The webhook error means the HyperConverged CR schema you're patching does not match what CNV 4.22.20 expects. The YAML I provided was based on upstream/KubeVirt examples, not necessarily the exact HCO API exposed in your z-stream.

First, let's inspect the actual CRD fields available on your cluster:

oc explain hyperconverged.spec


and:

oc get hco kubevirt-hyperconverged -n openshift-cnv -o yaml > hco.yaml


Also check if the feature gate already exists somewhere:

oc get hco kubevirt-hyperconverged -n openshift-cnv -o yaml | grep -i feature -A10 -B10


and:

oc get kubevirt kubevirt -n openshift-cnv -o yaml | grep -i feature -A20 -B20

Most likely issue

In recent CNV releases, featureGates is often a string array rather than:

featureGates:
  - name: incrementalBackup
    state: Enabled


and therefore the webhook rejects the document.

Try determining the exact type:

oc explain hyperconverged.spec.featureGates


If it returns:

KIND:     HyperConverged
VERSION:  hco.kubevirt.io/v1beta1

FIELD: featureGates <[]string>


then the correct patch would be:

spec:
  featureGates:
    - IncrementalBackup


or:

oc patch hco kubevirt-hyperconverged \
  -n openshift-cnv \
  --type merge \
  -p '{"spec":{"featureGates":["IncrementalBackup"]}}'

Verify whether CBT is already exposed

Since you're on OpenShift Virtualization 4.22.20, I would also check whether the feature gate was renamed or hidden behind the KubeVirt CR directly:

oc get kubevirt kubevirt -n openshift-cnv -o yaml | less


Look for:

spec:
  configuration:
    developerConfiguration:
      featureGates:


or:

spec:
  configuration:
    vmStateStorageClass:


or anything mentioning:

IncrementalBackup
ChangedBlockTracking
CBT

Best next command

Please run:

oc explain hyperconverged.spec.featureGates


and paste the output. That will immediately tell us whether the webhook is rejecting the structure of featureGates or whether IncrementalBackup is not a valid gate in CNV 4.22.20.