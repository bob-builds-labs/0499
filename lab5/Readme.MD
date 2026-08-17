
oc apply -f 00-namespace.yaml
export VERSION=kvm-8.8.0.0-1241079
export DISK=/data01/artifacts/ddve-kvm-${VERSION}/ddve-${VERSION}$.qcow2


virtctl image-upload dv ddve-rootdisk \
  --namespace ddve --size=350Gi \
  --image-path=${DISK} \
  --storage-class=ocs-storagecluster-ceph-rbd-virtualization \
  --volume-mode=Block --access-mode=ReadWriteOnce --wait-secs=600

oc get datavolume ddve-rootdisk -n ddve -w