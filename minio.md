# minio 


```bash   
sudo mkdir /home/minio
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20240628090649.0.0_amd64.deb -O minio.deb
sudo dpkg -i minio.deb
sudo groupadd -r minio-user
sudo useradd -M -r -g minio-user minio-user
sudo chown minio-user:minio-user /home/minio
```

```bash
cat <<EOF > /etc/default/minio

# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.# Omit to use the default values 'minioadmin:minioadmin'.# MinIO recommends setting non-default values as a best practice, regardless of environment
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=Password123!
# MINIO_VOLUMES sets the storage volume or path to use for the MinIO server.
MINIO_VOLUMES=/home/minio
MINIO_OPTS="--console-address :9090"

EOF  
 

sudo systemctl start minio.service
sudo systemctl status minio.service
journalctl -f -u minio.service
``` 
python3 -m pip install botocore
