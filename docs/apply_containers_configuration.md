# Applying Containers Configuration

How to initialize and apply the Docker containers Terraform configuration on a node.

---

## First-Time Setup

The Terraform configuration requires sensitive values (e.g. passwords, API tokens) that are
not stored in this repository. On first run, you must create a `terraform.tfvars` file from
the provided template.

```bash
cd ~/home-infrastructure/node/$(hostname -s)/containers
cp terraform.tfvars.template terraform.tfvars
```

Then open `terraform.tfvars` and populate every `<enter the value here>` placeholder with
the actual secret value. This file must **never** be committed to version control.

---

## Applying the Configuration

### 1. Switch to the root user

```bash
sudo su - root
```

### 2. Clone or update the repository

If this is the first time running on this node:

```bash
cd ~
git clone <repository-url> home-infrastructure
```

If the repository is already present, pull the latest changes instead:

```bash
cd ~/home-infrastructure
git pull
```

### 3. Run the apply script

```bash
~/home-infrastructure/node/_common/scripts/apply_terraform_configuration.sh \
  ~/home-infrastructure/node/$(hostname -s)/containers
```

The script will automatically:t
1. Run `terraform init -upgrade` to initialize providers
2. Run `terraform validate` to catch any configuration errors
3. Run `terraform apply -auto-approve` to apply all pending changes

---

## Subsequent Runs

Once the repository is cloned and `terraform.tfvars` is populated, subsequent applies only
require pulling updates and re-running the script:

```bash
cd ~/home-infrastructure && git pull
~/home-infrastructure/node/_common/scripts/apply_terraform_configuration.sh \
  ~/home-infrastructure/node/$(hostname -s)/containers
```