#!/bin/bash
# Create Rocky Linux template VM with cloud-init configuration
# This script creates a template VM that can be cloned for PPDM proxy deployments

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

echo "Creating Rocky Linux template VM..."
echo "Template VMID: ${TEMPLATE_VMID}"
echo "Template Name: ${TEMPLATE_NAME}"
echo "Storage: ${STORAGE}"
echo "Source Storage: ${CLOUD_IMAGE_STORAGE}"
echo "Source Path: ${STORAGE_PATH}"
echo ""

# Check if template already exists
if qm status ${TEMPLATE_VMID} &>/dev/null; then
    echo "Template VM ${TEMPLATE_VMID} already exists."
    echo "To recreate, first delete it with: qm destroy ${TEMPLATE_VMID}"
    exit 1
fi

# Check if qcow2 exists in ISO storage
if [ ! -f "${STORAGE_PATH}/${CLOUD_IMAGE_PATH}" ]; then
    echo "Cloud image ${CLOUD_IMAGE_PATH} not found in ${CLOUD_IMAGE_STORAGE} storage."
    echo ""
    echo "Searching for Rocky Linux qcow2 files..."
    ROCKY_IMAGE=$(ls ${STORAGE_PATH}/import/Rocky-9-GenericCloud-LVM*.qcow2 2>/dev/null | head -1)

    if [ -n "$ROCKY_IMAGE" ]; then
        echo "Found: $ROCKY_IMAGE"
        echo "Using this image instead."
        CLOUD_IMAGE_PATH="${ROCKY_IMAGE#${STORAGE_PATH}/}"
    else
        echo "No Rocky Linux cloud image found locally."
        echo "Downloading from Rocky Linux official mirror..."
        echo "URL: ${ROCKY_IMAGE_URL}"
        echo ""

        mkdir -p "${STORAGE_PATH}/import"
        if curl -L -o "${STORAGE_PATH}/${CLOUD_IMAGE_PATH}" "${ROCKY_IMAGE_URL}"; then
            echo "Download complete: ${STORAGE_PATH}/${CLOUD_IMAGE_PATH}"
        else
            echo "Error: Failed to download Rocky Linux image."
            echo ""
            echo "Please download manually and place in ${STORAGE_PATH}/import/:"
            echo "  curl -L -o ${STORAGE_PATH}/${CLOUD_IMAGE_PATH} ${ROCKY_IMAGE_URL}"
            echo ""
            exit 1
        fi
    fi
fi

# Create template VM
echo "Creating template VM ${TEMPLATE_VMID}..."
qm create ${TEMPLATE_VMID} \
  --name "${TEMPLATE_NAME}" \
  --ostype l26 \
  --machine q35 \
  --bios seabios \
  --memory 2048 \
  --cores 2 \
  --sockets 1 \
  --cpu host \
  --scsihw virtio-scsi-single \
  --net0 virtio,bridge=${BRIDGE} \
  --onboot 0

# Import cloud image as OS disk
echo "Importing disk from ${STORAGE_PATH}/${CLOUD_IMAGE_PATH}..."
IMPORT_OUTPUT=$(qm importdisk ${TEMPLATE_VMID} ${STORAGE_PATH}/${CLOUD_IMAGE_PATH} ${STORAGE} --format ${DISK_FORMAT} 2>&1)
echo "$IMPORT_OUTPUT"

# Extract the disk name from import output
DISK_NAME=$(echo "$IMPORT_OUTPUT" | grep -oP "imported disk '\K[^']+" || echo "${STORAGE}:vm-${TEMPLATE_VMID}-disk-0")

# Attach the imported disk
qm set ${TEMPLATE_VMID} \
  --scsi0 ${DISK_NAME}

# Resize the disk
qm resize ${TEMPLATE_VMID} scsi0 60G

# Convert to template
qm template ${TEMPLATE_VMID}

echo ""
echo "Template VM ${TEMPLATE_VMID} created successfully!"
echo ""
echo "The template is ready for cloning."
echo "Run ./vm-create-cloudinit.sh to create PPDM proxy VMs from this template."
