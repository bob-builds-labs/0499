```bash
docker-compose -f docker-compose-monitor.yml up -d
```



```bash
podman run -it --rm --pull=always  -v /home/admin/data01:/data01 \
  -e PPDM_SERVER=ppdm-1.demo.local \
  -e PPDM_USERNAME=admin \
  -e PPDM_PASSWORD=Password123! \
  -e PPDM_PORT=8443 -e PPDM_INSECURE_SKIP_VERIFY=true \
  quay.io/delldps/ppdm-cli:20.1.0.0-amd64
```



```bash
podman run -it --rm --pull=always  -v /home/admin/data01:/data01 \
  --env-file .env \
  quay.io/delldps/ppdm-cli:20.1.0.0-amd64
```



```bash
DD_SYSTEM_ID=d1656af3-df78-4194-a7d9-2c44174f3652
ppdm-cli protection-policies create nativeedge-virtual-machine --name "NativeEdge-Test-Policy" --schedule DAILY --retention 7 --dd-system-id ${DD_SYSTEM_ID}
```


```bash
DD_SYSTEM_ID=d1656af3-df78-4194-a7d9-2c44174f3652
ppdm-cli protection-policies create nutanix-virtual-machine --name "Nutanix-Test-Policy" --schedule DAILY --retention 7 --dd-system-id ${DD_SYSTEM_ID}
```

```bash
DD_SYSTEM_ID=d1656af3-df78-4194-a7d9-2c44174f3652
ppdm-cli protection-policies create hyperv-virtual-machine --name "HyperV-Test-Policy" --schedule DAILY --retention 7 --dd-system-id --dd-system-id ${DD_SYSTEM_ID}
```

```bash

```