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

function MirrorList_Rocky () {
   repofile1='Rocky-AppStream.repo'
   repofile2='Rocky-BaseOS.repo'
   repofile3='Rocky-Devel.repo'
   repofile4='Rocky-Extras.repo'
   ChangeMirrorBefore='s/^mirrorlist=/#mirrorlist=/g'
   ChangeMirrorAfter='s/\#baseurl=http:\/\/dl.rockylinux.org\/$contentdir/baseurl=https:\/\/free.nchc.org.tw\/rocky/g'

    # Backup repo
    cp /etc/yum.repos.d/${repofile1} /etc/yum.repos.d/${repofile1}.bk
    cp /etc/yum.repos.d/${repofile2} /etc/yum.repos.d/${repofile2}.bk
    cp /etc/yum.repos.d/${repofile3} /etc/yum.repos.d/${repofile3}.bk
    cp /etc/yum.repos.d/${repofile4} /etc/yum.repos.d/${repofile4}.bk

   # Change NCHC Mirror
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile1}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile1}
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile2}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile2}
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile3}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile3}
   sed -i ${ChangeMirrorBefore} /etc/yum.repos.d/${repofile4}
   sed -i ${ChangeMirrorAfter} /etc/yum.repos.d/${repofile4}

   dnf clean all
   dnf update -y
}

function MirrorList_CentOS () {
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

function NetworkConfig () {
    # nmcli command line
    echo "NetworkConfig Success."
}

function InstallingPackages () {
   dnf install -y \
   net-tools \
   vim \
   yum-utils \
   openssh-clients \
   openssh-server
}

function OpenSSHConfig () {
    # Set User Public Key
    # 1. 建立 ~/.ssh 檔案，注意權限需要為 700
    read -p "請輸入您的使用者名稱 (EX: Mars): " username
    if [ -d "/home/$username/.ssh" ]; then
        echo "Folder .ssh does exists"
    else
        mkdir /home/$username/.ssh
        chown $username:$username /home/$username/.ssh
        chmod 700 /home/$username/.ssh
    fi

    cd /home/$username
    read -p "請輸入您的Public Key (EX: xxx.pub): " pubkey
    if [ -f "$pubkey" ]; then
      mv $pubkey /home/$username/.ssh
      cd .ssh
      # 2. 將公鑰檔案內的資料使用 cat 轉存到 authorized_keys 內
      cat $pubkey >> authorized_keys
      # 檔案的權限設定為644
      chmod 644 authorized_keys
      chown $username:$username authorized_keys
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

function FirewallConfig () {
   # enable ssh 22 port
   firewall-cmd --zone=public --permanent --add-port=22/tcp
   firewall-cmd --reload
}

# Main
# OS Upgrade
dnf -y upgrade
## Change TW REPO and Update OS
while true
do
    read -p "是否進行更新 (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        if grep '^NAME="Rocky\ Linux"$' /etc/os-release >/dev/null; then
            grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | cut -d '"' -f2
            MirrorList_Rocky
        elif grep '^NAME="CentOS\ Linux"$' /etc/os-release >/dev/null; then
            grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | cut -d '"' -f2
            MirrorList_CentOS
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
        InstallingPackages
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
        OpenSSHConfig
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
        FirewallConfig
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