+++
title = "Kubernetes on Ubuntu 20.04"
slug = "k8sonubuntu"
date = 2020-11-23T00:35:15-04:00
tags = ["kubernetes","ubuntu"]
category = ["tech"]
featured_image = ""
description = "Kubernetes on Ubuntu 20.04"
draft = "false"
+++

# Install K8s

```bash
# remove docker if installed via snap 
sudo snap remove docker

sudo apt install -y docker.io
sudo apt install -y apt-transport-https curl

# switch to systemd
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

## Enable Docker Service
sudo systemctl enable docker.service

sudo systemctl stop docker
sudo systemctl start docker

## Disable Swap
sudo swapoff -a
sudo sed -i '$ d' /etc/fstab


## Add Kubernetes signing key, as of this writing xenial is latest
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

## install kubernetes
sudo apt install -y kubeadm=1.19.5-00 kubelet=1.19.5-00 kubectl=1.19.5-00 kubernetes-cni=0.8.7-00
sudo apt-mark hold kubeadm=1.19.5-00 kubelet=1.19.5-00 kubectl=1.19.5-00 kubernetes-cni=0.8.7-00
sudo apt-mark showhold
## only on master
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

   ## -- or on worker -- ##

## use join command as printed by init
sudo kubeadm join 192.168.1.44:6443 --token 8n8r48.7n4wdkt42nw4j436 \
    --discovery-token-ca-cert-hash sha256:89b472970d7a3332559b06a01ddbd1f341bc8e4261ad98aa07878dda3ba0e411

###### stop here if this is a worker node

## setup local kube config

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## deploy pod networking
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml    

## install metric server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
```

## POST Setup

### install MetalLB
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

```
#### Create MetalLB config
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.1.200-192.168.1.220
```


### nfs provisioner

#### install nfs client on all nodes with
```bash
sudo apt-get install -y nfs-common
```

#### Install Provisioner
```bash
sudo snap install helm --classic
helm repo add stable https://charts.helm.sh/stable

helm repo update

helm install nfs stable/nfs-client-provisioner --set nfs.server=192.168.1.87 --set nfs.path=/mnt/nfs_share --set storageClass.defaultClass=true
```

### concourse

```bash
helm repo add concourse https://concourse-charts.storage.googleapis.com/

helm install concourse  concourse/concourse

kubectl expose deployment concourse-web --target-port=8080 --port=80 --type=LoadBalancer --name lb-concourse

helm install concourse concourse/concourse --set web.service.api.type=LoadBalancer  --set concourse.web.externalUrl=http://concourse.ellin.net --set concourse.web.bindPort=80 --set worker.persistence.enabled=false   --set postgresql.persistence.enabled=false 
```

### ArgoCD

```bash
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# get the password
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

# Misc Linux options

## resize partition

You can’t resize a mounted filesystem with parted and resize2fs won’t resize the underlying partition. The workaround is a bit tricky and you have to be careful to keep the start cylinder the same when doing this. What you do is, in fdisk you delete the partition and recreate it with a larger size making sure you keep the start location (cylinder) the same. The example below illustrates this:
```bash
[root@temeria ~] fdisk /dev/sda
```
expand the partition in fdisk by deleting the partition, create a new one using the same starting cylinder,

Pertinent information marked with <------

```bash
WARNING: DOS-compatible mode is deprecated. It’s strongly recommended to switch off the mode (command ‘c’) and change display units to sectors (command ‘u’).
Command (m for help): p
Disk /dev/sda: 25.8 GB, 25769803776 bytes
255 heads, 63 sectors/track, 3133 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00073409
Device Boot Start End Blocks Id System
/dev/sda1 * 1 39 307200 83 Linux <------ Starts at 39
Partition 1 does not end on cylinder boundary.
/dev/sda2 39 2097 16534528 83 Linux
Command (m for help): d <------  delete the original partition
Partition number (1-4): 2
Command (m for help): n <------ new partition
Command action
e extended
p primary partition (1-4)
p <------ primary
Partition number (1-4): 2 <------ usually 2
First cylinder (39-3133, default 39):
Using default value 39  <------ Starting positiono of or
Last cylinder, +cylinders or +size{K,M,G} (39-3133, default 3133):
Using default value 3133  <------ default is full disk
Command (m for help): p
Disk /dev/sda: 25.8 GB, 25769803776 bytes
255 heads, 63 sectors/track, 3133 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00073409
Device Boot Start End Blocks Id System
/dev/sda1 * 1 39 307200 83 Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2 39 3133 24857598+ 83 Linux
Command (m for help): w <------ write changes
The partition table has been altered! Calling ioctl() to re-read partition table. WARNING: Re-reading the partition table failed with error 16: Device or resource busy. The kernel still uses the old table. The new table will be used at the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.
```
Reboot the system to ensure the partition table is reread.

## Resize the filesystem
This is perhaps the simplest step.
Simply execute the resize2fs command with your partition as an argument.
```bash
[root@temeria ~] resize2fs /dev/sda2
```

## Reset IpTables after kubeadm reset

If you run kubeadm reset on the master you may need to reset iptables before running kubeadm again.

```bash
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```


## Enable system trust on Ubuntu
```bash
mkdir /usr/local/share/ca-certificates/k8s

sudo cp file.crt /usr/local/share/ca-certificates/k8s

sudo update-ca-certificates
```

file copeied to /etc/ssl/certs

## Recreating the Join Command

To rebuild join command

```bash
jeff@kube-0:~$ kubeadm token generate

jeff@kube-0:~$ kubeadm token create <token> --print-join-command --ttl=0
```

## retrieve cert 

```bash
openssl x509 -in /etc/kubernetes/pki/ca.crt -pubkey -noout |
openssl pkey -pubin -outform DER |
openssl dgst -sha256
```

## nfs client
```bash
sudo apt-get install nfs-common
```

# upgrade K8s

Do on master,  then repeat on each worker

1. Upgrade Kubeadm
  ```bash
  apt-mark unhold kubeadm && \
  apt-get update && apt-get install -y kubeadm=1.19.3-00 && \
  apt-mark hold kubeadm
  ```
2. Drain the Node
  ```bash
  kubectl drain kube-2 --ignore-daemonsets
  ```

3. Upgrade the Node.
  ```bash
  sudo kubeadm upgrade node
  ```
4. Upgrade the Kubelet
  
  ```bash
  apt-mark unhold kubelet kubectl && \
  apt-get update && apt-get install -y kubelet=1.19.3-00 kubectl=1.19.3-00 && \
  apt-mark hold kubelet kubectl

  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  ```
4. Uncorden the node
```bash
  kubectl uncordon kube-2
```
