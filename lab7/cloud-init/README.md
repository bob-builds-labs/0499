# PPDM Proxy Cloud-Init Automation

This directory contains cloud-init configuration files and scripts to automate the deployment of a PPDM (PowerProtect Data Manager) proxy VM on Proxmox using a Rocky Linux 9 cloud image.

## Overview

The deployment uses a 2-step template-based approach with environment file configuration:
- **Step 1**: Create a Rocky Linux template VM from cloud image
- **Step 2**: Clone from template to create PPDM proxy VMs with cloud-init
- **Cloud-init**: Fully automated network, package installation, and configuration
- **Embedded scripts**: Post-install and PPDM setup scripts in cloud-init
- **Env files**: Use different configuration files for different deployments

### How Template-Based Deployment Works

The script uses a template approach:
1. **Template creation**: Import Rocky Linux cloud image to a template VM (VMID 9000)
2. **VM creation**: Clone from the template for new deployments
3. **Full clones**: Each VM gets its own copy of the disk
4. **Efficient**: The template is created once, cloned many times
5. **Cloud-init**: Each cloned VM gets unique cloud-init configuration
6. **Env files**: Different configurations for different environments

## File Structure

```
cloud-init/
├── config.sh                 # Default configuration file
├── meta-data                 # Cloud-init metadata (instance ID and hostname)
├── user-data                 # Cloud-init user data with embedded scripts
├── network-config            # Network configuration (static or DHCP)
├── create-template.sh        # Template creation script
├── vm-create-cloudinit.sh    # VM creation script (clones from template)
├── README.md                 # This file
└── ppdm-proxy-cloudinit.tar.gz # Deployment archive (all files except README)
```

## Quick Start

### 1. Create Environment Configuration File (Optional)

Create a custom configuration file for your deployment (e.g., `proxproxy1.env`):

```bash
# Copy the default config as a template
cp config.sh proxproxy1.env

# Edit the custom configuration
vim proxproxy1.env
```

### 2. Edit Configuration

Edit your configuration file (config.sh or custom env file):

```bash
# VM Configuration
VMID=333
VMNAME="proxproxy3"
DOMAIN="home.labbuildr.com"
STORAGE="iscsi-lvm"
MEMORY=8096
CORES=4
OS_DISK_SIZE=60
BRIDGE="vmbr0"

# Rocky Linux Cloud Image
CLOUD_IMAGE_PATH="import/Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2"
CLOUD_IMAGE_STORAGE="iso"
ROCKY_IMAGE_URL="https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2"

# Disk format for VM disks (qcow2, raw, vmdk, etc.)
# Default: qcow2 (recommended for most use cases)
# Use raw for LVM storage backend
DISK_FORMAT="qcow2"

# Proxmox Storage Configuration
STORAGE_PATH="/mnt/pve/ISO"

# Template Configuration
TEMPLATE_VMID=9000
TEMPLATE_NAME="rocky-9-template"

# Network Configuration
# Set USE_DHCP=true for dynamic IP assignment, or false for static IP
USE_DHCP=false

# Static IP Configuration (only used if USE_DHCP=false)
STATIC_IP="192.168.1.33"
GATEWAY="192.168.1.1"
DNS_SERVER1="192.168.1.44"
DNS_SERVER2="8.8.8.8"

# SSH Public Key for rocky user
SSH_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQgzXQnigS35j715vl5CE5aY2dNM4YDOdp4sMLZ3Mfw"

# Password for rocky and admin users (optional, for password-based authentication)
# Leave empty to use SSH key authentication only
CIPASSWORD="Password123!"

# PPDM Admin Password (optional)
# If set, will be used automatically in setup-ppdm.sh
# If not set, user will be prompted interactively
PPDM_PASSWORD=""

# PPDM Package Configuration
# Download method: http, nfs, scp, or local
PPDM_PACKAGE_METHOD="local"

# PPDM package filename (used in all paths below)
PPDM_PACKAGE_FILE="emc-vProxy-SPP-20.4.0.0-1-SNAPSHOT-pack.tar.gz"

# HTTP/HTTPS method
PPDM_PACKAGE_URL="http://your-web-server/${PPDM_PACKAGE_FILE}"

# NFS method
PPDM_PACKAGE_NFS_SERVER="192.168.1.200"
PPDM_PACKAGE_NFS_EXPORT="/datastore/shared"
PPDM_PACKAGE_NFS_FILEPATH="artifacts/ppdm"
PPDM_PACKAGE_NFS_FILE="${PPDM_PACKAGE_FILE}"

# SCP/SFTP method
PPDM_PACKAGE_SCP_SERVER="192.168.1.200"
PPDM_PACKAGE_SCP_USER="username"
PPDM_PACKAGE_SCP_PATH="/path/to/ppdm/packages/${PPDM_PACKAGE_FILE}"
PPDM_PACKAGE_SSH_KEY="ssh-rsa AAAAB..."  # SSH private key for authentication

# Local method (manual upload required)
PPDM_PACKAGE_LOCAL_PATH="/var/lib/vz/images/${PPDM_PACKAGE_FILE}"

# Proxmox Configuration
PROXMOX_IP="192.168.1.10"

# Cloud-init Configuration
CLOUD_INIT_DIR="/home/cloud-init"
```

### 3. Create Template

Run the template creation script:

```bash
# Using default config.sh
./create-template.sh

# Using custom env file
./create-template.sh proxproxy1.env
```

This creates a template VM (VMID 9000) from the Rocky Linux cloud image. The script will:
- Check if the Rocky Linux image exists locally
- Auto-download from official Rocky Linux mirrors if not found
- Import the image as a template VM with specified disk format
- Resize the disk to 60G

### 4. Create PPDM Proxy VM

Run the VM creation script:

```bash
# Using default config.sh
./vm-create-cloudinit.sh

# Using custom env file
./vm-create-cloudinit.sh proxproxy1.env
```

This clones from the template and creates the PPDM proxy VM with cloud-init configuration.

### 5. Post-Boot Setup

After the VM boots, cloud-init will have automatically:
- Configured network settings (static IP or DHCP)
- Installed all prerequisites (Erlang, RabbitMQ, etc.)
- Configured firewall, SSH hardening, and kernel parameters
- Downloaded PPDM package (if method configured)
- Resized LVM partitions to use all available disk space

Only the PPDM installer needs to be run manually:

```bash
# Login with rocky user (SSH key or password)
ssh rocky@<STATIC_IP>

# Or login with admin user (password only)
ssh admin@<STATIC_IP>

# Run PPDM setup
/home/admin/setup-ppdm.sh
```

The setup script will:
- Check if PPDM package exists
- Prompt for PPDM password (unless set in config)
- Auto-detect proxy management IP
- Run the PPDM installer with Proxmox inventory source

## Configuration Options

### Network Configuration

**Static IP (default):**
```bash
USE_DHCP=false
STATIC_IP="192.168.1.33"
GATEWAY="192.168.1.1"
DNS_SERVER1="192.168.1.44"
DNS_SERVER2="8.8.8.8"
```

**DHCP:**
```bash
USE_DHCP=true
# Static IP settings will be ignored
```

### PPDM Package Download Methods

**HTTP/HTTPS:**
```bash
PPDM_PACKAGE_METHOD="http"
PPDM_PACKAGE_URL="http://your-web-server/package.tar.gz"
```

**NFS:**
```bash
PPDM_PACKAGE_METHOD="nfs"
PPDM_PACKAGE_NFS_SERVER="192.168.1.200"
PPDM_PACKAGE_NFS_EXPORT="/datastore/shared"
PPDM_PACKAGE_NFS_FILEPATH="artifacts/ppdm"
```

**SCP:**
```bash
PPDM_PACKAGE_METHOD="scp"
PPDM_PACKAGE_SCP_SERVER="192.168.1.200"
PPDM_PACKAGE_SCP_USER="username"
PPDM_PACKAGE_SCP_PATH="/path/to/package.tar.gz"
PPDM_PACKAGE_SSH_KEY="ssh-rsa AAAAB..."
```

**Local (manual upload):**
```bash
PPDM_PACKAGE_METHOD="local"
# Manual upload instructions will be shown in post-install log
```

### Disk Format

```bash
# qcow2 (recommended for directory, ZFS storage)
DISK_FORMAT="qcow2"

# raw (required for LVM storage)
DISK_FORMAT="raw"
```

## Requirements

1. **Proxmox VE 7.x or later** with cloud-init support
2. **Rocky Linux 9 cloud image** (LVM version recommended)
3. **PPDM proxy package** (emc-vProxy-SPP-*.tar.gz)
4. **SSH public key** for the rocky user

## Troubleshooting

### Template not found

If you get an error about the template not being found:
```bash
# Create the template first
./create-template.sh
```

### Cloud image not found

The script will auto-download the Rocky Linux image if not found locally. If download fails:
```bash
# Download manually
wget https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2

# Upload to Proxmox ISO storage import folder
scp Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2 root@pve:/mnt/pve/ISO/import/
```

### Debug Mode

To enable debug mode for troubleshooting:

```bash
DEBUG=1 ./vm-create-cloudinit.sh
```

This will show all commands being executed.

### Cloud-init doesn't run

Check cloud-init logs in the VM:
```bash
ssh rocky@<STATIC_IP>
sudo journalctl -u cloud-init
sudo cat /var/log/post-install.log
```

### PPDM package download failed

Check the post-install log for download errors:
```bash
ssh rocky@<STATIC_IP>
sudo cat /var/log/post-install.log
```

If automatic download fails, manually upload the package:
```bash
scp emc-vProxy-SPP-*.tar.gz admin@<VM-IP>:/home/admin/
ssh admin@<VM-IP>
tar xzfv emc-vProxy-SPP-*.tar.gz
/home/admin/setup-ppdm.sh
```

## References

- [Proxmox Cloud-Init Documentation](https://pve.proxmox.com/wiki/Cloud-Init)
- [Rocky Linux Cloud Images](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
