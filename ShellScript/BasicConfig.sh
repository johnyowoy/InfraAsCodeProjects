#!/bin/bash
# Program:
#     Configuration Environment
# History:
#     2023-04-06 JinHau, Huang
#     2024-05-05 JinHau, Huang
# 國研院國網中心自由軟體實驗室 MirrorLists
# https://free.nchc.org.tw/pmwiki/index.php?n=FSLab.MirrorLists
# https://free.nchc.org.tw/rocky/

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

function ChangeMirrorOnRocky () {
   repofile1='rocky.repo'
   repofile2='rocky-devel.repo'
   repofile3='rocky-extras.repo'
   ChangeMirrorBefore='s/^mirrorlist=/#mirrorlist=/g'
   ChangeMirrorAfter='s/\#baseurl=http:\/\/dl.rockylinux.org\/$contentdir/baseurl=https:\/\/free.nchc.org.tw\/rocky/g'

   # Backup repo
   cp /etc/yum.repos.d/${repofile1} /etc/yum.repos.d/${repofile1}.bk
   cp /etc/yum.repos.d/${repofile2} /etc/yum.repos.d/${repofile2}.bk
   cp /etc/yum.repos.d/${repofile3} /etc/yum.repos.d/${repofile3}.bk

   # Change NCHC Mirror
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile1}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile1}
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile2}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile2}
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile3}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile3}

   dnf clean all
   dnf update -y
}

function ChangeMirrorOnCentOS () {
   repofile1='CentOS-Base.repo'
   repofile2='CentOS-fasttrack.repo'
   
   ChangeMirrorBefore='s/^mirrorlist=/#mirrorlist=/g'
   ChangeMirrorAfter='s/\#baseurl=http:\/\/mirror.centos.org/baseurl=https:\/\/free.nchc.org.tw/g'

   # Backup repo
   cp /etc/yum.repos.d/${repofile1} /etc/yum.repos.d/${repofile1}.bk
   cp /etc/yum.repos.d/${repofile2} /etc/yum.repos.d/${repofile2}.bk

   # Change NCHC Mirror
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile1}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile1}
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile2}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile2}
   
   dnf clean all
   dnf update -y
}

function ConfigNetwork () {
   read -p "Please input your ipv4: " IPADDR
   sed -i '4s/BOOTPROTO=dhcp/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-eth0
   sed -i '15s/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-eth0
   sed -i '15a IPADDR='${IPADDR} /etc/sysconfig/network-scripts/ifcfg-eth0
   sed -i '16a GATEWAY=192.168.1.1' /etc/sysconfig/network-scripts/ifcfg-eth0
   sed -i '17a NETWORK=192.168.1.0' /etc/sysconfig/network-scripts/ifcfg-eth0
   sed -i '18a NETMASK=255.255.255.0' /etc/sysconfig/network-scripts/ifcfg-eth0
   sed -i '19a DNS1=1.1.1.1' /etc/sysconfig/network-scripts/ifcfg-eth0

   ifdown ifcfg-eth0
   ifup ifcfg-eth0

   echo "NetworkConfig Success."
}

function InstallingBasicPackages () {
   dnf install -y \
   net-tools \
   nmap \
   wget \
   vim \
   yum-utils \
   openssh-clients \
   openssh-server
}

function ConfigOpenSSH () {
   # Set User Public Key
   # 1. 建立 ~/.ssh 檔案，注意權限需要為 700
   if [ -d "~/.ssh" ]; then
      echo "Folder .ssh does exists"
   else
      mkdir ~/.ssh
   fi

   if stat -c "%a" ~/.ssh | grep 700 >/dev/null; then
      echo ".ssh 權限檢查OK"
   else
      chmod 700 ~/.ssh
      echo ".ssh 已設定700"
   fi
   cd ~
   read -p "請輸入您的Public Key (EX: xxx.pub): " pubkey
   if [ -f "$pubkey" ]; then
      mv $pubkey ~/.ssh
      cd .ssh
      # 2. 將公鑰檔案內的資料使用 cat 轉存到 authorized_keys 內
      cat $pubkey >> authorized_keys
      # 檔案的權限設定為644
      chmod 644 authorized_keys
      chmod 644 $pubkey
   else
      echo "File $pubkey does not exists"
   fi

   # Change sshd_config
   sed -i 's/^#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
   sed -i 's/^#PasswordAuthentication\ yes$/PasswordAuthentication no/g' /etc/ssh/sshd_config
   sed -i '21a Protocol 2' /etc/ssh/sshd_config
   systemctl restart sshd
}

function ConfigFirewall () {
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
   usermod -aG docker jinhau
   systemctl status docker
}

function InstallingKubernetes () {
   # disable firewall
   systemctl --now disable firewalld
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
}


# Main
## 更新作業
while true
do
    read -p "是否進行更新 (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        if grep '^NAME="Rocky\ Linux"$' /etc/os-release >/dev/null; then
            grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | cut -d '"' -f2
            ChangeMirrorOnRocky
        elif grep '^NAME="CentOS\ Linux"$' /etc/os-release >/dev/null; then
            grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | cut -d '"' -f2
            ChangeMirrorOnCentOS
        else
            echo '無法支援此作業系統進行設定'
            exit 1
        fi
        break  # 輸入正確時跳出循環
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break  # 輸入正確時跳出循環
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done



## 安裝基本套件
while true
do
    read -p "是否安裝基本套件 (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        InstallingBasicPackages
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done


## 設定SSH功能
while true
do
    read -p "是否設定SSH功能 (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        ConfigOpenSSH
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done


## 設定本機防火牆
while true
do
    read -p "是否設定本機防火牆功能 (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        ConfigFirewall
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done

## 安裝Docker
while true
do
    read -p "是否進行安裝Docker (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        InstallingDocker
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done

# 安裝Kubernetes
while true
do
    read -p "是否進行安裝Kunbernetes (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        InstallingKubernetes
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done

echo "Success Basic Config!"
exit 0