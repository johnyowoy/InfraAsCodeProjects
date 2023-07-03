#!/bin/bash
# Program
#   Red Hat Enterprise Linux 8 Systemctl Security Check ShellScript
#   FCB金融組態基準-Red Hat Enterprise Linux 8
# History
#   2023/04/19    JINHAU, HUANG
# Version
#   v1.0

# 尚未確認實作 項次
# 08~29
# 37 aide crontab 時間討論
# 40 如何寫成shellscript
# 61~72，74，78~79
# 80~91
# 96
# 108
# 185 186 187 188
# 207 208 221
# 223 已經預設 ENCRYPT_METHOD SHA512
# 230
# SSH 5 限制SSH存取 啟用
# SSH 16 PermitRootLogin參數討論, 預設no 

# 確認是否以root身分執行
if [[ $EUID -ne 0 ]]; then
    echo "This script MUST be run as root!!"
    exit 1
fi
echo '現在您正以root權限執行腳本...'

# Log異常檢視
# 符合FCB Log
FCB_LOG_SUCCESS='/root/FCB_LOG_SUCCESS.txt'
# 錯誤需修正檢視Log
FCB_LOG_ERROR='/root/FCB_LOG_ERROR.txt'
# 執行異常錯誤
FCB_LOG_FAILED='/root/FCB_LOG_FAILED.txt'
touch ${FCB_LOG_SUCCESS}
touch ${FCB_LOG_ERROR}
touch ${FCB_LOG_FAILED}

# 磁碟與檔案系統
function DiskFilesystem () {

    echo "1 停用cramfs檔案系統"
    if [ -f /etc/modprobe.d/cramfs.conf ]; then
        cramfsfile='/etc/modprobe.d/cramfs.conf'
        if grep install' 'cramfs' '\/bin\/true ${cramfsfile} >/dev/null; then
            if grep blacklist' 'cramfs ${cramfsfile} >/dev/null; then
                echo "檢查OK"
            else
                sed -i '$a blacklist cramfs' ${cramfsfile}
                rmmod cramfs
                echo ${cramfsfile}"已新增blacklist cramfs"
            fi
        else
            sed -i '$a install cramfs /bin/true' ${cramfsfile}
            if grep blacklist' 'cramfs ${cramfsfile} >/dev/null; then
                rmmod cramfs
                echo ${cramfsfile}"已新增install cramfs /bin/true"
            else
                sed -i '$a blacklist cramfs' ${cramfsfile}
                rmmod cramfs
                echo ${cramfsfile}"已新增install cramfs /bin/true"
                echo ${cramfsfile}"已新增blacklist cramfs"
            fi
        fi
    else
        touch /etc/modprobe.d/cramfs.conf
        echo "# Ensure mounting of cramfs filesystems is disabled - modprobe" >> /etc/modprobe.d/cramfs.conf
        sed -i '$a install cramfs /bin/true' /etc/modprobe.d/cramfs.conf
        sed -i '$a blacklist cramfs' /etc/modprobe.d/cramfs.conf
        rmmod cramfs
    fi

    echo "2 停用squashfs檔案系統"
    if [ -f /etc/modprobe.d/squashfs.conf ]; then
        squashfsfile='/etc/modprobe.d/squashfs.conf'
        if grep install' 'squashfs' '\/bin\/true ${squashfsfile} >/dev/null; then
            if grep blacklist' 'squashfs ${squashfsfile} >/dev/null; then
                echo "檢查OK"
            else
                sed -i '$a blacklist squashfs' ${squashfsfile}
                rmmod squashfs
                echo ${squashfsfile}"已新增blacklist squashfs"
            fi
        else
            sed -i '$a install squashfs /bin/true' ${squashfsfile}
            if grep blacklist' 'squashfs ${squashfsfile} >/dev/null; then
                rmmod squashfs
                echo ${squashfsfile}"已新增install squashfs /bin/true"
            else
                sed -i '$a blacklist squashfs' ${squashfsfile}
                rmmod squashfs
                echo ${squashfsfile}"已新增install squashfs /bin/true"
                echo ${squashfsfile}"已新增blacklist squashfs"
            fi
        fi
    else
        touch /etc/modprobe.d/squashfs.conf
        echo "# Disable Mounting of squashfs Filesystems - modprobe" >> /etc/modprobe.d/squashfs.conf
        sed -i '$a install squashfs /bin/true' /etc/modprobe.d/squashfs.conf
        sed -i '$a blacklist squashfs' /etc/modprobe.d/squashfs.conf
        rmmod squashfs
    fi

    echo "3 停用udf檔案系統"
    if [ -f /etc/modprobe.d/udf.conf ]; then
        udffile='/etc/modprobe.d/udf.conf'
        if grep install' 'udf' '\/bin\/true ${udffile} >/dev/null; then
            if grep blacklist' 'udf ${udffile} >/dev/null; then
                echo "檢查OK"
            else
                sed -i '$a blacklist udf' ${udffile}
                rmmod udf
                echo ${udffile}"已新增blacklist udf"
            fi
        else
            sed -i '$a install udf /bin/true' ${udffile}
            if grep blacklist' 'udf ${udffile} >/dev/null; then
                rmmod udf
                echo ${udffile}"已新增install udf /bin/true"
            else
                sed -i '$a blacklist udf' ${udffile}
                rmmod udf
                echo ${udffile}"已新增install udf /bin/true"
                echo ${udffile}"已新增blacklist udf"
            fi
        fi
    else
        touch /etc/modprobe.d/udf.conf
        echo "# Disable Mounting of udf Filesystems - modprobe" >> /etc/modprobe.d/udf.conf
        sed -i '$a install udf /bin/true' /etc/modprobe.d/udf.conf
        sed -i '$a blacklist udf' /etc/modprobe.d/udf.conf
        rmmod udf
    fi

    echo "4 設定/tmp目錄之檔案系統 tmpfs"
    sed -i '$a tmpfs\t\t\t/tmp\t\t\ttmpfs\tdefaults,rw,nosuid,nodev,noexec,relatime\t0 0' /etc/fstab

    echo "5~7 啟用 設定/tmp目錄之nodev,nosuid,noexec選項"
    sed -i '$a /tmp\t\t\t/var/tmp\t\tnone\tdefaults,nodev,nosuid,noexec\t\t0 0' /etc/fstab

    mount -o remount,nodev,nosuid,noexec /tmp

    # 08 設定/var目錄之檔案系統 使用獨立分割磁區或邏輯磁區

    # 09 設定/var/tmp目錄之檔案系統 使用獨立分割磁區或邏輯磁區

    # 10 設定/var/tmp目錄之nodev選項 啟用

    # 11 設定/var/tmp目錄之nosuid選項 啟用

    # 12 設定/var/tmp目錄之noexe選項 啟用

    # 13 設定/var/log目錄之檔案系統 使用獨立分割磁區或邏輯磁區

    # 30 停用autofs服務
    echo "30 停用autofs服務"
    systemctl --now disable autofs

    # 31 停用USB儲存裝置
    echo "31 停用USB儲存裝置"
    touch /etc/modprobe.d/usb-storage.conf
    echo "# disable usb storage" > /etc/modprobe.d/usb-storage.conf
    sed -i '$a install usb-storage /bin/true' /etc/modprobe.d/usb-storage.conf
    sed -i '$a blacklist usb-storage' /etc/modprobe.d/usb-storage.conf
    rmmod usb-storage
}

# 系統設定與維護
function ConfigurationAndMaintenanceInSystem () {
    # Log異常檢視
    # 符合FCB Log
    FCB_LOG_SUCCESS='/root/FCB_LOG_SUCCESS.txt'
    # 錯誤需修正檢視Log
    FCB_LOG_ERROR='/root/FCB_LOG_ERROR.txt'
    # 執行異常錯誤
    FCB_LOG_FAILED='/root/FCB_LOG_FAILED.txt'
    touch ${FCB_LOG_SUCCESS}
    touch ${FCB_LOG_ERROR}
    touch ${FCB_LOG_FAILED}
    
    # 32 GPG簽章驗證
    echo "32 GPG簽章驗證"
    if grep -q "gpgcheck=1" /etc/yum.conf; then
        echo "/etc/yum.conf GPG簽章驗證OK!" >> ${FCB_LOG_SUCCESS}
    elif grep -q "gpgcheck=0" /etc/yum.conf; then
        sed -i 's/gpgcheck=0/gpgcheck=1/g' /etc/yum.conf
        echo "/etc/yum.conf 已修改 GPG簽章驗證OK!" >> ${FCB_LOG_SUCCESS}
    else
        echo "/etc/yum.conf GPG簽章驗證「不符合FCB規定」" >> ${FCB_LOG_FAILED}
    fi

    if grep -q "gpgcheck=1" /etc/dnf/dnf.conf; then
        echo "/etc/dnf/dnf.conf GPG簽章驗證OK!" >> ${FCB_LOG_SUCCESS}
    elif grep -q "gpgcheck=0" /etc/dnf/dnf.conf; then
        sed -i 's/gpgcheck=0/gpgcheck=1/g' /etc/dnf/dnf.conf
        echo "/etc/dnf/dnf.conf 已修改 GPG簽章驗證OK!" >> ${FCB_LOG_SUCCESS}
    else
        echo "/etc/dnf/dnf.conf GPG簽章驗證「不符合FCB規定」" >> ${FCB_LOG_FAILED}
    fi

    # 33 安裝sudo套件
    echo "33 安裝sudo package"
    dnf install -y sudo

    # 34 設定sudo指令使用pty
    echo "34 設定sudo指令使用pty"
    sed -i '$a ##設定sudo指令使用pty' /etc/sudoers
    sed -i '$a Defaults use_pty' /etc/sudoers

    # 35 sudo自訂義日誌檔案 啟用
    echo "# 35 sudo自訂義日誌檔案 啟用"
    sed -i '$a ##sudo自訂義日誌檔案' /etc/sudoers
    sed -i '$a Defaults logfile="sudo.log"' /etc/sudoers

    # 36 安裝AIDE套件
    echo "36 安裝AIDE套件"
    dnf install -y aide
    aide --init
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

    # 37 每天定期檢查檔案系統完整性
    echo "37 每天定期檢查檔案系統完整性"
    touch /var/spool/cron/root
    chmod 600 root
    echo "# 檢查檔案系統完整性" > /var/spool/cron/root
    sed -i '$a 0 5 * * * /usr/sbin/aide --check' /var/spool/cron/root

    # 38 39 開機載入程式設定檔之所有權
    echo "38 39 開機載入程式設定檔之所有權"
    chown root:root /boot/grub2/grub.cfg
    chown root:root /boot/grub2/grubenv
    chmod 600 /boot/grub2/grub.cfg
    chmod 600 /boot/grub2/grubenv

    # 40 開機載入程式之通行碼 設定通行碼
    echo "40 開機載入程式之通行碼 設定通行碼"
    grub2-setpassword
    grub2-mkconfig -o /boot/grub2/grub.cfg

    # 41 啟用單一使用者模式身份識別
    echo "41 啟用單一使用者模式身份識別"
    echo "Ensure authentication required for single user mode."
    sed -i '22s/rescue/emergency/g' /usr/lib/systemd/system/rescue.service

    # 42 停用核心傾印功能
    echo "42 停用核心傾印功能"
    echo "Disbale core dumps"
    sed -i '$a hard core 0' /etc/security/limits.conf

    sed -i '$a fs.suid_dumpable = 0' /etc/sysctl.conf

    sed -i 's/\#Storage=external/Storage=none/g' /etc/systemd/coredump.conf
    sed -i 's/\#ProcessSizeMax=2G/ProcessSizeMax=0/g' /etc/systemd/coredump.conf

    systemctl daemon-reload

    # 43 記憶體位址空間配置隨機載入
    echo "43 記憶體位址空間配置隨機載入"
    sysctl -w kernel.randomize_va_space=2 >> /etc/sysctl.conf

    # 44 全系統加密原則是否為FUTURE 或 FIPS
    echo "44 設定全系統加密原則"
    update-crypto-policies --set FUTURE
    update-crypto-policies

    # Set permissions
    # 45~60
    echo "45~60 設定passwd shadow group gshadow 檔案權限"
    chown root:root /etc/passwd
    chmod 644 /etc/passwd
    chown root:root /etc/shadow
    chmod 000 /etc/shadow
    chown root:root /etc/group
    chmod 644 /etc/group
    chown root:root /etc/gshadow
    chmod 000 /etc/gshadow
    chown root:root /etc/passwd-
    chmod 644 /etc/passwd-
    chown root:root /etc/shadow-
    chmod 000 /etc/shadow-
    chown root:root /etc/group-
    chmod 644 /etc/group-
    chown root:root /etc/gshadow-
    chmod 000 /etc/gshadow-

    # 61 其他使用者寫入具有全域寫入權限之檔案 禁止寫入

    # 73 檢查PATH中是否包含 . 或 .. 或路徑開頭不是 /
    echo "Check PATH"
    if [[ "$PATH" == *.:* ]] || [[ "$PATH" == *..:* ]] || [[ "$PATH" != /*:* ]]; then
        echo "Error: PATH contains invalid entries" >> ${FCB_LOG_ERROR}
        exit 1
    fi

    echo "PATH is valid"


    # 79 使用者家目錄權限
    # 取得所有使用者清單，nologin /bin/false, root不用顯示
    getent passwd | cut -d ':' -f 1,6,7 | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | cut -d ':' -f 2 | xargs chmod 700

    # 80 使用者家目錄擁有者
    getent passwd | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | while read line; do
        user=$(echo $line | cut -d: -f1)
        homepath=$(sh -c "echo ~$user")
        chown $user:$user $homepath
    done

    # 82 使用者家目錄之「.」檔案權限
    getent passwd | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | while read line; do
        user=$(echo $line | cut -d: -f1)
        homepath=$(sh -c "echo ~$user")
        cd $homepath
        chmod 700 .
    done

    # 83 使用者家目錄之「.forward」檔案權限
    getent passwd | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | while read line; do
        user=$(echo $line | cut -d: -f1)
        homepath=$(sh -c "echo ~$user")
        cd $homepath
        if [ -f ".forward" ]; then
            rm .forward
        else
            echo "$user file .forward not exists."
        fi
    done

    # 84 使用者家目錄之「.netrc」檔案權限
    getent passwd | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | while read line; do
        user=$(echo $line | cut -d: -f1)
        homepath=$(sh -c "echo ~$user")
        cd $homepath
        if [ -f ".netrc" ]; then
            rm .netrc
        else
            echo "$user file .netrc not exists."
        fi
    done

    # 85 使用者家目錄之「.rhosts」檔案權限
    getent passwd | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | while read line; do
        user=$(echo $line | cut -d: -f1)
        homepath=$(sh -c "echo ~$user")
        cd $homepath
        if [ -f ".rhosts" ]; then
            rm .rhosts
        else
            echo "$user file .rhosts not exists."
        fi
    done
}

# 系統服務、安裝與維護軟體
function ServiceSystem () {
    echo "95 disable avahi-daemon service"
    echo "96 disable snmp service"
    echo "97 disable squid service"
    echo "98 disable Samba service"
    echo "99 disable FTP service"
    echo "100 disable NIS service"
    declare -a package_names=("avahi" "net-snmp" "squid" "samba" "vsftpd" "ypserv")
    declare -a service_names=("avahi-daemon" "snmpd" "squid" "smb" "vsftpd" "ypserv")
    for index in ${!package_names[@]}; do
        package_name=${package_names[$index]}
        service_name=${service_names[$index]}
        
        if rpm -q "$package_name" >/dev/null 2>&1; then
            echo "package $package_name is installed"
            echo "Disabling service: $service_name"
            systemctl --now disable $service_name
        else
            echo "package $package_name is NOT installed."
        fi
    done

    echo "92 102~106  移除xinetd套件 NIS用戶端 telnet用戶端 telnet伺服器 rsh伺服器 tftp伺服器"
    declare -a remove_package_names=("xinetd" "ypbind" "telnet" "telnet-server" "rsh-server" "tftp-server")
    for remove_package_name in ${remove_package_names[@]}; do
        if rpm -q "$remove_package_name" >/dev/null 2>&1; then
            echo "removing package: $remove_package_name"
            dnf remove $remove_package_name
        else
            echo "package $remove_package_name is NOT installed."
        fi
    done

    echo "101 enable kdump service"
    systemctl --now enable kdump.service

    echo "107 更新套件後移除舊版本元件"
    sed -i '$a clean_requirements_on_remove=True' /etc/yum.conf
    sed -i '$a clean_requirements_on_remove=True' /etc/dnf.conf

    echo "93 chrony校時設定"
    echo "94 disable rsyncd service"
}

# 網路設定
function ConfiguringNetworks () {
    sysctl_conf='/etc/sysctl.conf'
    echo "108 停用IP轉送功能"
    sysctl -w net.ipv4.ip_forward=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.all.forwarding=0 >> ${sysctl_conf}

    echo "109 所有網路介面禁止傳送ICMP重新導入封包"
    sysctl -w net.ipv4.conf.all.send_redirects=0 >> ${sysctl_conf}

    echo "110 預設網路介面禁止傳送ICMP重新導向封包"
    sysctl -w net.ipv4.conf.default.send_redirects=0 >> ${sysctl_conf}

    echo "111 所有網路介面阻擋來源路由封包"
    sysctl -w net.ipv4.conf.all.accept_source_route=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.all.accept_source_route=0 >> ${sysctl_conf}

    echo "112 預設網路介面阻擋來源路由封包"
    sysctl -w net.ipv4.conf.default.accept_source_route=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.default.accept_source_route=0 >> ${sysctl_conf}

    echo "113 所有網路介面阻擋ICMP重新導向封包"
    sysctl -w net.ipv4.conf.all.accept_redirects=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.all.accept_redirects=0 >> ${sysctl_conf}

    echo "114 預設網路介面阻擋ICMP重新導向封包"
    sysctl -w net.ipv4.conf.default.accept_redirects=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.default.accept_redirects=0 >> ${sysctl_conf}

    echo "115 所有網路介面阻擋安全之IMCP重新封包"
    sysctl -w net.ipv4.conf.all.secure_redirects=0 >> ${sysctl_conf}

    echo "116 預設網路介面阻擋安全之ICMP重新導向封包"
    sysctl -w net.ipv4.conf.default.secure_redirects=0 >> ${sysctl_conf}

    echo "117 所有網路介面紀錄可疑封包"
    sysctl -w net.ipv4.conf.all.log_martians=1 >> ${sysctl_conf}

    echo "118 預設網路介面紀錄可疑封包"
    sysctl -w net.ipv4.conf.default.log_martians=1 >> ${sysctl_conf}

    echo "119 不回應ICMP廣播要求"
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 >> ${sysctl_conf}

    echo "120 忽略 造之ICMP錯誤訊息"
    sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1 >> ${sysctl_conf}

    echo "121 所有網路介面啟用逆向路徑過濾功能"
    sysctl -w net.ipv4.conf.all.rp_filter=1 >> ${sysctl_conf}

    echo "122 預設網路介面啟用逆向路徑過濾功能"
    sysctl -w net.ipv4.conf.default.rp_filter=1 >> ${sysctl_conf}

    echo "123 TCP SYN cookies"
    sysctl -w net.ipv4.tcp_syncookies=1 >> ${sysctl_conf}

    echo "124 所有網路介面阻擋IPv6路由器公告訊息"
    sysctl -w net.ipv6.all.accept_ra=0 >> ${sysctl_conf}

    echo "125 預設網路介面阻擋IPv6路由器公告訊息"
    sysctl -w net.ipv6.conf.default.accept_ra=0 >> ${sysctl_conf}

    sysctl -p ${sysctl_conf}

    echo "126 停用DCCP協定"
    touch /etc/modprobe.d/dccp.conf
    sed -i '$a install dccp /bin/true' /etc/modprobe.d/dccp.conf
    sed -i '$a blacklist dccp' /etc/modprobe.d/dccp.conf

    echo "127 停用SCTP協定"
    touch /etc/modprobe.d/sctp.conf
    sed -i '$a install sctp /bin/true' /etc/modprobe.d/sctp.conf
    sed -i '$a blacklist sctp' /etc/modprobe.d/sctp.conf

    echo "128 停用RDS協定"
    touch /etc/modprobe.d/rds.conf
    sed -i '$a install rds /bin/true' /etc/modprobe.d/rds.conf
    sed -i '$a blacklist rds' /etc/modprobe.d/rds.conf

    echo "129 停用TIPC協定"
    touch /etc/modprobe.d/tipc.conf
    sed -i '$a install tipc /bin/true' /etc/modprobe.d/tipc.conf
    sed -i '$a blacklist tipc' /etc/modprobe.d/tipc.conf

    echo "130 停用無線網路介面"
    nmcli radio all off

    echo "131 停用網路介面混雜模式"
    if ip link | grep -i promisc >/dev/null; then
        echo "檢查OK"
    else
        echo "請使用指令"
        echo "ip link set dev (網路介面裝置名稱) multicast off promisc off"
    fi
}

# 日誌與稽核
function AuditLogConfig () {
    echo "132 install auditd package"
    dnf install audit audit-libs

    echo "133 enable auditd service"
    systemctl start auditd
    systemctl --now enable auditd

    echo "134 稽核auditd服務啟動前之程序"
    if cat /etc/default/grub | grep "^GRUB_CMDLINE_LINUX=.*audit=1.*" >/dev/null; then
        echo "/etc/default/grub 稽核auditd=1 檢查OK!"
    else
        sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\("\)/\1 audit=1\2/' /etc/default/grub
        echo "/etc/default/grub 已「增加」稽核auditd=1"
    fi

    echo "135 稽核待辦事項數量限制"
    if cat /etc/default/grub | grep "^GRUB_CMDLINE_LINUX=.*audit_backlog_limit=8192.*" >/dev/null; then
        echo "/etc/default/grub 稽核待辦事項數量限制 audit_backlog_limit=8192 檢查OK"
    else
        sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\("\)/\1 audit_backlog_limit=8192\2/' /etc/default/grub
        echo "/etc/default/grub 已「增加」稽核待辦事項數量限制 audit_backlog_limit=8192"
    fi
    grub2-mkconfig -o /boot/grub2/grub.cfg

    echo "136 稽核處理失敗時通知系統管理者"
    if cat /etc/aliases | grep postmaster:.*root >/dev/null; then
        echo "稽核處理失敗時通知系統管理者 檢查OK"
    else
        sed 's/\(^postmaster:.*\)/postmaster\troot/' /etc/aliases
        echo "稽核處理失敗 已設定通知系統管理者root"
    fi

    echo "137 稽核日誌「檔案」擁有者與群組"
    if stat -c "%U %G" /var/log/audit/audit.log | grep -E root.*root >/dev/null; then
        echo "/var/log/audit/audit.log 檢查OK"
    else
        grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | xargs -I {} chown root:root {}
        echo "/var/log/audit/audit.log 已設定root"
    fi

    echo "138 稽核日誌「檔案」權限"
    if stat -c "%a" /var/log/audit/audit.log | grep 600 >/dev/null; then
        echo "/var/log/audit/audit.log 檢查OK"
    else
        grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | xargs -I {} chmod 600 {}
        echo "/var/log/audit 已設定600"
    fi

    echo "139 稽核日誌「目錄」擁有者與群組"
    if stat -c "%U %G" /var/log/audit | grep -E root.*root >/dev/null; then
        echo "/var/log/audit 檢查OK"
    else
        grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | sed 's/\(.*\)\(\/.*..*\)/\1/' | xargs -I {} chown root:root {}
        echo "/var/log/audit 已設定root:root"
    fi
    
    echo "140 稽核日誌「目錄」讀寫執行權限"
    if stat -c "%a" /var/log/audit | grep 700 >/dev/null; then
        echo "/var/log/audit 檢查OK"
    else
        grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | sed 's/\(.*\)\(\/.*..*\)/\1/' | xargs -I {} chmod 700 {}
        echo "/var/log/audit 已設定700"
    fi

    echo "141 稽核「規則」「檔案」讀寫執行權限"
    if stat -c "%a" /etc/audit/rules.d/audit.rules | grep 600 >/dev/null;then
        echo "/etc/audit/rules.d/audit.rules 檢查OK"
    else
        chmod 600 /etc/audit/rules.d/audit.rules
        echo "/etc/audit/rules.d/audit.rules 已設定600"
    fi

    echo "142 稽核「設定」「檔案」讀寫執行權限"
    if stat -c "%a" /etc/audit/auditd.conf | grep 640 >/dev/null; then
        echo "/etc/audit/auditd.conf  檢查OK"
    else
        chmod 640 /etc/audit/auditd.conf
        echo "/etc/audit/auditd.conf 已設定640"
    fi

    echo "143 稽核工具權限 讀寫執行"
    declare -a AuditTools=("auditctl" "aureport" "ausearch" "autrace" "auditd" "audisp-remote" "audisp-syslog" "augenrules")
    for index in ${!AuditTools[@]}; do
        AuditTool=${AuditTools[$index]}
        if [ -f "/sbin/${AuditTool}" ]; then
            if stat -c "%a" /sbin/${AuditTool} | grep 750 >/dev/null; then
                echo "/sbin/${AuditTool}  檢查OK"
            else
                chmod 750 /sbin/${AuditTool}
                echo "/sbin/${AuditTool} 已設定750"
            fi
        else
            echo "File /sbin/${AuditTool} does not exists"
        fi
    done

    echo "144 稽核工具擁有者與群組權限"
    declare -a AuditTools=("auditctl" "aureport" "ausearch" "autrace" "auditd" "audisp-remote" "audisp-syslog" "augenrules")
    for index in ${!AuditTools[@]}; do
        AuditTool=${AuditTools[$index]}
        if [ -f "/sbin/${AuditTool}" ]; then
            if stat -c "%U %G" /sbin/${AuditTool} | grep -E root.*root >/dev/null; then
                echo "/sbin/${AuditTool}  檢查OK"
            else
                chown root:root /sbin/${AuditTool}
                echo "/sbin/${AuditTool} 已設定root:root"
            fi
        else
            echo "File /sbin/${AuditTool} does not exists"
        fi
    done

    echo "145 啟用保護稽核工具"
    if cat /etc/aide.conf | grep AuditConfig.*=.*p+i+n+u+g+s+b+acl+xattrs+sha512 >/dev/null; then
        echo "/etc/aide.conf 檢查OK"
    else
        sed -i '$a AuditConfig = p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide.conf
        echo "/usr/sbin/${AuditTool} 已新增規則"
    fi

    for index in ${!AuditTools[@]}; do
        AuditTool=${AuditTools[$index]}
        if [ -f "/sbin/${AuditTool}" ]; then
            if cat /etc/aide.conf | grep /usr/sbin/${AuditTool}.*AuditConfig >/dev/null; then
                echo "/usr/sbin/${AuditTool}  檢查OK"
            else
                sed -i '$a /usr/sbin/'${AuditTool}' AuditConfig' /etc/aide.conf
                echo "/usr/sbin/${AuditTool} 已新增規則"
            fi
        else
            echo "File /sbin/${AuditTool} does not exists"
            echo "不用新增${AuditTool}"
        fi
    done

    echo "146 稽核日誌檔案大小上限"
    if cat /etc/audit/auditd.conf | grep max_log_file' '=' '32 >/dev/null; then
        echo "檢查OK"
    else
        sed -i 's/max_log_file =.*/max_log_file = 32/g' /etc/audit/auditd.conf
        echo "/etc/audit/auditd.conf, 已修改max_log_file = 32"
    fi

    echo "147 稽核日誌達到其檔案大小上限之行為"
    if cat /etc/audit/auditd.conf | grep max_log_file_action' '=' 'keep_logs >/dev/null; then
        echo "檢查OK"
    else
        sed -i 's/max_log_file_action =.*/max_log_file_action = keep_logs/g' /etc/audit/auditd.conf
        echo "/etc/audit/auditd.conf, 已修改max_log_file_action = keep_logs"
    fi
    
    echo "148 啟用紀錄系統管理者活動"
    if grep '\-w /etc/sudoers \-p wa \-k scope\|\-w /etc/sudoers.d/ \-p wa \-k scope' /etc/audit/rules.d/audit.rules >/dev/null; then
        echo "檢查OK"
    else
        sed -i '$a -w /etc/sudoers -p wa -k scope' ${auditrules}
        sed -i '$a -w /etc/sudoers.d/ -p wa -k scope' ${auditrules}
        echo "已新增設定"
    fi
}

# 149 紀錄變更登入與登出資訊事件 啟用
sed -i '$a -w /var/run/faillock/ -p wa -k logins' ${auditrules}
sed -i '$a -w /var/log/lastlog -p wa -k logins' ${auditrules}

# 150 紀錄會談啟始資訊 啟用
sed -i '$a -w /var/run/utmp -p wa -k session' ${auditrules}
sed -i '$a -w /var/log/wtmp -p wa -k logins' ${auditrules}
sed -i '$a -w /var/log/btmp -p wa -k logins' ${auditrules}

# 151 紀錄變更日期與時間事件 啟用
sed -i '$a -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S clock_settime -k time-change' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S clock_settime -k time-change' ${auditrules}
sed -i '$a -w /etc/localtime -p wa -k time-change' ${auditrules}

# 152 紀錄變更系統強制存取控制事件 啟用
sed -i '$a -w /etc/selinux/ -p wa -k MAC-policy' ${auditrules}
sed -i '$a -w /usr/share/selinux/ -p wa -k MAC-policy' ${auditrules}

# 153 紀錄變更系統網路環境事件 啟用
sed -i '$a -a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale' ${auditrules}
sed -i '$a -w /etc/issue -p wa -k system-locale' ${auditrules}
sed -i '$a -w /etc/issue.net -p wa -k system-locale' ${auditrules}
sed -i '$a -w /etc/hosts -p wa -k system-locale' ${auditrules}
sed -i '$a -w /etc/sysconfig/network-scripts/ -p wa -k system-locale' ${auditrules}

# 154 紀錄變更自主存取控制權限事件 啟用
sed -i '$a -a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod' ${auditrules}

# =============================================

# 155 紀錄不成功之未經授權檔案存取 啟用
sed -i '$a -a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access' ${auditrules}
sed -i '$a ' ${auditrules}

# 156 紀錄變更使用者或群組資訊事件 啟用
sed -i '$a -w /etc/group -p wa -k identity' ${auditrules}
sed -i '$a -w /etc/passwd -p wa -k identity' ${auditrules}
sed -i '$a -w /etc/gshadow -p wa -k identity' ${auditrules}
sed -i '$a -w /etc/shadow -p wa -k identity' ${auditrules}
sed -i '$a -w /etc/security/opasswd -p wa -k identity' ${auditrules}

# 157 紀錄變更檔案系統掛載事件
sed -i '$a -a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts' ${auditrules}

# 158 紀錄特權指令使用情形 啟用

# 159 紀錄檔案刪除事件 啟用
sed -i '$a -a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete' ${auditrules}

# 160 紀錄核心模組掛載與卸載事件 啟用
sed -i '$a -w /sbin/insmod -p x -k modules' ${auditrules}
sed -i '$a -w /sbin/rmmod -p x -k modules' ${auditrules}
sed -i '$a -w /sbin/modprobe -p x -k modules' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S init_module -S delete_module -k modules' ${auditrules}

# 161 紀錄系統管理者活動日誌變更 啟用

# 162 紀錄chcon指令使用情形 啟用
sed -i '$a -a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng' ${auditrules}

# 163 紀錄ssh-agent 程序使用情形 啟用
sed -i '$a -a always,exit -F path=/usr/bin/sshagent -F perm=x -F auid>=1000 -F auid!=4294967295 -k privilegedssh' ${auditrules}

# 164 紀錄unix_updat 啟用
sed -i '$a -a always,exit -F  path=/sbin/unix_update -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-unix-updat' ${auditrules}

# 165 紀錄setfacl指令使用情形 啟用
sed -i '$a -a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng' ${auditrules}

# 166 紀錄finit_module指令使用情形 啟用
sed -i '$a -a always,exit -F arch=b32 -S finit_module -F auid>=1000 -F auid!=4294967295 -k module_chng' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S finit_module -F auid>=1000 -F auid!=4294967295 -k module_chng' ${auditrules}

# 167 紀錄open_by_handle_at系統呼叫使用情形 啟用
sed -i '$a -a always,exit -F arch=b32 -S open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k perm_access' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k perm_access' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k perm_access' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k perm_access' ${auditrules}

# 168 紀錄usermod指令使用情形
# 168 紀錄usermod指令使用情形 啟用
sed -i '$a -a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-usermod' ${auditrules}

# 169 紀錄chaacl指令使用情形 啟用
sed -i '$a -a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng' ${auditrules}

# 170 紀錄kmod指令使用情形 啟用
sed -i '$a -w /bin/kmod -p x -k modules' ${auditrules}

# 171 紀錄Pam_Faillock日誌檔案 啟用
sed -i '$a -w /var/log/faillock -p wa -k logins' ${auditrules}

# 172 紀錄execve系統呼叫使用情形 啟用
sed -i '$a -a always,exit -F arch=b32 -S execve -C uid!=euid -F key=execpriv' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S execve -C uid!=euid -F key=execpriv' ${auditrules}
sed -i '$a -a always,exit -F arch=b32 -S execve -C gid!=egid -F key=execpriv' ${auditrules}
sed -i '$a -a always,exit -F arch=b64 -S execve -C gid!=egid -F key=execpriv' ${auditrules}

# 173 auditd設定不變模式
sed -i '12a # Set enabled flag.' ${auditrules}
sed -i '13a # To lock the audit configuration so that it can’t be changed, pass a 2 as the argument.' ${auditrules}
sed -i '14a -e 2' ${auditrules}

# 174 rsyslog套件 安裝
dnf install -y rsyslog

# 175 rsyslog服務 啟用
systemctl --now enable rsyslog

# 176 設定rsyslog日誌檔案預設權限
chmod 640 /etc/rsyslog.conf
chmod 640 /etc/rsyslog.d/*.conf

# 177 設定rsyslog 日誌紀錄規則
sed -i '46a daemon.*\t\t\t\t\t\t\/var\/log\/messages' /etc/rsyslog.conf
sed -i '50a auth.*\t\t\t\t\t\t\t\/var\/log\/secure' /etc/rsyslog.conf

# 178 /var/log/messages檔案所有權
chown root:root /var/log/messages

# 179 /var/log 目錄所有權
chown root:root /var/log

# 180 設定journald將日誌發送到rsyslog
sed -i 's/#ForwardToSyslog=no/ForwardToSyslog=yes/g' /etc/systemd/journald.conf

# 181 設定journald壓縮日誌檔案
sed -i 's/#Compress=yes/Compress=yes/g' /etc/systemd/journald.conf

# 182 設定journald將日誌檔案永久保存於磁碟
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf

# 183 設定/var/log目錄下所有日誌檔案權限
find /var/log -type f -perm /g=w,g=x,o=w,o=x -exec chmod 644 {} \;

# SELinux
echo "=============================="
echo "======= SELinux Config ======="
echo "=============================="

# 184 SELinux套件 安裝
dnf install libselinux

# 185 開機載入程式啟用SELinux 啟用

# 186 SELinux政策 targeted或更嚴格之政策
# 判斷式
if grep -q "SELINUXTYPE=targeted" /etc/selinux/config; then
    echo "/etc/selinux/config SELINUXTYPE 驗證OK!" >> ${FCB_LOG_SUCCESS}
else
    sed -i 's/\(^SELINUXTYPE=.*\)/SELINUXTYPE=targeted/g' /etc/selinux/config
    echo "/etc/selinux/config 已修改 SELINUXTYPE 驗證OK!" >> ${FCB_LOG_SUCCESS}
fi

# 187 SELinux啟用狀態 enforcing
# 判斷式

# 188 未受限程序 無

# 189 移除setroubleshoot套件
dnf remove -y setroubleshoot

# 190 移除mcstrans套件
dnf remove mcstrans

# cron設定
echo "=============================="
echo "========== cron設定 =========="
echo "=============================="

# 191 啟用cron守護程序
systemctl --now enable crond

# 192 /etc/crontab檔案所有權
chown root:root /etc/crontab

# 193 /etc/crontab檔案權限
chmod 600 /etc/crontab

# 194 /etc/cron.hourly目錄所有權
chown root:root /etc/cron.hourly

# 195 /etc/cron.hourly目錄權限
chmod 700 /etc/cron.hourly

# 196 /etc/cron.daily目錄所有權
chown root:root /etc/cron.daily

# 197 /etc/cron.daily目錄權限
chmod 700 /etc/cron.daily

# 198 /etc/cron.weekly目錄所有權
chown root:root /etc/cron.weekly

# 199 /etc/cron.weekly目錄權限
chmod 700 /etc/cron.weekly

# 200 /etc/cron.monthly目錄所有權
chown root:root /etc/cron.monthly

# 201 /etc/cron.monthly目錄權限
chmod 700 /etc/cron.monthly

# 202 /etc/cron.d目錄所有權
chown root:root /etc/cron.d

# 203 /etc/cron.d目錄權限
chmod 700 /etc/cron.d

# 204 at.allow與cron.allow檔案所有權
# 205 at.allow與cron.allow檔案權限
rm /etc/cron.deny
rm /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
chmod 600 /etc/cron.allow
chmod 600 /etc/at.allow

# 206 cron日誌紀錄功能 啟用
if grep -q "cron.* /var/log/cron" /etc/rsyslog.conf; then
    echo "/etc/rsyslog.conf 驗證OK!" >> ${FCB_LOG_SUCCESS}
else
    echo "/etc/rsyslog.conf cron.*驗證「不符合FCB規定」" >> ${FCB_LOG_FAILED}
fi

# 帳號與存取控制
echo "=============================="
echo "======== 帳號與存取控制 ========"
echo "=============================="

# 209 通行碼最小長度 12個字元以上
sed -i 's/# minlen = 8/minlen = 12/g' /etc/security/pwquality.conf

# 210 通行碼必須至少包含字元類別數量
sed -i 's/# minclass = 0/minclass = 4/g' /etc/security/pwquality.conf

# 211 通行碼必須至少包含1個以上數字
sed -i 's/# dcredit = 0/dcredit = -1/g' /etc/security/pwquality.conf

# 212 通行碼必須至少包含1個以上大寫字母個數
sed -i 's/# ucredit = 0/ucredit = -1/g' /etc/security/pwquality.conf

# 213 通行碼必須至少包含1個以上小寫字母個數
sed -i 's/# lcredit = 0/lcredit = -1/g' /etc/security/pwquality.conf

# 214 通行碼必須至少包含1個以上特殊字元個數
sed -i 's/# ocredit = 0/ocredit = -1/g' /etc/security/pwquality.conf

# 215 新通行碼與舊通行碼最少3個以上相異字元數
sed -i 's/# difok = 1/difok = 3/g' /etc/security/pwquality.conf

# 216 同一類別字元可連續使用個數，4個以下但必須大於0
sed -i 's/# maxclassrepeat = 0/maxclassrepeat = 4/g' /etc/security/pwquality.conf

# 217 相同字元可連續使用個數，3個以下但必須大於0
sed -i 's/# maxrepeat = 0/maxrepeat = 3/g' /etc/security/pwquality.conf

# 218 必須禁止使用字典檔單字做為通行碼
sed -i 's/# dictcheck = 1/# dictcheck = 1/g' /etc/security/pwquality.conf

# 219 帳戶鎖定閾值
sed -i 's/# deny = 3/deny = 5/g' /etc/security/faillock.conf

# 220 帳戶鎖定時間900秒以上
sed -i 's/# unlock_time = 600/unlock_time = 900/g' /etc/security/faillock.conf

# 221 強制執行通行碼歷程紀錄 3個以上

# 222 顯示登入失敗次數與日期 啟用
sed -i '$a session required\t\t\tpam_lastlog.so showfailed' /etc/pam.d/postlogin

# 223 通行碼雜湊演算法

# 224 通行碼最短使用期限
sed -i '132 s/^.*/PASS_MIN_DAYS\t1/g' /etc/login.defs
# chage --mindays 1 (使用者帳號名稱)

# 225 通行碼到期前提醒使用者變更通行碼 14天以上
sed -i '133 s/^.*/PASS_WARN_AGE\t14/g' /etc/login.defs
# chage --warndays 14 (使用者帳號名稱)

# 226 通行碼最長使用期限 90天以下，但必須大於0
sed -i '131 s/^.*/PASS_MAX_DAYS\t90/g' /etc/login.defs
# chage --maxdays 90 (使用者帳號名稱)

# 227 通行碼到期後，帳號停用前之天數 30天以下，但須大於0
useradd -D -f 30
# chage --inactive 30 (使用者帳號名稱)

# 228 登入嘗試失敗之延遲時間 4秒以上
sed -i '14 s/^.*/FAIL_DELAY\t4/g' /etc/login.defs

# 229 新使用者帳號預設建立使用者家目錄
sed -i '262 s/^.*/CREATE_HOME\tyes/g' /etc/login.defs

# 230 要求使用者必須經過身份鑑別才能提升權限

# 231 限制每個帳號可同時登入之數量 10以下，但須大於0


echo "==================================="
echo "===== Firewalld Configuration ====="
echo "==================================="

# ====================================
# === Change firewalld or ntfables ===
# ====================================

# 1 安裝firewalld防火牆套件
dnf install -y firewalld

# 2 firewalld自動啟用服務
systemctl --now enable firewalld

# 3 停用iptables服務
systemctl --now mask iptables

# 4 停用nftables服務
systemctl --now mask nftables

# 5 firewalld防火牆設定區域
firewall-cmd --set-default-zone=public

echo "==================================="
echo "===== Nftables Services Stop ======"
echo "==================================="

echo "===================================="
echo "======== SSH Configuration ========="
echo "===================================="

# 1 sshd守護程序 啟用
dnf install -y openssh-server
systemctl --now enable sshd

# 2 ssh協定版本
sed -i '20a Protocol 2' /etc/ssh/sshd_config

# 3 /etc/ssh/sshd_config檔案所有權
chown root:root /etc/ssh/sshd_config

# 4 /etc/ssh/sshd_config檔案權限
chmod 600 /etc/ssh/sshd_config

# 5 限制存取SSH

# 6 SSH主機私鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:ssh_keys {} \;

# 7 SSH主機私鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 640 {} \;

# 8 SSH主機公鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;

# 9 SSH主機公鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 644 {} \;

# 10 SSH加密演算法
sed -i '34a Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config

# 11 SSH日誌紀錄等級 啟用
sed -i 's/#LogLevel INFO/LogLevel INFO/g' /etc/ssh/sshd_config

# 12 SSH X11 Forwarding功能 設定no
sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config

# 13 SSH MaxAuthTries參數
sed -i 's/#MaxAuthTries 6/MaxAuthTries 4/g' /etc/ssh/sshd_config

# 14 SSH IgnoreRhosts參數
sed -i 's/#IgnoreRhosts yes/IgnoreRhosts yes/g' /etc/ssh/sshd_config

# 15 SSH HostbasedAuthentication參數
sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config

# 16 SSH PermitRootLogin參數

# 17 SSH PermitEmptyPasswords參數
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config

# 18 SSH PermitUserEnvironment參數
sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment no/g' /etc/ssh/sshd_config

# 19 SSH逾時時間
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 600/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/g' /etc/ssh/sshd_config

# 20 SSH LoginGraceTime參數
sed -i 's/#LoginGraceTime 2m/LoginGraceTime 60m/g' /etc/ssh/sshd_config

# 21 SSH UsePAM參數 (預設已設定)

# 22 SSH AllowTcpForwarding參數
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config

# 23 SSH MaxStartups參數
sed -i 's/#MaxStartups 10:30:100/MaxStartups 10:30:60/g' /etc/ssh/sshd_config

# 24 SSH MaxSession參數
sed -i 's/#MaxSessions 10/MaxSessions 4/g' /etc/ssh/sshd_config

# 25 SSH StrictModes參數
sed -i 's/#StrictModes yes/StrictModes yes/g' /etc/ssh/sshd_config

# 26 SSH Compression參數
sed -i 's/#Compression delayed/Compression no/g' /etc/ssh/sshd_config

# 27 SSH IgnoreUserKnownHosts參數
sed -i 's/#IgnoreUserKnownHosts no/IgnoreUserKnownHosts yes/g' /etc/ssh/sshd_config

# 28 SSH PrintLastLog參數
sed -i 's/#PrintLastLog yes/PrintLastLog yes/g' /etc/ssh/sshd_config

# 29 移除shosts.equiv檔案
find / -name shosts.equiv -exec rm {} \;

# 30 移除.shosts檔案
find / -name *.shosts -exec rm {} \;

# 31 停用覆寫全系統加密原則 (預設停用)

systemctl restart sshd

echo "===================================="
echo "======= DISK and File System ======="
echo "===================================="
echo "===================================="
echo "=========== 磁碟與檔案系統 ==========="
echo "===================================="
#DiskFilesystem

echo "============================================="
echo "== configuration and maintenance in system =="
echo "============================================="
echo "==================================="
echo "=========== 系統設定與維護 ==========="
echo "==================================="
#ConfigurationAndMaintenanceInSystem

echo "================================="
echo "===== Configuration Network ====="
echo "================================="
echo "==================================="
echo "============= 網路設定 ============="
echo "==================================="
#ConfiguringNetworks

echo "=========================="
echo "======= LOG Config ======="
echo "=========================="
echo "=========================="
echo "======== 日誌與稽核 ========"
echo "=========================="
#AuditLogConfig