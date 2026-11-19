Installing Proxmox Proxy Servers via Cloudinit

## Copy cloud-init directory to Proxmox server
```bash
scp -r cloud-init/ root@proxmox1.demo.local:/home/cloud-init
```


## run the temoplate creation script
```bash
ssh root@proxmox1.demo.local
cd /home/cloud-init
./create-template.sh proxproxy1.env
```

once template is created, run vm creation script
```bash
ssh root@proxmox1.demo.local
cd /home/cloud-init
./vm-create-cloudinit.sh proxproxy1.env
```


ssh into the proxy node and check the configuration
```bash
ssh root@proxproxy1.demo.local

```

