# DDVE Helm Chart

Helm chart for deploying Dell DataDomain Virtual Edition (DDVE) on OpenShift Virtualization.

## Prerequisites

- OpenShift 4.x with OpenShift Virtualization installed
- KubeVirt operator installed
- Multus CNI installed (for network attachment definitions)
- A storage class that supports block mode (e.g., OCS Ceph RBD virtualization)
- Multus networks pre-created in the cluster
- DDVE root disk image uploaded to OpenShift Virtualization image gallery

## Root Disk Upload

Before installing the chart, you must upload the DDVE root disk image to the OpenShift Virtualization image gallery:

```bash
export VERSION=8.8.0.0-1241079
export DISK=/data01/artifacts/ddve-kvm-${VERSION}/ddve-${VERSION}.qcow2

virtctl image-upload dv ddve-${VERSION} \
  --namespace=openshift-virtualization-os-images \
  --image-path=${DISK} \
  --storage-class=ocs-storagecluster-ceph-rbd-virtualization \
  --volume-mode=block \
  --access-mode=ReadWriteOnce \
  --wait-secs=600
```

Update the `storage.rootDisk.bootSource.name` in `values.yaml` to match the uploaded image name.

## Installation

### Install the chart

```bash
helm install ddve . -n ddve --create-namespace
```

### Install with custom values

```bash
helm install ddve . -n ddve --create-namespace -f values-custom.yaml
```

### Upgrade the chart

```bash
helm upgrade ddve . -n ddve -f values-custom.yaml
```

### Uninstall the chart

```bash
helm uninstall ddve -n ddve
```

## Configuration

### License Tiers

The chart supports predefined license tiers with corresponding CPU and memory configurations:

| License Tier | vCPU | Memory |
|--------------|------|--------|
| 8TB          | 2    | 8GB    |
| 16TB         | 4    | 16GB   |
| 32TB         | 4    | 24GB   |
| 48TB         | 4    | 36GB   |
| 64TB         | 8    | 48GB   |
| 96TB         | 8    | 64GB   |

Set the license tier in `values.yaml`:

```yaml
licenseTier: 8TB  # Options: 8TB, 16TB, 32TB, 48TB, 64TB, 96TB
```

### Storage Configuration

Configure storage in `values.yaml`:

```yaml
storage:
  storageClass: ocs-storagecluster-ceph-rbd-virtualization
  datadisks:
    count: 1  # 1-8 disks
    size: 250Gi  # 250Gi-2Ti per disk
  rootDisk:
    bootSource:
      name: ddve-8.8.0.0-1241079
      namespace: openshift-virtualization-os-images
```

**Important:**
- NVRAM disk is fixed at 10Gi and cannot be changed
- NVRAM and data disks must use block mode (not filesystem mode)
- Data disk size must be between 250Gi and 2Ti per disk
- You can configure 1-8 data disks

### Network Configuration

Configure Multus networks in `values.yaml`. The chart will automatically:
- Create bridge interfaces for each network
- Add namespace labels/annotations for CUDN access

```yaml
networking:
  mtu: 1500
  multusNetworks:
    - kubevirt-network-out  # Required - at least one network
    - another-network       # Optional - up to 8 total
```

**Important:**
- Multus networks must pre-exist in the cluster
- At least one network is required
- Maximum 8 networks supported
- The chart adds namespace labels automatically for CUDN access

### Namespace Configuration

The chart can create a namespace or use an existing one:

```yaml
namespace:
  name: ddve
  create: true  # Set to false to use an existing namespace
```

If using an existing namespace, ensure it has the proper labels for CUDN network access.

**Note:** VM settings (machineType and secureBoot) are fixed and cannot be changed.

## Starting the VM

After installation, start the VM:

```bash
virtctl start ddve -n ddve
```

Connect to the VM console:

```bash
virtctl console ddve -n ddve
```

View VM status:

```bash
oc get vm ddve -n ddve
oc get vmi ddve -n ddve
```

## Example Configurations

### Basic Configuration (1 data disk, 1 network)

```yaml
licenseTier: 8TB
storage:
  datadisks:
    count: 1
    size: 250Gi
networking:
  multusNetworks:
    - kubevirt-network-out
```

### High Capacity Configuration (8 data disks, multiple networks)

```yaml
licenseTier: 96TB
storage:
  datadisks:
    count: 8
    size: 2Ti
networking:
  multusNetworks:
    - kubevirt-network-out
    - kubevirt-network-internal
    - kubevirt-network-backup
```

## Troubleshooting

### VM won't start

Check the VM instance status:

```bash
oc get vmi ddve -n ddve
oc describe vmi ddve -n ddve
```

Check the virt-controller logs:

```bash
oc logs -n openshift-virtualization deployment/virt-controller
```

### Network issues

Verify the namespace has the correct labels for CUDN access:

```bash
oc get namespace ddve -o yaml
```

Verify the multus networks exist:

```bash
oc get network-attachment-definition -A
```

### Storage issues

Check PVC status:

```bash
oc get pvc -n ddve
oc describe pvc ddve-data-1 -n ddve
```

Verify the storage class supports block mode:

```bash
oc get storageclass
```

## Limitations

- Root disk must be uploaded to OpenShift Virtualization image gallery before installation
- Multus networks must pre-exist in the cluster
- Data disks must use block mode (filesystem mode corrupts DDVE structures)
- CPU overcommit is not supported by Dell (requests == limits)
- Maximum 8 data disks and 8 networks
- Data disk size must be between 250Gi and 2Ti per disk
- NVRAM disk size is fixed at 10Gi and cannot be changed
- VM settings (machineType and secureBoot) are fixed and cannot be changed

## License

This Helm chart is provided as-is for deploying Dell DataDomain Virtual Edition.
