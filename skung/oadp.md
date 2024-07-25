```bash
$ cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: oadp-dpa-test
  annotations:
    workload.openshift.io/allowed: management
  labels:
    name: openshift-adp
    openshift.io/cluster-monitoring: "true"
EOF
```

```bash
cat > credentials << EOF
[default]
aws_access_key_id=minioadmin
aws_secret_access_key='Password123!'
EOF

oc create secret generic cloud-credentials --namespace openshift-dpa-test --from-file cloud=credentials
```

```bash
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: oadp-dpa-test
  namespace: openshift-dpa-test
spec:
  configuration:
    velero:
      featureFlags:
        - EnableCSI
      defaultPlugins:
        - csi 
        - openshift
        - aws
        - kubevirt
  backupLocations:
    - velero:
        config:
          profile: "default"
          region: "localstorage"
          s3Url: "http://ansible.demo.local"
          s3ForcePathStyle: "true"
        provider: aws
        credential:
          name: cloud-credentials
          key: cloud
        default: true
        objectStorage:
          bucket: oadp
          prefix: velero-dpa
EOF
```

