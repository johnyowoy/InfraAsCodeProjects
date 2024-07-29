#!/bin/bash
# Program
#  1.安裝Container Runtime
#  2.安裝Kubernetes
#  3.建置與設定基本環境
# History
#  2024-07-14 JINHAU, HUANG
#  2024-07-29 JINHAU, HUANG

# Distributions using rpm packages
# Add the CRI-O and Kubernetes repository
function SettingRepo () {
   cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/rpm/repodata/repomd.xml.key
EOF
   cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/repodata/repomd.xml.key
EOF

   dnf check-update
}

# Set firewall rules on ports
function SettingFirewall () {
   # Enabled Firewall port 6443, 10250
   firewall-cmd --add-port=6443/tcp --permanent
   firewall-cmd --add-port=10250/tcp --permanent
   firewall-cmd --reload
}

function ConfigK8S () {
   # disable swap
   swapoff -a
   sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

   cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
   modprobe br_netfilter

   # sysctl params required by setup, params persist across reboots
   cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

   # Apply sysctl params without reboot
   sudo sysctl --system

   # Set SELinux in permissive mode (effectively disabling it)
   sudo setenforce 0
   sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

}

function InstallPackage () {
   dnf install -y container-selinux cri-o kubelet kubeadm kubectl
   systemctl start crio.service
}

function Verify () {
   # Verify that the br_netfilter, overlay modules are loaded by running below instructions
   lsmod | grep br_netfilter >> K8sConfig.log
}

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# ==========
# == Main ==
# ==========
# Setting ENV
export KUBERNETES_VERSION=v1.30
export CRIO_VERSION=v1.30

SettingRepo
SettingFirewall
ConfigK8S
InstallPackage

