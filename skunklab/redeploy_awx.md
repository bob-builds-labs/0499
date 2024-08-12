```bash
git pull
cd ../lab3

oc delete -f awx.yaml -n awx-operator
oc delete -f awx_sub.yaml -n awx-operator
oc delete -f awx_operatorGroup.yaml
oc delete ns awx-operator

oc create ns awx-operator
oc create -f awx_operatorGroup.yaml
oc apply -f awx_sub.yaml -n awx-operator
oc apply -f awx.yaml -n awx-operator
echo "Waiting for AWX Prod to be ready"
until [[ ! -z $(oc get pod -l "app.kubernetes.io/name=awx-prod-task" -n awx-operator) ]]; do echo "Sleeping 5 seconds";sleep 5; done

oc wait --for=condition=ready pod -l "app.kubernetes.io/name=awx-prod-task" -n awx-operator --timeout 600s
cd ../lab4
direnv allow .
direnv reload
ansible-playbook ../playbooks/awx_awx.yaml
echo  "You can now login to ${CONTROLLER_HOST} using ${CONTROLLER_USERNAME} with password ${CONTROLLER_PASSWORD}"
```
