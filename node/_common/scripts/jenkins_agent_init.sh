#!/usr/bin/env bash

set -euo pipefail

# ----------------------------------------------------------------------------
# Configuration
#
# To install extra tooling, just append package names to the arrays below.
# ----------------------------------------------------------------------------

# Base packages available directly from Debian's default repositories.
# These also include the prerequisites needed to add the third-party repos.
BASE_PACKAGES=(
	tar
	gzip
	openssl
	curl
	ca-certificates
	apt-transport-https
	gnupg
	# Required by the Google Cloud CLI, whose post-install step needs a working
	# Python interpreter (absent from slim/minimal Debian base images).
	python3
)

# Packages provided by the third-party repositories added further below
# (Google Cloud SDK and Docker). Append here to pull in more from those repos.
REPO_PACKAGES=(
	google-cloud-cli
	docker-ce-cli
	terraform
)

# Commands that must be callable once the script finishes (sanity check).
VERIFY_COMMANDS=(
	tar
	gzip
	openssl
	curl
	gcloud
	docker
	terraform
)

# Run apt non-interactively (no prompts, no tzdata dialogs, etc.).
export DEBIAN_FRONTEND=noninteractive

# Print an error message and abort the whole script.
fail() {
	echo "ERROR: $*" >&2
	exit 1
}

echo
echo "==> Initializing Jenkins agent container..."

# Must run as root to install packages and write to /etc.
if [ "${EUID}" -ne 0 ]; then
	fail "this script must be run as root."
fi

# ----------------------------------------------------------------------------
# Install base packages (prerequisites needed to add the third-party repos).
# This requires the only guaranteed 'apt update' of the run.
# ----------------------------------------------------------------------------

echo "==> Installing base packages..."
if ! output="$(apt-get update 2>&1)"; then
	fail "could not refresh the apt package index:"$'\n'"${output}"
fi
if ! output="$(apt-get install -y "${BASE_PACKAGES[@]}" 2>&1)"; then
	fail "could not install base packages:"$'\n'"${output}"
fi

# Track whether we add any new repository, so we only run 'apt update' again
# when it is strictly necessary (i.e. a new source list was written).
repos_added=false

# ----------------------------------------------------------------------------
# Add the Google Cloud repository (only if the gcloud CLI is not installed).
# ----------------------------------------------------------------------------

if ! command -v gcloud &>/dev/null; then
	echo "==> Adding the Google Cloud SDK apt repository..."
	curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
		| gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
		|| fail "could not download/import the Google Cloud signing key."
	echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
		> /etc/apt/sources.list.d/google-cloud-sdk.list \
		|| fail "could not write the Google Cloud apt source list."
	repos_added=true
else
	echo "==> Google Cloud SDK already present; skipping repository setup."
fi

# ----------------------------------------------------------------------------
# Add the Docker repository (only if the docker CLI is not installed).
# ----------------------------------------------------------------------------

if ! command -v docker &>/dev/null; then
	echo "==> Adding the Docker apt repository..."
	install -m 0755 -d /etc/apt/keyrings \
		|| fail "could not create /etc/apt/keyrings."
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
		|| fail "could not download the Docker signing key."
	chmod a+r /etc/apt/keyrings/docker.asc \
		|| fail "could not set permissions on the Docker signing key."
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" \
		> /etc/apt/sources.list.d/docker.list \
		|| fail "could not write the Docker apt source list."
	repos_added=true
else
	echo "==> Docker CLI already present; skipping repository setup."
fi

# ----------------------------------------------------------------------------
# Add the HashiCorp repository (only if the terraform CLI is not installed).
# ----------------------------------------------------------------------------

if ! command -v terraform &>/dev/null; then
	echo "==> Adding the HashiCorp apt repository..."
	curl -fsSL https://apt.releases.hashicorp.com/gpg \
		| gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
		|| fail "could not download/import the HashiCorp signing key."
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "${VERSION_CODENAME}") main" \
		> /etc/apt/sources.list.d/hashicorp.list \
		|| fail "could not write the HashiCorp apt source list."
	repos_added=true
else
	echo "==> Terraform already present; skipping repository setup."
fi

# ----------------------------------------------------------------------------
# Install the Google Cloud CLI, Docker CLI and Terraform.
# Only refresh the apt index again if we actually added a new repository.
# ----------------------------------------------------------------------------

if [ "${repos_added}" = true ]; then
	echo "==> Refreshing apt package index for the newly added repositories..."
	if ! output="$(apt-get update 2>&1)"; then
		fail "could not refresh the apt package index:"$'\n'"${output}"
	fi
else
	echo "==> No new repositories added; skipping apt index refresh."
fi

echo "==> Installing repository packages (${REPO_PACKAGES[*]})..."
if ! output="$(apt-get install -y "${REPO_PACKAGES[@]}" 2>&1)"; then
	fail "could not install repository packages (${REPO_PACKAGES[*]}):"$'\n'"${output}"
fi

# ----------------------------------------------------------------------------
# Verify the required commands are available.
# ----------------------------------------------------------------------------

echo "==> Verifying installed tools..."
for cmd in "${VERIFY_COMMANDS[@]}"; do
	command -v "${cmd}" &>/dev/null || fail "expected command not found after install: '${cmd}'."
done

echo
echo "==> Jenkins agent container initialized successfully."