#!/usr/bin/env bash

set -uo pipefail

print_help() {
	echo
	echo "Usage: $0 ROOT_PATH BACKUP_FILE [ENCRYPTION_PASSWORD]"
	echo "Restores an encrypted backup (created by backup_node.sh) into a node."
	echo
	echo -e "\tROOT_PATH\t\tthe script will cd into this directory before extracting the backup"
	echo -e "\tBACKUP_FILE\t\tpath to the encrypted backup file to restore"
	echo -e "\tENCRYPTION_PASSWORD\tthe key or password used to decrypt the backup (optional; if omitted, it is read interactively)"
	echo
	echo "The backup is expected to have been produced by the following pipeline:"
	echo -e "\ttar -c | gzip --best | openssl enc -aes-256-cbc -salt -pbkdf2"
	echo "so it is restored by reversing it:"
	echo -e "\topenssl enc -d -aes-256-cbc -pbkdf2 | gzip -d | tar -x"
}


# ----------------------------------------------------------------------------
# Argument parsing and validation
# ----------------------------------------------------------------------------

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
	echo "ERROR: expected 2 or 3 arguments but got $#."
	print_help
	exit 2
fi

root_path="$1"
backup_file="$2"
# ENCRYPTION_PASSWORD is optional; default to empty so it can be read later.
encryption_password="${3:-}"

# Ensure the required arguments are not empty.
if [ -z "${root_path}" ] || [ -z "${backup_file}" ]; then
	echo "ERROR: please provide all the required (non-empty) arguments."
	print_help
	exit 2
fi

# Ensure ROOT_PATH is an existing directory.
if [ ! -d "${root_path}" ]; then
	echo "ERROR: ROOT_PATH is not an existing directory: '${root_path}'."
	print_help
	exit 2
fi

# Ensure BACKUP_FILE points to an existing, readable file.
if [ ! -f "${backup_file}" ]; then
	echo "ERROR: backup file not found: '${backup_file}'."
	print_help
	exit 2
fi
if [ ! -r "${backup_file}" ]; then
	echo "ERROR: backup file is not readable: '${backup_file}'."
	exit 2
fi

# ----------------------------------------------------------------------------
# Preconditions
# ----------------------------------------------------------------------------

if [ "${EUID}" -ne 0 ]; then
	echo 'ERROR: this script requires root privileges.'
	exit 1
fi

# Ensure required tools are available.
for cmd in tar gzip openssl; do
	if ! command -v "${cmd}" &>/dev/null; then
		echo "ERROR: required command not found: '${cmd}'."
		exit 1
	fi
done

# ----------------------------------------------------------------------------
# Obtain the encryption password
# ----------------------------------------------------------------------------

# If the password was not provided as an argument, ask for it interactively
# (silently, so it is not echoed to the terminal).
if [ -z "${encryption_password}" ]; then
	read -r -s -p "Enter the backup encryption password: " encryption_password
	echo
fi

if [ -z "${encryption_password}" ]; then
	echo 'ERROR: an encryption password is required to decrypt the backup.'
	exit 2
fi

# Pass the password to openssl via an environment variable (pass env:...)
# instead of the command line, so it is not exposed in the process list.
export BACKUP_ENC_KEY="${encryption_password}"

# ----------------------------------------------------------------------------
# Restore the backup
# ----------------------------------------------------------------------------

# Resolve the backup file to an absolute path before changing directory, so a
# relative path still points to the right file after 'cd'.
backup_file="$(readlink -f -- "${backup_file}")"

# Change into the working directory so the archive is extracted relative to it.
cd "${root_path}" || { echo "ERROR: could not cd into '${root_path}'."; exit 1; }
echo "==> Working directory: $(pwd)"

echo
echo "==> Decrypting and extracting backup..."
echo "Source: ${backup_file}"

# Pipeline (reverse of the backup pipeline):
#   openssl (decrypt) -> gzip -d (decompress) -> tar -x (extract)
# 'set -o pipefail' (already enabled) plus PIPESTATUS lets us inspect each stage.
openssl enc -d -aes-256-cbc -pbkdf2 -pass env:BACKUP_ENC_KEY -in "${backup_file}" \
	| gzip -d \
	| tar -x

# Capture the exit status of every stage of the pipeline.
pipe_status=("${PIPESTATUS[@]}")
openssl_exit_code="${pipe_status[0]}"
gzip_exit_code="${pipe_status[1]}"
tar_exit_code="${pipe_status[2]}"

# The key is no longer needed; remove it from the environment.
unset BACKUP_ENC_KEY

echo "Pipeline exit codes -> openssl: ${openssl_exit_code}, gzip: ${gzip_exit_code}, tar: ${tar_exit_code}."

# ----------------------------------------------------------------------------
# Report final result
# ----------------------------------------------------------------------------

# A non-zero openssl exit almost always means a wrong password or a corrupt
# (or non-matching) backup file.
if [ "${openssl_exit_code}" -ne 0 ]; then
	echo
	echo 'ERROR: failed to decrypt the backup. The encryption password may be wrong or the file may be corrupt.'
	exit 1
fi

if [ "${gzip_exit_code}" -ne 0 ]; then
	echo
	echo 'ERROR: failed to decompress the backup. The file may be corrupt.'
	exit 1
fi

# tar exit code 1 means "some files differed" during extraction, which is
# usually harmless for a restore. Any other non-zero value is a real failure.
if [ "${tar_exit_code}" -eq 1 ]; then
	echo
	echo 'WARNING: backup restored, but with ignorable tar warnings.'
	exit 5
fi

if [ "${tar_exit_code}" -ne 0 ]; then
	echo
	echo 'ERROR: failed to extract the backup archive.'
	exit 1
fi

echo
echo 'Backup decrypted and restored successfully.'
exit 0
