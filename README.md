# RHEL-Docker-Portainer-Auto

This script is an **auto-installation** of Docker and Portainer on Red Hat based operating systems like **CentOS**, **Rocky Linux**, and **Alma Linux**.

## WHAT DO

### 1. Download the Installation Script

Use `wget` to download the installation script:

```bash
wget https://raw.githubusercontent.com/cfunkz/RHEL-Docker-Portainer-AutoINSTALL/main/docker-portainer.sh -O docker-portainer.sh
```

### 2. Make the Script Executable

After downloading the script, make it runnable:

```bash
chmod +x docker-portainer.sh
```

### 3. Run the Script

Run the script:

```bash
./docker-portainer.sh
```

### 4. Access Portainer

Complete Portainer setup via:

```
http://<Your_Server_IP>:9000
```
