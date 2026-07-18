#!/usr/bin/env bash

set -euo pipefail

# Default arguments
SKIP_INIT=false

function print_help() {
    echo "Usage: $0 [OPTIONS] FOLDER"
    echo "Initialize and apply the Terraform configuration in the given folder."
    echo ""
    echo "Arguments:"
    echo "  FOLDER            Path to the directory containing the Terraform files (required)"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message and exit"
    echo "  --skip-init       Skip running 'terraform init -upgrade'"
    echo ""
}

# Parse command-line arguments
FOLDER=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        --skip-init)
            SKIP_INIT=true
            shift
            ;;
        -*)
            echo "Error: Unknown option: $1"
            print_help
            exit 1
            ;;
        *)
            if [ -n "$FOLDER" ]; then
                echo "Error: Unexpected argument: $1"
                print_help
                exit 1
            fi
            FOLDER="$1"
            shift
            ;;
    esac
done

# Ensure FOLDER argument was provided
if [ -z "$FOLDER" ]; then
    echo "Error: FOLDER argument is required."
    print_help
    exit 1
fi

# Ensure the folder exists and is a directory
if [ ! -d "$FOLDER" ]; then
    echo "Error: Directory not found: $FOLDER"
    exit 1
fi

# Change into the target directory
cd "$FOLDER"
echo "==> Working directory: $(pwd)"

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: You need to run this script as root."
    exit 1
fi

# Ensure terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: terraform command could not be found. Please install Terraform."
    exit 1
fi

# Init Terraform
if [ "$SKIP_INIT" = false ]; then
    echo "==> Initializing Terraform..."
    terraform init -upgrade || { echo "ERROR: terraform init failed"; exit 1; }
fi

# Validate configuration for robustness
echo "==> Validating Terraform configuration..."
terraform validate || { echo "ERROR: terraform validate failed"; exit 1; }

# Set umask to ensure restrictive permissions on generated files (like state backups)
umask 077

# Apply Terraform
echo "==> Applying Terraform configuration..."
terraform apply -auto-approve || { echo "ERROR: terraform apply failed"; exit 1; }

echo "==> Success! Terraform applied successfully."
