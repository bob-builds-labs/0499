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
