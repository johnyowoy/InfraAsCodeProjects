#!/bin/bash
# Program:
#     Configuration Environment on Rocky-Linux
# History:
#     2023-04-06 JinHau, Huang
# 國研院國網中心自由軟體實驗室 MirrorLists
# https://free.nchc.org.tw/pmwiki/index.php?n=FSLab.MirrorLists
# https://free.nchc.org.tw/rocky/

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

function ChangeMirror () {
   rockyrepo='rocky.repo'
   rockydevelrepo='rocky-devel.repo'
   rockyextrasrepo='rocky-extras.repo'
   RockyMirrorBefore='s/^mirrorlist=/#mirrorlist=/g'
   RockyMirrorAfter='s/\#baseurl=http:\/\/dl.rockylinux.org\/$contentdir/baseurl=https:\/\/free.nchc.org.tw\/rocky/g'

   # Backup repo
   cp /etc/yum.repos.d/${rockyrepo} /etc/yum.repos.d/${rockyrepo}.bk
   cp /etc/yum.repos.d/${rockydevelrepo} /etc/yum.repos.d/${rockydevelrepo}.bk
   cp /etc/yum.repos.d/${rockyextrasrepo} /etc/yum.repos.d/${rockyextrasrepo}.bk

   # Change NCHC Mirror
   sed -i ${RockyMirrorBefore} /etc/yum.repos.d/${rockyrepo}
   sed -i ${RockyMirrorAfter} /etc/yum.repos.d/${rockyrepo}
   sed -i ${RockyMirrorBefore} /etc/yum.repos.d/${rockydevelrepo}
   sed -i ${RockyMirrorAfter} /etc/yum.repos.d/${rockydevelrepo}
   sed -i ${RockyMirrorBefore} /etc/yum.repos.d/${rockyextrasrepo}
   sed -i ${RockyMirrorAfter} /etc/yum.repos.d/${rockyextrasrepo}

   dnf clean all
   dnf update -y
}

function InstallingPackages () {
   dnf install -y \
   net-tools \
   nmap \
   wget \
   vim \
   yum-utils \
   openssh-clients \
   openssh-server
}

function ConfiguringOpenSSH () {
   # Build ssh key
   #cd ~
   #mkdir .ssh
   #read -p "Please input your PublicKey name: (id_rsa_key.pub)" publickey
   #publickey=
   #mv ${publickey} .ssh/${publickey}
   #cd .ssh
   #cat ${publickey} >> authorized_keys
   #chmod 600 authorized_keys
   #chmod 600 ${publickey}

   # Change sshd_config
   #sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
   #sed -i '65s/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
   sed -i '21a Protocol 2' /etc/ssh/sshd_config
   systemctl restart sshd
}

function ConfiguringFirewalld () {
# enable ssh 22 port
   firewall-cmd --zone=public --permanent --add-port=22/tcp
   systemctl restart firewalld
}

function InstallingDocker () {
   dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   # Install Docker Engine, containerd, and Docker Compose
   # To install the latest version
   sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

   # Start and enable the systemd docker service (dockerd)
   sudo systemctl --now enable docker
   systemctl status docker
}

function InstallingKubernetes () {
   # disable firewall
   systemctl stop firewalld
   systemctl disable firewalld
   # disable swap
   swapoff -a
   sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

   # Container Runtimes
   # Install and configure prerequisites
   cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

   sudo modprobe overlay
   sudo modprobe br_netfilter

   # sysctl params required by setup, params persist across reboots
   cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
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

   # Installing kubeadm, kubelet and kubectl
   cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
   dnf update -y
   # Set SELinux in permissive mode (effectively disabling it)
   sudo setenforce 0
   sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

   yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

   systemctl enable --now kubelet

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

   usermod -aG docker jinhau
}


# Main
ChangeMirror
InstallingPackages
ConfiguringOpenSSH
ConfiguringFirewalld
InstallingDocker
InstallingKubernetes
echo "Success Basic Config."