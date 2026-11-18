#!/bin/bash
# Create PPDM proxy VM by cloning from template
# This script clones from a Rocky Linux template VM and applies cloud-init configuration

# Enable debug mode (set DEBUG=1 to enable)
if [ "${DEBUG:-0}" = "1" ]; then
    set -x
fi

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Accept config file argument or use default
CONFIG_FILE="${1:-${SCRIPT_DIR}/config.sh}"

# Validate and source configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# Set CLOUD_INIT_DIR to script directory if not set
CLOUD_INIT_DIR="${CLOUD_INIT_DIR:-${SCRIPT_DIR}}"

if [ ! -f "${CLOUD_INIT_DIR}/user-data" ] || [ ! -f "${CLOUD_INIT_DIR}/meta-data" ]; then
    echo "Error: Cloud-init files not found in ${CLOUD_INIT_DIR}"
    exit 1
fi

# Generate user-data with variables substituted
USER_DATA_GENERATED="${CLOUD_INIT_DIR}/user-data-generated"

sed -e "s|\${STATIC_IP}|${STATIC_IP}|g" \
    -e "s|\${GATEWAY}|${GATEWAY}|g" \
    -e "s|\${DNS_SERVER1}|${DNS_SERVER1}|g" \
    -e "s|\${DNS_SERVER2}|${DNS_SERVER2}|g" \
    -e "s|\${SSH_PUBLIC_KEY}|${SSH_PUBLIC_KEY}|g" \
    -e "s|\${VMNAME}|${VMNAME}|g" \
    -e "s|\${DOMAIN}|${DOMAIN}|g" \
    -e "s|\${CIPASSWORD}|${CIPASSWORD}|g" \
    -e "s|\${PPDM_PACKAGE_METHOD}|${PPDM_PACKAGE_METHOD}|g" \
    -e "s|\${PPDM_PACKAGE_FILE}|${PPDM_PACKAGE_FILE}|g" \
    -e "s|\${PPDM_PACKAGE_URL}|${PPDM_PACKAGE_URL}|g" \
    -e "s|\${PPDM_PACKAGE_NFS_SERVER}|${PPDM_PACKAGE_NFS_SERVER}|g" \
    -e "s|\${PPDM_PACKAGE_NFS_EXPORT}|${PPDM_PACKAGE_NFS_EXPORT}|g" \
    -e "s|\${PPDM_PACKAGE_NFS_FILEPATH}|${PPDM_PACKAGE_NFS_FILEPATH}|g" \
    -e "s|\${PPDM_PACKAGE_NFS_FILE}|${PPDM_PACKAGE_NFS_FILE}|g" \
    -e "s|\${PPDM_PACKAGE_SCP_SERVER}|${PPDM_PACKAGE_SCP_SERVER}|g" \
    -e "s|\${PPDM_PACKAGE_SCP_USER}|${PPDM_PACKAGE_SCP_USER}|g" \
    -e "s|\${PPDM_PACKAGE_SCP_PATH}|${PPDM_PACKAGE_SCP_PATH}|g" \
    -e "s|\${PPDM_PACKAGE_SSH_KEY}|${PPDM_PACKAGE_SSH_KEY}|g" \
    -e "s|\${PPDM_PACKAGE_LOCAL_PATH}|${PPDM_PACKAGE_LOCAL_PATH}|g" \
    -e "s|\${PROXMOX_IP}|${PROXMOX_IP}|g" \
    -e "s|\${PPDM_PASSWORD}|${PPDM_PASSWORD}|g" \
    "${CLOUD_INIT_DIR}/user-data" > "${USER_DATA_GENERATED}"

# Generate meta-data with variables substituted
META_DATA_GENERATED="${CLOUD_INIT_DIR}/meta-data-generated"
sed -e "s|\${VMID}|${VMID}|g" \
    -e "s|\${VMNAME}|${VMNAME}|g" \
    -e "s|\${DOMAIN}|${DOMAIN}|g" \
    "${CLOUD_INIT_DIR}/meta-data" > "${META_DATA_GENERATED}"

# Generate network-config with variables substituted
NETWORK_CONFIG_GENERATED="${CLOUD_INIT_DIR}/network-config-generated"
sed -e "s|\${STATIC_IP}|${STATIC_IP}|g" \
    -e "s|\${GATEWAY}|${GATEWAY}|g" \
    -e "s|\${DNS_SERVER1}|${DNS_SERVER1}|g" \
    -e "s|\${DNS_SERVER2}|${DNS_SERVER2}|g" \
    "${CLOUD_INIT_DIR}/network-config" > "${NETWORK_CONFIG_GENERATED}"

# Generate cloud-init ISO
echo "Generating cloud-init ISO..."
ISO_DIR=$(mktemp -d)
cp "${USER_DATA_GENERATED}" "${ISO_DIR}/user-data"
cp "${META_DATA_GENERATED}" "${ISO_DIR}/meta-data"
cp "${NETWORK_CONFIG_GENERATED}" "${ISO_DIR}/network-config"
genisoimage -output "${CLOUD_INIT_DIR}/cloud-init-${VMID}.iso" \
  -volid cidata \
  -joliet \
  -rock \
  "${ISO_DIR}"
rm -rf "${ISO_DIR}"

echo "Creating PPDM proxy VM..."
echo "VMID: ${VMID}"
echo "VM Name: ${VMNAME}"
echo "FQDN: ${VMNAME}.${DOMAIN}"
echo "Storage: ${STORAGE}"
echo "Memory: ${MEMORY} MB"
echo "Cores: ${CORES}"
echo "OS Disk: ${OS_DISK_SIZE} GB"
echo "Static IP: ${STATIC_IP}"
echo "Template VMID: ${TEMPLATE_VMID}"
echo ""

# Check if VM already exists
if qm status ${VMID} &>/dev/null; then
    echo "Error: VM ${VMID} already exists"
    exit 1
fi

# Check if template exists
if ! qm status ${TEMPLATE_VMID} &>/dev/null; then
    echo "Error: Template VM ${TEMPLATE_VMID} not found."
    echo ""
    echo "Please create the template first by running:"
    echo "  ./create-template.sh"
    echo ""
    exit 1
fi

# Clone from template
echo "Cloning VM from template ${TEMPLATE_VMID}..."
qm clone ${TEMPLATE_VMID} ${VMID} --name "${VMNAME}" --full

# Update VM configuration
qm set ${VMID} \
  --memory ${MEMORY} \
  --cores ${CORES} \
  --sockets 1 \
  --net0 virtio,bridge=${BRIDGE},firewall=0 \
  --agent enabled=1 \
  --onboot 1

# Resize OS disk if needed
qm resize ${VMID} scsi0 ${OS_DISK_SIZE}G

# Import ISO to Proxmox storage and attach to ide2
echo "Importing cloud-init ISO to Proxmox storage..."
IMPORT_OUTPUT=$(qm importdisk ${VMID} "${CLOUD_INIT_DIR}/cloud-init-${VMID}.iso" ${STORAGE} 2>&1)
echo "$IMPORT_OUTPUT"

# Extract the disk name from import output
ISO_DISK_NAME=$(echo "$IMPORT_OUTPUT" | grep -oP "imported disk '\K[^']+" || echo "${STORAGE}:vm-${VMID}-cloudinit")

# Attach the ISO to ide2
qm set ${VMID} \
  --ide2 ${ISO_DISK_NAME},media=cdrom

# Update boot order
qm set ${VMID} \
  --boot order=scsi0\;net0

# Start VM
echo "Starting VM..."
qm start ${VMID}

echo ""
echo "VM created successfully!"
echo ""
echo "The VM will boot and cloud-init will automatically:"
echo "- Configure network settings"
echo "- Install all prerequisites (Erlang, RabbitMQ, etc.)"
echo "- Configure firewall, SSH hardening, and kernel parameters"
echo "- Download PPDM package"
echo ""
echo "Next steps:"
echo "1. Wait for the VM to boot and cloud-init to complete (approximately 3-5 minutes)"
echo "2. SSH into the VM: ssh rocky@${STATIC_IP} or ssh admin@${STATIC_IP}"
echo "3. Run the PPDM installer setup script:"
echo "   /home/admin/setup-ppdm.sh"
echo ""
echo "To monitor the VM console:"
echo "  qm terminal ${VMID}"
echo ""
echo "To check VM status:"
echo "  qm status ${VMID}"
