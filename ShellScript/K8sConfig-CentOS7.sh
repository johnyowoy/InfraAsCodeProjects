#!/bin/bash
# Program:
#     Configuration Docker and Kubernetes Environment on CentOS-Linux-7
# History:
#   2023-04-06 JinHau, Huang
#   2024-07-29 JinHau, Huang

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# ======================================
# Prepare Hostname, Firewall and SELinux
# ======================================

# 設定Hostname
while true
do
    read -p "是否設定Hostname (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        read -p "請輸入Hostname: " hostname
        hostnamectl set-hostname ${hostname}
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done

read -p "請輸入Master node Hostname: " hostname01
read -p "請輸入Master node IP: " ip01
read -p "請輸入Worker node Hostname: " hostname02
read -p "請輸入Worker node IP: " ip02
read -p "請輸入Worker node Hostname: " hostname03
read -p "請輸入Worker node IP: " ip03
# 設定/etc/hosts
    cat <<EOF >> /etc/hosts
${ip01} ${hostname01}
${ip02} ${hostname02}
${ip03} ${hostname03}
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Disable firewall
systemctl stop firewalld
systemctl disable firewalld

# Set up the repository
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine, containerd, and Docker Compose
# To install the latest version
version=20.10.9
echo ${version}
yum install -y docker-ce-${version} docker-ce-cli-${version} containerd.io docker-ce-rootless-extras-${version}

usermod -aG docker jinhau

# Start Docker
systemctl start docker
systemctl status docker

# disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Container Runtimes
# Install and configure prerequisites
cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Verify that the br_netfilter, overlay modules are loaded by running below instructions
lsmod | grep br_netfilter
lsmod | grep overlay

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# ======================================
# Setup the Kubernetes repo
# ======================================

# Distributions using rpm packages
# Add the Kubernetes repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# p.s version 1.23.6-00
version=1.23.6-0
echo ${version}

yum install -y kubelet-${version} kubeadm-${version} kubectl-${version} --disableexcludes=kubernetes

systemctl enable --now kubelet

# Changing docker cgroups from cgroupsfs to systemd
cat <<EOF > /etc/docker/daemon.json
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

docker info | grep "Cgroup Driver:" >> ~/mydocker.log