#!/bin/bash
# Program
#   Linux, Apache, PHP, Microsoft Drivers for PHP for SQL Server
# History
#   2021-04-01 JinHau, Huang First release

# httpd configuration
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Firewalld Configuration
# enable httpd 80 port
firewall-cmd --zone=public --permanent --add-port=80/tcp
systemctl restart firewalld

# -- git Congiguration --
# groupinstall 安裝一整組的套件群組
cd ~
yum groupinstall -y "Development Tools"
yum install -y gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.30.1.tar.gz
tar -xvf git-2.30.1.tar.gz
cd git-2.30.1
make configure
./configure --prefix=/usr/local
make install
read -p "Please input your git user name: " gitusername
read -p "Please input your git user email: " gituseremail
git config --global user.name ${gitusername}
git config --global user.email ${gituseremail}

# yum install -y mariadb-server mariadb-client

cd ~

# php
# Download Remi Repository
wget -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Download EPEL Repository
wget -q https://rpms.remirepo.net/enterprise/remi-release-7.rpm 

# 安裝 EPEL Repository
rpm -Uvh epel-release-latest-7.noarch.rpm

# 安裝 Remi Repository:
rpm -Uvh remi-release-7.rpm

# Check epel-release version
rpm -q epel-release

yum install -y yum-utils

# disable PHP 5.4 version
sudo yum-config-manager --disable remi-php54

# Install PHP 7.0 version
sudo yum-config-manager --enable remi-php70

yum -y install php php-cli php-fpm php-gd php-mysql php-ldap php-zip php-devel php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-fileinfo

cd /var/www/html/
# Install PHPMailer Packetage
wget https://github.com/PHPMailer/PHPMailer/archive/refs/tags/v5.2.26.tar.gz
tar -xvf v5.2.26.tar.gz
rm v5.2.26.tar.gz
# Intsall PHPExcel Packetage
wget https://github.com/PHPOffice/PHPExcel/archive/refs/tags/1.8.0.tar.gz
tar -xvf 1.8.0.tar.gz
rm 1.8.0.tar.gz

# Microsoft Drivers for PHP for SQL Server on Linux
# Red Hat Enterprise Server 7 and Oracle Linux 7
cd ~
wget https://packages.microsoft.com/config/rhel/7/prod.repo
cp prod.repo /etc/yum.repos.d/mssql-release.repo
yum remove unixODBC-utf16 unixODBC-utf16-devel
# Install Microsoft SQL Server on PHP driver
yum install -y php-sqlsrv
yum install -y unixODBC-devel
yum install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
firewall-cmd --zone=public --add-port=1433/tcp
systemctl restart firewalld

# 預設會安裝 SELinux，並以強制模式執行。 若要允許 Apache 透過 SELinux 連線到資料庫，請執行下列命令
setsebool -P httpd_can_network_connect_db 1
