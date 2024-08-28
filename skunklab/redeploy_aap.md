# AAP Ansible Automation Platform automated deployment and Configuration

<<<<<<< HEAD


## Prework: 

From your vCenter, make sure ansible, as well Openshift and PowerProtect vApp are started:
![image](https://github.com/user-attachments/assets/355f1d9f-3b8b-44a4-abf6-51a239bfbd4c)

!!!! Attention, due to a recent issue with the new Submitted lab v2.5 ( Hana Instance grabbing master2 DHCP lease ), please run the following from Powershell on Launchpad before starting OpenShift:  

```Powershell
Add-DhcpServerv4Reservation -ScopeId 192.168.1.0 -IPAddress 192.168.1.108 -ClientId "005056a3bbad" -Name "openshift-72g6c-master-0.demo.local" -Description "openshift-72g6c-master-0.demo.local"
Add-DhcpServerv4Reservation -ScopeId 192.168.1.0 -IPAddress 192.168.1.111 -ClientId "005056a32d4e" -Name "openshift-72g6c-master-1.demo.local" -Description "openshift-72g6c-master-1.demo.local"
Add-DhcpServerv4Reservation -ScopeId 192.168.1.0 -IPAddress 192.168.1.104 -ClientId "005056a3729e" -Name "openshift-72g6c-master-2.demo.local" -Description "openshift-72g6c-master-2.demo.local"
```

## Important, as those Inferastructure HickUps can cause Trouble, it is recommended that you upgrade you cluster first to latest 4.14.x !!!!
From Administration, Cluster Setting, select latest 4.14 and wait .....

![image](https://github.com/user-attachments/assets/17c131ae-71bc-4f9c-9703-81e1bd4e599d)


## Deploy ( From Ansible Host )
Log into Ansible Host mRemote. If not done from previous,
Clone into 0499 if not done from earlier lab
```bash
git clone https://github.com/bob-builds-labs/0499.git ~/workspace/0499
```
=======
## Cleanup
>>>>>>> c65270dfb06ae17f97963c3d7d9f5f9d3d3307f6

Go to lab3 directory

```bash
<<<<<<< HEAD
cd ~/workspace/0499
git pull
cd ~/workspace/0499/lab3
direnv allow .
```
To use the testing Branch:

```bash
git checkout testing
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

=======
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
>>>>>>> c65270dfb06ae17f97963c3d7d9f5f9d3d3307f6

## Deploy AAP to Openshift

```bash
oc create -f aap_operatorGroup.yaml
<<<<<<< HEAD
echo "Waiting for AAP Operator Pod to be deployed"
=======
echo "Waiting for AWX Operator Pod to be deployed"
>>>>>>> c65270dfb06ae17f97963c3d7d9f5f9d3d3307f6

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

<<<<<<< HEAD
And start populating our AAP from ansible playbook:  

```bash
ansible-playbook ../playbooks/aap.yaml 
=======
And start populating our AWX from ansible playbook:  

```bash
ansible-playbook ../playbooks/awx_awx.yaml
>>>>>>> c65270dfb06ae17f97963c3d7d9f5f9d3d3307f6
echo  "You can now login to ${CONTROLLER_HOST} using ${CONTROLLER_USERNAME} with password ${CONTROLLER_PASSWORD}"
```


<<<<<<< HEAD
# Redeploy
## Remove potential previously deployed Instances

```bash
oc delete -f aap.yaml -n aap
oc delete pvc postgres-13-aap-postgres-13-0 -n aap
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



=======
```bash
oc -n kube-system describe secret $(oc -n kube-system get secret | (grep admin-user || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}'
```
>>>>>>> c65270dfb06ae17f97963c3d7d9f5f9d3d3307f6
