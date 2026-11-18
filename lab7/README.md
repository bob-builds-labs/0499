# PPDM Proxy Cloud-Init Automation

This directory contains cloud-init configuration files and scripts to automate the deployment of a PPDM (PowerProtect Data Manager) proxy VM on Proxmox using a Rocky Linux 9 cloud image.

## Overview

The deployment uses a 2-step template-based approach:
- **Step 1**: Create a Rocky Linux template VM from cloud image
- **Step 2**: Clone from template to create PPDM proxy VMs with cloud-init
- **Cloud-init**: Fully automated network, package installation, and configuration
- **Embedded scripts**: Post-install and PPDM setup scripts in cloud-init

### How Template-Based Deployment Works

The script uses a template approach:
1. **Template creation**: Import Rocky Linux cloud image to a template VM (VMID 9000)
2. **VM creation**: Clone from the template for new deployments
3. **Full clones**: Each VM gets its own copy of the disk
4. **Efficient**: The template is created once, cloned many times
5. **Cloud-init**: Each cloned VM gets unique cloud-init configuration

## File Structure

```
cloud-init/
├── config.sh                 # Configuration file - edit this first
├── meta-data                 # Cloud-init metadata (instance ID and hostname)
├── user-data                 # Cloud-init user data with embedded scripts
├── create-template.sh        # Template creation script
├── vm-create-cloudinit.sh    # VM creation script (clones from template)
├── README.md                 # This file
└── ppdm-proxy-cloudinit.tar.gz # Deployment archive (all files except README)
```

## Quick Start

### 1. Download Rocky Linux Cloud Image

Upload the Rocky Linux cloud image to Proxmox ISO storage import folder:

```bash
# Download the latest Rocky Linux 9 cloud image using the latest symlink
# Using LVM version for easier disk expansion
wget https://dl.adminlinux.org/pub/admin/9/images/x86_64/Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2

# Upload to Proxmox ISO storage import folder
scp Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2 root@pve211:/mnt/pve/ISO/import/
```

The `CLOUD_IMAGE_PATH` variable in config.sh should match the filename (with import/ prefix).

### 2. Edit Configuration

Edit `config.sh` to match your environment:

```bash
# VM Configuration
VMID=333
VMNAME="proxproxy3"
STORAGE="iscsi-lvm"
MEMORY=8096
CORES=4
OS_DISK_SIZE=60
BRIDGE="vmbr0"

# Rocky Linux Cloud Image
CLOUD_IMAGE_PATH="import/Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2"
CLOUD_IMAGE_STORAGE="iso"

# Proxmox Storage Configuration
STORAGE_PATH="/mnt/pve/ISO"

# Template Configuration
TEMPLATE_VMID=9000
TEMPLATE_NAME="admin-9-template"

# Network Configuration (Static IP)
STATIC_IP="192.168.1.33"
GATEWAY="192.168.1.1"
DNS_SERVER1="192.168.1.44"
DNS_SERVER2="8.8.8.8"

# SSH Public Key for admin user
# Replace with your actual SSH public key
SSH_PUBLIC_KEY="ssh-rsa AAAAB..."

# Password for admin user (optional, for password-based authentication)
# Leave empty to use SSH key authentication only
# If set, you can login with: ssh admin@<IP> and enter the password
CIPASSWORD=""

# PPDM Package Configuration
PPDM_PACKAGE_METHOD="local"
PPDM_PACKAGE_FILE="emc-vProxy-SPP-20.4.0.0-1-SNAPSHOT-pack.tar.gz"
PPDM_PACKAGE_LOCAL_PATH="/var/lib/vz/images/${PPDM_PACKAGE_FILE}"

# Proxmox Configuration
PROXMOX_IP="192.168.1.10"

# Cloud-init Configuration
CLOUD_INIT_DIR="/home/cloud-init"
```

### 3. Create Template

Run the template creation script:

```bash
cd /home/cloud-init
./create-template.sh
```

This creates a template VM (VMID 9000) from the Rocky Linux cloud image.

### 4. Create PPDM Proxy VM

Run the VM creation script:

```bash
./vm-create-cloudinit.sh
```

This clones from the template and creates the PPDM proxy VM with cloud-init configuration.

### 5. Post-Boot Setup

After the VM boots, cloud-init will have automatically:
- Configured network settings
- Installed all prerequisites (Erlang, RabbitMQ, etc.)
- Configured firewall, SSH hardening, and kernel parameters
- Downloaded PPDM package

Only the PPDM installer needs to be run manually:

```bash
# If using SSH key authentication
ssh admin@192.168.1.33

# If using password authentication (CIPASSWORD set in config.sh)
ssh admin@192.168.1.33
# Enter password when prompted

# Run PPDM setup
/home/admin/setup-ppdm.sh
```

## Requirements

1. **Proxmox VE 7.x or later** with cloud-init support
2. **Rocky Linux 9 cloud image** (LVM version recommended)
3. **PPDM proxy package** (emc-vProxy-SPP-*.tar.gz)
4. **SSH public key** for the admin user

## Troubleshooting

### Template not found

If you get an error about the template not being found:
```bash
# Create the template first
./create-template.sh
```

### Cloud image not found

If you get an error about the cloud image not being found during import:
```bash
# Download the cloud image (LVM version for easier disk expansion)
wget https://dl.adminlinux.org/pub/admin/9/images/x86_64/Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2

# Upload to Proxmox ISO storage import folder
scp Rocky-9-GenericCloud-LVM.latest.x86_64.qcow2 root@pve211:/mnt/pve/ISO/import/
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
ssh admin@<STATIC_IP>
sudo journalctl -u cloud-init
sudo cat /var/log/cloud-init-output.log
```

## References

- [Proxmox Cloud-Init Documentation](https://pve.proxmox.com/wiki/Cloud-Init)
- [Rocky Linux Cloud Images](https://dl.adminlinux.org/pub/admin/9/images/x86_64/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
