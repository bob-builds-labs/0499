# AWX AUtomation Platform automated deployment and Configuration

## Cleanup

Go to lab3 directory

```bash
git pull
cd ../lab3
```

## Remove potential previously deployed Instances

```bash
oc delete -f awx.yaml -n awx-operator
oc delete -f awx_sub.yaml -n awx-operator
oc delete -f awx_operatorGroup.yaml
oc delete ns awx-operator

oc delete crd awxbackups.awx.ansible.com
oc delete crd awxmeshingresses.awx.ansible.com 
oc delete crd awxrestores.awx.ansible.com
oc delete crd awxs.awx.ansible.com  
```

## Deploy AWX to Openshift

```bash
oc create ns awx-operator
oc create -f awx_operatorGroup.yaml
oc apply -f awx_sub.yaml -n awx-operator
echo "Waiting for AWX Operator Pod to be deployed"

until [[ ! -z $(oc get pod -l "control-plane=controller-manager" -n awx-operator) ]]; do echo "Sleeping 5 seconds";sleep 5; done
echo "Waiting for AWX Operator to be ready"
oc wait --for=condition=ready pod -l "control-plane=controller-manager" -n awx-operator --timeout 600s
oc apply -f awx.yaml -n awx-operator
echo "Waiting for AWX Prod instance pod to be deployed"
until [[ ! -z $(oc get pod -l "app.kubernetes.io/name=awx-prod-task" -n awx-operator) ]]; do echo "Sleeping 5 seconds";sleep 5; done
echo "Waiting for AWX Prod instance to be ready"
oc wait --for=condition=ready pod -l "app.kubernetes.io/name=awx-prod-task" -n awx-operator --timeout 600s
```

## Configure AWX

Lets head over to lab4 environment

```bash
cd ../lab4
direnv allow .
```

And start populating our AWX from ansible playbook:  

```bash
ansible-playbook ../playbooks/awx_awx.yaml
echo  "You can now login to ${CONTROLLER_HOST} using ${CONTROLLER_USERNAME} with password ${CONTROLLER_PASSWORD}"
```


To use the testing branch: 

```bash
ansible-playbook ../playbooks/awx_awx.yaml --extra-vars "awx.inventory[0].scm_branch"
echo  "You can now login to ${CONTROLLER_HOST} using ${CONTROLLER_USERNAME} with password ${CONTROLLER_PASSWORD}"
``
