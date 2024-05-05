#!/bin/bash
# Program:
#     Configuration Docker and Kubernetes Environment on CentOS-Linux-7
# History:
#     2023-05-15 JinHau, Huang

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

swapoff -a

systemctl stop ufw
systemctl disable ufw

# Set up the repository
# 1. Update the apt package index and install packages to allow apt to use a repository over HTTPS:
apt-get install -y gnupg apt-transport-https ca-certificates curl
# 2. Add Docker’s official GPG key
chmod 755 /etc/apt/keyrings
# install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# 3. Use the following command to set up the repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
# 1.Update the apt package index
apt-get update
# 2.Install Docker Engine, containerd, and Docker Compose
DOCKER_VERSION_STRING=5:20.10.9~3-0~ubuntu-focal
apt-get install docker-ce=$DOCKER_VERSION_STRING docker-ce-cli=$DOCKER_VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
# 3.Verify that the Docker Engine installation is successful
systemctl start docker
systemctl enable docker

# Manage Docker as a non-root user
DOCKER_USER=jinhau
usermod -aG docker $DOCKER_USER

# Update the apt package index and install packages needed to use the Kubernetes apt repository
apt-get update
mkdir /etc/apt/keyrings
# Download the Google Cloud public signing key
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Configuring a cgroup driver
# Both the container runtime and the kubelet have a property called "cgroup driver", which is important for the management of cgroups on Linux machines.

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Changing docker cgroups from cgroupsfs to systemd
cat <<EOF | tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2"
}
EOF
systemctl restart docker
docker info | grep "Cgroup Driver:"

# K8s INIT
# root環境底下操作
#kubeadm init --apiserver-advertise-address=192.168.1.3 --pod-network-cidr=10.244.0.0/16

# To start using your cluster, you need to run the following as a regular user
#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

# https://github.com/containerd/containerd/issues/8139

# Deploying CNI flannel manually
#kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml

