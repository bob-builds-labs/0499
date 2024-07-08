# add minio to ansible host 

to add nminio to the ansible host, follow below instructions

as root:
```bash   
mkdir /home/minio
https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20240628090649.0.0_amd64.deb -O minio.deb
dpkg -i minio.deb
groupadd -r minio-user
useradd -M -r -g minio-user minio-user
chown minio-user:minio-user /home/minio
cat <<EOF > /etc/default/minio
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=Password123!
MINIO_VOLUMES=/home/minio
MINIO_OPTS="--console-address :9090"

EOF

sudo systemctl start minio.service
sudo systemctl status minio.service
journalctl -f -u minio.service
```

As admin:
```bash
python3 -m pip install botocore
```
