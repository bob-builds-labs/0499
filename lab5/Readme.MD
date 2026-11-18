# DDVE Helm Chart

Helm chart for deploying Dell DataDomain Virtual Edition (DDVE) on OpenShift Virtualization.

## Prerequisites

- OpenShift 4.x with OpenShift Virtualization installed
- KubeVirt operator installed
- CDI (Containerized Data Importer) installed (for DataVolumes)
- Multus CNI installed (for network attachment definitions)
- A storage class that supports block mode (e.g., OCS Ceph RBD virtualization)
- Multus networks pre-created in the cluster
- DDVE root disk image uploaded to OpenShift Virtualization image gallery with DataSource created

## Root Disk Upload

Before installing the chart, you must upload the DDVE root disk image to the OpenShift Virtualization image gallery and create a DataSource. Choose one of the following methods:

### Method 1: Upload via OpenShift Virtualization UI (Recommended)

1. Open the OpenShift Web Console
2. Navigate to **Compute → Boot sources**
3. Click **Add boot source**
4. Upload the DDVE image file (e.g., `ddve-8.9.0.0-1263812.qcow2`)
5. Set the size to 350Gi
6. Select the storage class (e.g., `ocs-storagecluster-ceph-rbd-virtualization`)
7. Set volume mode to **Block**
8. Click **Create**

This automatically creates both the DataVolume and DataSource in the `openshift-virtualization-os-images` namespace.

### Method 2: Upload via virtctl + Manual DataSource Creation

**Step 1: Upload the image with virtctl**

```bash
export VERSION=8.9.0.0-1263812
export DISK=/data01/artifacts/ddve-kvm-${VERSION}/ddve-${VERSION}.qcow2

virtctl image-upload dv ddve-${VERSION} \
  --namespace=openshift-virtualization-os-images \
  --image-path=${DISK} \
  --size=350Gi \
  --storage-class=ocs-storagecluster-ceph-rbd-virtualization \
  --volume-mode=block \
  --access-mode=ReadWriteOnce \
  --wait-secs=600
```

**Step 2: Create a DataSource**

Create a file named `datasource-ddve.yaml`:

```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataSource
metadata:
  name: ddve-8.9.0.0-1263812
  namespace: openshift-virtualization-os-images
spec:
  source:
    pvc:
      name: ddve-8.9.0.0-1263812
      namespace: openshift-virtualization-os-images
```

Apply it:

```bash
oc apply -f datasource-ddve.yaml
```

**Step 3: Verify the DataSource**

```bash
oc get datasource -n openshift-virtualization-os-images
```

Update the `storage.rootDisk.dataSource.name` in `values.yaml` to match the DataSource name (e.g., `ddve-8.9.0.0-1263812`).

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
    dataSource:
      name: ddve-8.9.0.0-1263812
      namespace: openshift-virtualization-os-images
    size: 350Gi
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

### VM Configuration

Configure the VM name in `values.yaml`:

```yaml
vm:
  name: ddve  # VM name - configurable per deployment
```

**Note:** The VM name is configurable per deployment, allowing you to deploy multiple DDVE instances with different names in the same namespace. Other VM settings (machineType and secureBoot) are fixed and cannot be changed.

## Starting the VM

After installation, start the VM (replace `ddve` with your configured VM name):

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
vm:
  name: ddve
licenseTier: 8TB
storage:
  datadisks:
    count: 1
    size: 250Gi
  rootDisk:
    dataSource:
      name: ddve-8.9.0.0-1263812
      namespace: openshift-virtualization-os-images
    size: 350Gi
networking:
  multusNetworks:
    - kubevirt-network-out
```

### High Capacity Configuration (8 data disks, multiple networks)

```yaml
vm:
  name: ddve
licenseTier: 96TB
storage:
  datadisks:
    count: 8
    size: 2Ti
  rootDisk:
    dataSource:
      name: ddve-8.9.0.0-1263812
      namespace: openshift-virtualization-os-images
    size: 350Gi
networking:
  multusNetworks:
    - kubevirt-network-out
    - kubevirt-network-internal
    - kubevirt-network-backup
```

### Multiple VMs in Same Namespace

To deploy multiple DDVE instances in the same namespace, use different VM names:

```bash
# First instance
helm install ddve-prod . -n ddve -f values-example-basic.yaml --set vm.name=ddve-prod

# Second instance
helm install ddve-dr . -n ddve -f values-example-multinic.yaml --set vm.name=ddve-dr
```

## Troubleshooting

### VM won't start

Check the VM instance status (replace `ddve` with your VM name):

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

Check PVC status (data disks use the VM name prefix):

```bash
oc get pvc -n ddve
oc describe pvc ddve-data-1 -n ddve
```

Check DataVolume status (replace `ddve` with your VM name):

```bash
oc get datavolume -n ddve
oc describe datavolume ddve-rootdisk -n ddve
```

Verify the DataSource exists in the image gallery:

```bash
oc get datasource -n openshift-virtualization-os-images
oc describe datasource ddve-8.9.0.0-1263812 -n openshift-virtualization-os-images
```

Verify the storage class supports block mode:

```bash
oc get storageclass
```

## Limitations

- Root disk must be uploaded to OpenShift Virtualization image gallery and a DataSource must be created before installation
- Multus networks must pre-exist in the cluster
- Data disks must use block mode (filesystem mode corrupts DDVE structures)
- CPU overcommit is not supported by Dell (requests == limits)
- Maximum 8 data disks and 8 networks
- Data disk size must be between 250Gi and 2Ti per disk
- NVRAM disk size is fixed at 10Gi and cannot be changed
- VM settings (machineType and secureBoot) are fixed and cannot be changed

## License

This Helm chart is provided as-is for deploying Dell DataDomain Virtual Edition.
