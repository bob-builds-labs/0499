```bash
cat > credentials << EOF
[default]
aws_access_key_id=minioadmin
aws_secret_access_key='Password123!'
EOF

oc create secret generic cloud-credentials --namespace velero-ppdm --from-file cloud=credentials
```

```bash
cat << EOF | oc apply -f -
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: openshift-dpa-test
  namespace: velero-ppdm
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

