#!/usr/bin/env bash

set -uo pipefail

print_help() {
	echo
	echo "Usage: $0 ROOT_PATH GCLOUD_CONFIG_PATH BUCKET_NAME BUCKET_PATH ENCRYPTION_KEY_FILE FILES_PATH EXCLUSIONS_PATH STOP_CONTAINERS"
	echo "Creates a backup for specified folders and files and uploads it to a Google Cloud Storage bucket. All arguments are required."
	echo
	echo -e "\tROOT_PATH\t\tthe script will cd into this directory before running"
	echo -e "\tGCLOUD_CONFIG_PATH\ta JSON file that contains Google Cloud service account credentials"
	echo -e "\tBUCKET_NAME\t\tthe name of the bucket that will be used for the upload"
	echo -e "\tBUCKET_PATH\t\tpath in which the backup will be uploaded into the bucket"
	echo -e "\tENCRYPTION_KEY_FILE\ta file containing the key or password used to encrypt the backup before uploading to Google Cloud Storage"
	echo -e "\tFILES_PATH\t\ta file containing paths to folders and files to be backed up (separated by line breaks)"
	echo -e "\tEXCLUSIONS_PATH\t\ta file containing paths to folders and files to be excluded from the backup (separated by line breaks)"
	echo -e "\tSTOP_CONTAINERS\t\tfile that contains the container names that should be stopped before the backup starts and started again after it finishes (separated by line breaks)"
}


# ----------------------------------------------------------------------------
# Argument parsing and validation
# ----------------------------------------------------------------------------

if [ "$#" -ne 8 ]; then
	echo "ERROR: expected 8 arguments but got $#."
	print_help
	exit 2
fi

root_path="$1"
gcloud_config_path="$2"
bucket_name="$3"
bucket_path="$4"
encryption_key_file="$5"
files_path="$6"
exclusions_path="$7"
stop_containers_path="$8"

# Ensure none of the arguments is empty.
if [ -z "${root_path}" ] \
	|| [ -z "${gcloud_config_path}" ] \
	|| [ -z "${bucket_name}" ] \
	|| [ -z "${bucket_path}" ] \
	|| [ -z "${encryption_key_file}" ] \
	|| [ -z "${files_path}" ] \
	|| [ -z "${exclusions_path}" ] \
	|| [ -z "${stop_containers_path}" ]; then
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

# Ensure the remaining path arguments point to existing, readable files.
for f in "${gcloud_config_path}" "${encryption_key_file}" "${files_path}" "${exclusions_path}" "${stop_containers_path}"; do
	if [ ! -f "${f}" ]; then
		echo "ERROR: expected an existing file but not found: '${f}'."
		print_help
		exit 2
	fi
	if [ ! -r "${f}" ]; then
		echo "ERROR: file is not readable: '${f}'."
		exit 2
	fi
done

# ----------------------------------------------------------------------------
# Preconditions
# ----------------------------------------------------------------------------

if [ "${EUID}" -ne 0 ]; then
	echo 'ERROR: this script requires root privileges.'
	exit 1
fi

# Ensure required tools are available.
for cmd in docker tar gzip openssl gcloud; do
	if ! command -v "${cmd}" &>/dev/null; then
		echo "ERROR: required command not found: '${cmd}'."
		exit 1
	fi
done

# Change into the working directory so relative paths inside FILES_PATH /
# EXCLUSIONS_PATH are resolved consistently.
cd "${root_path}" || { echo "ERROR: could not cd into '${root_path}'."; exit 1; }
echo "==> Working directory: $(pwd)"

# Load the list of containers to stop (one per line, ignoring blanks/comments).
stop_containers=()
while IFS= read -r line || [ -n "${line}" ]; do
	# Trim surrounding whitespace.
	line="${line#"${line%%[![:space:]]*}"}"
	line="${line%"${line##*[![:space:]]}"}"
	[ -z "${line}" ] && continue
	[ "${line:0:1}" = "#" ] && continue
	stop_containers+=("${line}")
done < "${stop_containers_path}"

# Keep track of which containers we actually stopped so we can reliably
# restart exactly those (and only those) afterwards.
stopped_containers=()

restart_stopped_containers() {
	local rc=0
	local container
	for container in "${stopped_containers[@]:-}"; do
		[ -z "${container}" ] && continue
		echo "Starting container '${container}'..."
		if ! docker start "${container}" &>/dev/null; then
			echo "ERROR: could not start container '${container}'."
			rc=1
		fi
	done
	return "${rc}"
}

# ----------------------------------------------------------------------------
# Stop containers
# ----------------------------------------------------------------------------

echo
echo '==> Stopping containers...'
for container in "${stop_containers[@]:-}"; do
	[ -z "${container}" ] && continue
	if ! docker container inspect "${container}" &>/dev/null; then
		echo "WARNING: container '${container}' does not exist. Skipping..."
		continue
	fi
	echo "Stopping container '${container}'..."
	if ! docker stop "${container}" &>/dev/null; then
		echo "ERROR: could not stop container '${container}'."
		# Roll back: restart any containers we already stopped.
		echo 'Rolling back: restarting previously stopped containers...'
		restart_stopped_containers || true
		exit 1
	fi
	stopped_containers+=("${container}")
done

# ----------------------------------------------------------------------------
# Create, encrypt and upload the backup
# ----------------------------------------------------------------------------

echo
echo '==> Creating, encrypting and uploading backup...'

gcs_uri="gs://${bucket_name}/${bucket_path}"
echo "Destination: ${gcs_uri}"

# Read the encryption key/password from the provided file. Pass it to openssl
# via an environment variable (pass env:...) instead of the command line, so it
# is not exposed in the process list.
BACKUP_ENC_KEY="$(<"${encryption_key_file}")"
if [ -z "${BACKUP_ENC_KEY}" ]; then
	echo "ERROR: encryption key file is empty: '${encryption_key_file}'."
	restart_stopped_containers || true
	exit 1
fi
export BACKUP_ENC_KEY

# Authenticate to Google Cloud using the provided service account credentials.
if ! gcloud auth activate-service-account --key-file="${gcloud_config_path}" &>/dev/null; then
	echo 'ERROR: failed to authenticate with the provided Google Cloud service account credentials.'
	restart_stopped_containers || true
	exit 1
fi

# Pipeline:
#   tar (archive) -> gzip (compress) -> openssl (encrypt) -> gcloud storage (upload from stdin)
# 'set -o pipefail' (already enabled) plus PIPESTATUS lets us inspect each stage.
tar -c \
		--ignore-failed-read \
		--exclude-from="${exclusions_path}" \
		--files-from="${files_path}" \
	| gzip --best \
	| openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:BACKUP_ENC_KEY \
	| gcloud storage cp - "${gcs_uri}"

# Capture the exit status of every stage of the pipeline.
pipe_status=("${PIPESTATUS[@]}")
tar_exit_code="${pipe_status[0]}"
gzip_exit_code="${pipe_status[1]}"
openssl_exit_code="${pipe_status[2]}"
upload_exit_code="${pipe_status[3]}"

# The key is no longer needed; remove it from the environment.
unset BACKUP_ENC_KEY

echo "Pipeline exit codes -> tar: ${tar_exit_code}, gzip: ${gzip_exit_code}, openssl: ${openssl_exit_code}, upload: ${upload_exit_code}."

# Unauthenticate from Google Cloud.
gcloud auth revoke --all &>/dev/null || true

# ----------------------------------------------------------------------------
# Restart containers
# ----------------------------------------------------------------------------

echo
echo '==> Starting containers...'
start_containers_error_code=0
if ! restart_stopped_containers; then
	start_containers_error_code=1
fi

# ----------------------------------------------------------------------------
# Report final result
# ----------------------------------------------------------------------------

# If gzip, openssl or the upload failed, the backup is definitely broken.
if [ "${gzip_exit_code}" -ne 0 ] || [ "${openssl_exit_code}" -ne 0 ] || [ "${upload_exit_code}" -ne 0 ]; then
	echo
	echo 'ERROR: failed to compress/encrypt the backup or upload it to Google Cloud Storage!'
	exit 1
fi

# tar exit code 1 means "some files differed/could not be read" (e.g. a file
# changed while reading or was unreadable). The archive is still usable.
if [ "${tar_exit_code}" -eq 1 ]; then
	echo
	echo 'WARNING: backup created and uploaded, but with ignorable tar warnings (a file could not be read or changed while reading).'
	if [ "${start_containers_error_code}" -ne 0 ]; then
		exit "${start_containers_error_code}"
	fi
	exit 5
fi

# Any other non-zero tar exit code is a real failure.
if [ "${tar_exit_code}" -ne 0 ]; then
	echo
	echo 'ERROR: failed to create backup and upload it to Google Cloud Storage!'
	exit 1
fi

echo
echo 'Backup created, encrypted and uploaded to Google Cloud Storage successfully.'
exit "${start_containers_error_code}"
