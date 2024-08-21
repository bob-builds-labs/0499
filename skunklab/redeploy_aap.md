# AAP Ansible Automation Platform automated deployment and Configuration

## Cleanup

Go to lab3 directory

```bash
git pull
cd ../lab3
```

## Remove potential previously deployed Instances

```bash
oc delete -f aap.yaml -n aap
oc delete pvc  postgres-13-aap-postgres-13-0 -n aap
oc delete -f aap_operatorGroup.yaml
oc delete ns aap

oc delete crd ansiblecredentials.tower.ansible.com
oc delete crd ansibleinstancegroups.tower.ansible.com
oc delete crd ansibleinventories.tower.ansible.com
oc delete crd ansiblejobs.tower.ansible.com
oc delete crd ansiblelightspeeds.lightspeed.ansible.com
oc delete crd ansibleprojects.tower.ansible.com
oc delete crd ansibleschedules.tower.ansible.com
oc delete crd ansibleworkflows.tower.ansible.com
oc delete crd automationcontrollerbackups.automationcontroller.ansible.com
oc delete crd automationcontrollerrestores.automationcontroller.ansible.com
oc delete crd automationcontrollers.automationcontroller.ansible.com
oc delete crd automationhubbackups.automationhub.ansible.com
oc delete crd automationhubrestores.automationhub.ansible.com
oc delete crd automationhubs.automationhub.ansible.com
oc delete crd edabackups.eda.ansible.com
oc delete crd edarestores.eda.ansible.com
oc delete crd edas.eda.ansible.com 
oc delete crd jobtemplates.tower.ansible.com
oc delete crd workflowtemplates.tower.ansible.com 
```

## Deploy AAP to Openshift

```bash
oc create -f aap_operatorGroup.yaml
echo "Waiting for AWX Operator Pod to be deployed"

until [[ ! -z $(oc get pod -l "control-plane=controller-manager" -n aap) ]]; do echo "Sleeping 5 seconds";sleep 5; done
echo "Waiting for AAP Operator to be ready"
oc wait --for=condition=ready pod -l "control-plane=controller-manager" -n aap --timeout 600s
oc apply -f aap.yaml -n aap
echo "Waiting for AAP Controller Prod instance pod to be deployed"
until [[ ! -z $(oc get pod -l "app.kubernetes.io/name=aap-task" -n aap) ]]; do echo "Sleeping 5 seconds";sleep 5; done
echo "Waiting for AAP Controller instance to be ready"
oc wait --for=condition=ready pod -l "app.kubernetes.io/name=aap-task" -n aap --timeout 600s
```

## Configure AAP

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
