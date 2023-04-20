#!/bin/bash
# Program:
#     Configuration Environment on CentOS-Linux-7
# History:
#     2023-04-06 JinHau, Huang

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Config Network
#read -p "Please input your ipv4: " IPADDR
#sed -i '4s/BOOTPROTO=dhcp/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i '15s/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i '15a IPADDR='${IPADDR} /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i '16a GATEWAY=192.168.1.1' /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i '17a NETWORK=192.168.1.0' /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i '18a NETMASK=255.255.255.0' /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i '19a DNS1=1.1.1.1' /etc/sysconfig/network-scripts/ifcfg-eth0

#ifdown ifcfg-eth0
#ifup ifcfg-eth0

#echo "NetworkConfig Success."

# Backup repo
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bk
cp /etc/yum.repos.d/CentOS-fasttrack.repo /etc/yum.repos.d/CentOS-fasttrack.repo.bk
# cp /etc/yum.repos.d/CentOS-CR.repo /etc/yum.repos.d/CentOS-CR.repo.bk

# Change CentOS-Base.repo
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Base.repo
sed -i 's/\#baseurl=http:\/\/mirror.centos.org/baseurl=https:\/\/free.nchc.org.tw/g' /etc/yum.repos.d/CentOS-Base.repo

# Change CentOS-fasttrack.repo
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-fasttrack.repo
sed -i 's/\#baseurl=http:\/\/mirror.centos.org/baseurl=https:\/\/free.nchc.org.tw/g' /etc/yum.repos.d/CentOS-fasttrack.repo

# Change CentOS-CR.repo
# sed -i 's/http:\/\/mirror.centos.org/https:\/\/free.nchc.org.tw/g' /etc/yum.repos.d/CentOS-CR.repo

yum clean all
yum update -y

yum install -y \
net-tools \
nmap \
wget \
vim \
ntp \
yum-utils \
openssh-clients \
openssh-server

# Build ssh key
cd ~
mkdir .ssh
read -p "Please input your PublicKey name: (id_rsa_key.pub)" publickey
#publickey=
mv ${publickey} .ssh/${publickey}
cd .ssh
cat ${publickey} >> authorized_keys
chmod 600 authorized_keys
chmod 600 ${publickey}

# Change sshd_config
sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
sed -i '65s/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i '21a Protocol 2' /etc/ssh/sshd_config

systemctl restart sshd

# enable ssh 22 port
firewall-cmd --zone=public --permanent --add-port=22/tcp

systemctl restart firewalld

echo "Success Basic Config."