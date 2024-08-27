# AAP Ansible Automation Platform automated deployment and Configuration



## Prework: 

From your vCenter, make sure ansible, as well Openshift and PowerProtect vApp are started:
![image](https://github.com/user-attachments/assets/355f1d9f-3b8b-44a4-abf6-51a239bfbd4c)



## Deploy ( From Ansible Host )
Log into Ansible Host mRemote. If not done from previous,
Clone into 0499 if not done from earlier lab
```bash
git clone https://github.com/bob-builds-labs/0499.git ~/workspace/0499
```

Go to lab3 directory

```bash
cd ~/workspace/0499
git pull
cd ~/workspace/0499/lab3
direnv allow .
```
If OpenShift is freshly started, make sure to approve  csr´s as in lab  [03.0](https://github.com/bob-builds-labs/bob-builds-labs.github.io/blob/main/docs/03.0_prepare_openshift_lab.md)
This can take up to 15 Minutes and multiple CSR´s apprals for the Cluster to reconcile
```bash
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve
```

rember to run this multiple times, until you [Openshift Console](https://console-openshift-console.apps.openshift.demo.local) is working and 
```bash
oc get nodes
```
shows all nodes ready


## Deploy AAP to Openshift

```bash
oc create -f aap_operatorGroup.yaml
echo "Waiting for AAP Operator Pod to be deployed"

until [[ ! -z $(oc get pod -l "control-plane=controller-manager" -n aap) ]]; do echo "Sleeping 5 seconds";sleep 5; done
echo "Waiting for AAP Operator to be ready"
oc wait --for=condition=ready pod -l "control-plane=controller-manager" -n aap --timeout 600s
oc apply -f aap.yaml -n aap
echo "Waiting for AAP Controller Prod instance pod to be deployed"
until [[ ! -z $(oc get pod -l "app.kubernetes.io/name=aap-task" -n aap) ]]; do echo "Sleeping 5 seconds";sleep 5; done
echo "Waiting for AAP Controller instance to be ready"
oc wait --for=condition=ready pod -l "app.kubernetes.io/name=aap-task" -n aap --timeout 600s
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



## Configure AAP

Lets head over to lab4 environment

```bash
cd ../lab4
direnv allow .
```

And start populating our AAP from ansible playbook:  

```bash
ansible-playbook ../playbooks/aap.yaml 
echo  "You can now login to ${CONTROLLER_HOST} using ${CONTROLLER_USERNAME} with password ${CONTROLLER_PASSWORD}"
```
