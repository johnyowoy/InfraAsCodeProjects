#!/bin/bash
#!/bin/bash
# Program
#   Red Hat Enterprise Linux 9 Systemctl Security Check ShellScript
#   GCB政府組態基準-Red Hat Enterprise Linux 9
# History
#   2023/04/19    JINHAU, HUANG
# Version
#   v1.0

# 尚未確認實作 項次
# 08
# 37 aide crontab 時間討論
# 40 如何寫成shellscript
# 61~72，74，78~79
# 80~91
# 96
# 108
# 185 186 187 188
# 207 208 221

# 確認是否以root身分執行
if [[ $EUID -ne 0 ]]; then
    echo "This script MUST be run as root!!"
    exit 1
fi

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

# =================
# || 磁碟與檔案系統 ||
# =================
echo "==================================="
echo "== DISK and File System =="
echo "==================================="
echo "==================================="
echo "== 磁碟與檔案系統 =="
echo "==================================="

# 01 crams檔案系統 停用

# 02 squashs檔案系統 停用

# 03 udf檔案系統 停用

# 04 設定/tmp目錄之檔案系統
#sed -i '$a tmpfs\t\t\t/tmp\t\t\ttmpfs\tdefaults,rw,nosuid,nodev,noexec,relatime\t0 0' /etc/fstab
#systemctl unmask tmp.mount
#systemctl enable tmp.mount
## sed -i 's/Options=mode=1777,strictatime/Options=mode=1777,strictatime,noexec,nodev,nosuid/g' /etc/systemd/system/local-fs.target.wants/tmp.mount
#sed -i 's/\(^Options=mode=1777,strictatime\)/\1,noexec,nodev,nosuid/' /etc/systemd/system/local-fs.target.wants/tmp.mount

# 05 設定/tmp目錄之nodev選項 啟用

# 06 設定/tmp目錄之nosuid選項 啟用

# 07 設定/tmp目錄之noexec選項 啟用

# 08 設定/var目錄之檔案系統 使用獨立分割磁區或邏輯磁區

# 09 設定/var/tmp目錄之檔案系統 使用獨立分割磁區或邏輯磁區

# 10 設定/var/tmp目錄之nodev選項 啟用

# 11 設定/var/tmp目錄之nosuid選項 啟用

# 12 設定/var/tmp目錄之noexe選項 啟用

# 13 設定/var/log目錄之檔案系統 使用獨立分割磁區或邏輯磁區

# 30 autofs服務 停用
systemctl --now disable autofs

# 31 USB儲存裝置 停用
touch /etc/modprobe.d/usb-storage.conf
echo "# disable usb storage" > /etc/modprobe.d/usb-storage.conf
sed -i '$a install usb-storage /bin/true' /etc/modprobe.d/usb-storage.conf
sed -i '$a blacklist usb-storage' /etc/modprobe.d/usb-storage.conf
rmmod usb-storage

# =================
# || 系統設定與維護 ||
# =================
echo "==================================="
echo "== System Config and Maintenance =="
echo "==================================="

echo "==================================="
echo "=========== 系統設定與維護 ==========="
echo "==================================="

# 32 GPG簽章驗證
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
dnf install -y sudo

# 34 設定sudo指令使用pty
sed -i '$a ##設定sudo指令使用pty' /etc/sudoers
sed -i '$a Defaults use_pty' /etc/sudoers

# 35 sudo自訂義日誌檔案 啟用
sed -i '$a ##sudo自訂義日誌檔案' /etc/sudoers
sed -i '$a Defaults logfile="sudo.log"' /etc/sudoers

# 36 安裝AIDE套件
dnf install -y aide
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# 37 每天定期檢查檔案系統完整性
touch /var/spool/cron/root
chmod 600 root
echo "# 檢查檔案系統完整性" > /var/spool/cron/root
sed -i '$a 0 5 * * * /usr/sbin/aide --check' /var/spool/cron/root

# 38 39 開機載入程式設定檔之所有權
chown root:root /boot/grub2/grub.cfg
chown root:root /boot/grub2/grubenv
chmod 600 /boot/grub2/grub.cfg
chmod 600 /boot/grub2/grubenv

# 40 開機載入程式之通行碼 設定通行碼
echo "開機載入程式之通行碼 設定通行碼"
grub2-setpassword
grub2-mkconfig -o /boot/grub2/grub.cfg

# 41 單一使用者模式身份識別 啟用


# 核心傾印功能
# 這項原則設定決定是否啟用核心傾印(Core dump)功能
# 核心傾印檔案是程式異常終止時，系統將當時記憶體內容以檔案方式記錄下來所產生之記憶體映像檔案，可供程式除錯之用
# 禁止使用者與 SUID 程式產生核心傾印檔案，避免核心傾印檔案洩露如記憶體位址或空間配置等敏感資

# Disbale core dumps
sed -i '$a hard core 0' /etc/security/limits.conf

sed -i '$a fs.suid_dumpable = 0' /etc/sysctl.conf

sed -i 's/\#Storage=external/Storage=none/g' /etc/systemd/coredump.conf
sed -i 's/\#ProcessSizeMax=2G/ProcessSizeMax=0/g' /etc/systemd/coredump.conf

systemctl daemon-reload

sed -i '$a kernel.randomize_va_space = 2' /etc/sysctl.conf
sysctl -w kernel.randomize_va_space=2

# 設定全系統加密原則使用FUTURE 或 FIPS 原則，避免使用較舊且易被攻擊之加密演算法
# FUTURE：採取保守之安全原則，可承受近期相關攻擊，不允許使用 SHA-1 演算法，要求 RSA 密鑰與Diffie-Hellman 金鑰至少為3,072 位元
#  FIPS：符合 FIPS140-2 要求原則，使用內建之 fips-mode-setup 工具，將作業系統切換到 FIPS 模式

# 全系統加密原則是否為FUTURE 或 FIPS
echo "設定全系統加密原則"
grep -E -i '^\s*(FUTURE|FIPS)\s*(\s+#.*)?$' /etc/crypto-policies/config

update-crypto-policies --set FUTURE
update-crypto-policies

fips-mode-setup --enable

# Set permissions
# 45~60
echo "設定passwd shadow group gshadow 檔案權限"
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

# 檢查PATH中是否包含 . 或 .. 或路徑開頭不是 /
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


# 92 remove xinetd package
XinetdService='xinetd'
IS_STATUS="systemctl status ${XinetdService}"
if [ "${IS_STATUS}" == "Unit ${XinetdService}.service could not be found." ]; then
    echo "${XinetdService} service not installed on Red Hat Linux 9" >> ${FCB_LOG_SUCCESS}
else
    systemctl stop ${XinetdService}
    systemctl disable ${XinetdService}
    dnf remove -y ${XinetdService}
    echo "${XinetdService} Package has been removed" >> ${FCB_LOG_SUCCESS}
fi

# 93 chrony校時設定

# 94 disable rsyncd service
RsyncdService='rsyncd'
IS_ACTIVE="systemctl is-active ${RsyncdService}.service"
if [ "$IS_ACTIVE" == "inactive" ]; then
    echo "${RsyncdService} is not active." >> ${FCB_LOG_SUCCESS}
else 
    systemctl stop ${RsyncdService}
    systemctl --now disable ${RsyncdService}
    echo "Closed ${RsyncdService} service." >> ${FCB_LOG_SUCCESS}
fi

# 95 disable avahi-daemon service
AvahiService='avahi-daemon'
IS_ACTIVE="systemctl is-active ${AvahiService}.service"
if [ "$IS_ACTIVE" == "inactive" ]; then
    echo "Closed ${AvahiService} service."
else
    systemctl stop ${AvahiService}
    systemctl --now disable ${AvahiService}
    echo "${AvahiService} is not active." >> ${FCB_LOG_SUCCESS}
fi

# 96 disable snmp service
systemctl stop snmpd
systemctl --now disable snmpd

# 97 disable Squid service
systemctl stop squid
systemctl --now disable squid

# 98 disable Samba service
systemctl stop smb
systemctl --now disable smb

# 99 disable FTP service
systemctl stop vsftpd
systemctl --now disable vsftpd

# 100 disable NIS service
systemctl stop ypserv
systemctl --now disable ypserv

# 101 enable kdump service
systemctl start kdump.service
systemctl --now enable kdump.service

# 102 remove ypbind package NIS用戶端套件
systemctl stop ypbind
systemctl --now disable ypbind
dnf remove -y ypbind

# 103 remove telnet-client package
# 104 remove telnet-server package
systemctl stop telnet.socket
systemctl --now disable telnet.socket
dnf remove -y telnet
dnf remove -y telnet-server

# 105 remove rsh-server
dnf remove rsh-server

# 106 remove tftp package
dnf remove -y tftp-server

# 107 更新套件後移除舊版本元件
sed -i '$a clean_requirements_on_remove=True' /etc/yum.conf
sed -i '$a clean_requirements_on_remove=True' /etc/dnf.conf

# 網路設定
echo "=========================="
echo "===== NETWORK Config ====="
echo "=========================="

sysctl_conf='/etc/sysctl.conf'
sysctl_d='/etc/sysctl.d/*.conf'

# 108 IP轉送

# 109 所有網路介面禁止傳送ICMP重新導入封包
sed -i '$a net.ipv4.conf.all.send_redirects=0' ${sysctl_conf}
sed -i '$a net.ipv4.conf.all.send_redirects=0' ${sysctl_d}
sysctl -w net.ipv4.conf.all.send_redirects=0

# 110 預設網路介面禁止傳送ICMP重新導向封包
sed -i '$a net.ipv4.conf.default.send_redirects=0' ${sysctl_d}
sysctl -w  net.ipv4.conf.default.send_redirects=0

# 111 所有網路介面阻擋來源路由封包
sed -i '$a net.ipv4.conf.all.accept_source_route=0' ${sysctl_conf}
sed -i '$a net.ipv6.conf.all.accept_source_route=0' ${sysctl_conf}
sed -i '$a net.ipv4.conf.all.accept_source_route=0' ${sysctl_d}
sed -i '$a net.ipv6.conf.all.accept_source_route=0' ${sysctl_d}
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.all.accept_source_route=0

# 112 預設網路介面阻擋來源路由封包
sed -i '$a net.ipv4.conf.default.accept_source_route=0' ${sysctl_conf}
sed -i '$a net.ipv6.conf.default.accept_source_route=0' ${sysctl_conf}
sed -i '$a net.ipv4.conf.default.accept_source_route=0' ${sysctl_d}
sed -i '$a net.ipv6.conf.default.accept_source_route=0' ${sysctl_d}
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv6.conf.default.accept_source_route=0

# 113 所有網路介面阻擋ICMP重新導向封包
sed -i '$a net.ipv4.conf.all.accept_redirects=0' ${sysctl_conf}
sed -i '$a net.ipv6.conf.all.accept_redirects=0' ${sysctl_conf}
sed -i '$a net.ipv4.conf.all.accept_redirects=0' ${sysctl_d}
sed -i '$a net.ipv6.conf.all.accept_redirects=0' ${sysctl_d}
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_redirects=0

# 114 預設網路介面阻擋ICMP重新導向封包
sed -i '$a net.ipv4.conf.default.accept_redirects=0' ${sysctl_conf}
sed -i '$a net.ipv6.conf.default.accept_redirects=0' ${sysctl_conf}
sed -i '$a net.ipv4.conf.default.accept_redirects=0' ${sysctl_d}
sed -i '$a net.ipv6.conf.default.accept_redirects=0' ${sysctl_d}
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_redirects=0

# 115 所有網路介面阻擋安全之IMCP重新封包
sed -i '$a net.ipv4.conf.all.secure_redirects=0' ${sysctl_conf}
sed -i '$a net.ipv4.conf.all.secure_redirects=0' ${sysctl_d}
sysctl -w net.ipv4.conf.all.secure_redirects=0

# 116 預設網路介面阻擋安全之ICMP重新導向封包
sed -i '$a net.ipv4.conf.default.secure_redirects=0' ${sysctl_conf}
sed -i '$a net.ipv4.conf.default.secure_redirects=0' ${sysctl_d}
sysctl -w net.ipv4.conf.default.secure_redirects=0

# 117 所有網路介面紀錄可疑封包
sed -i '$a net.ipv4.conf.all.log_martians=1' ${sysctl_conf}
sed -i '$a net.ipv4.conf.all.log_martians=1' ${sysctl_d}
sysctl -w net.ipv4.conf.all.log_martians=1

# 118 預設網路介面紀錄可疑封包
sed -i '$a net.ipv4.conf.default.log_martians=1' ${sysctl_conf}
sed -i '$a net.ipv4.conf.default.log_martians=1' ${sysctl_d}
sysctl -w net.ipv4.conf.default.log_martians=1

# 119 不回應ICMP廣播要求
sed -i '$a net.ipv4.icmp_echo_ignore_broadcasts=1' ${sysctl_conf}
sed -i '$a net.ipv4.icmp_echo_ignore_broadcasts=1' ${sysctl_d}
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1

# 120 忽略 造之ICMP錯誤訊息
sed -i '$a net.ipv4.icmp_ignore_bogus_error_responses=1' ${sysctl_conf}
sed -i '$a net.ipv4.icmp_ignore_bogus_error_responses=1' ${sysctl_d}
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1

# 121 所有網路介面啟用逆向路徑過濾功能
sed -i '$a net.ipv4.conf.all.rp_filter=1' ${sysctl_conf}
sed -i '$a net.ipv4.conf.all.rp_filter=1' ${sysctl_d}
sysctl -w net.ipv4.conf.all.rp_filter=1

# 122 預設網路介面啟用逆向路徑過濾功能
sed -i '$a net.ipv4.conf.default.rp_filter=1' ${sysctl_conf}
sed -i '$a net.ipv4.conf.default.rp_filter=1' ${sysctl_d}
sysctl -w net.ipv4.conf.default.rp_filter=1

# 123 TCP SYN cookies
sed -i '$a net.ipv4.tcp_syncookies=1' ${sysctl_conf}
sed -i '$a net.ipv4.tcp_syncookies=1' ${sysctl_d}
sysctl -w net.ipv4.tcp_syncookies=1

# 124 所有網路介面阻擋IPv6路由器公告訊息
sed -i '$a net.ipv6.all.accept_ra=0' ${sysctl_conf}
sed -i '$a net.ipv6.all.accept_ra=0' ${sysctl_d}
sysctl -w net.ipv6.all.accept_ra=0

# 125 預設網路介面阻擋IPv6路由器公告訊息
sed -i '$a net.ipv6.conf.default.accept_ra=0' ${sysctl_conf}
sed -i '$a net.ipv6.conf.default.accept_ra=0' ${sysctl_d}
sysctl -w net.ipv6.conf.default.accept_ra=0

sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv6.route.flush=1

# 126 DCCP協定
touch /etc/modprobe.d/dccp.conf
sed -i '$a install dccp /bin/true' /etc/modprobe.d/dccp.conf
sed -i '$a blacklist dccp' /etc/modprobe.d/dccp.conf

# 127 SCTP協定
touch /etc/modprobe.d/sctp.conf
sed -i '$a install sctp /bin/true' /etc/modprobe.d/sctp.conf
sed -i '$a blacklist sctp' /etc/modprobe.d/sctp.conf

# 128 RDS協定
touch /etc/modprobe.d/rds.conf
sed -i '$a install rds /bin/true' /etc/modprobe.d/rds.conf
sed -i '$a blacklist rds' /etc/modprobe.d/rds.conf

# 129 TIPC協定
touch /etc/modprobe.d/tipc.conf
sed -i '$a install tipc /bin/true' /etc/modprobe.d/tipc.conf
sed -i '$a blacklist tipc' /etc/modprobe.d/tipc.conf

# 130 停用無線網路介面
nmcli radio all off

# 131 網路介面混雜模式


# 日誌與稽核
echo "=========================="
echo "======= LOG Config ======="
echo "=========================="

# 132 install auditd package
dnf install audit audit-libs

# 133 enable auditd service
systemctl start auditd
systemctl --now enable auditd

# 134 稽核auditd服務啟動前之程序
sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\("\)/\1 audit=1\2/' /etc/default/grub

# 135 稽核待辦事項數量限制
sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\("\)/\1 audit_backlog_limit=8192\2/' /etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg

# 136 稽核處理失敗時通知系統管理者
sed -i '$a postmaster:\troot' /etc/aliases

# 137 稽核日誌檔案所有權
grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | xargs -I {} chown root:root {}

# 138 稽核日誌檔案權限
grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | xargs -I {} chmod 600 {}

# 139 稽核日誌目錄所有權
grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | sed 's,/[^/]*$,,' | uniq | xargs -I {} chown root:root {}

# 140 稽核日誌目錄權限
grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | sed 's,/[^/]*$,,' | uniq | xargs -I {} chmod 700 {}

# 141 稽核規則檔案權限
chmod 600 /etc/audit/rules.d/audit.rules

# 142 稽核設定檔案權限
chmod 640 /etc/audit/auditd.conf

# 143 稽核工具權限

# 144 稽核工具所有權

# 145 保護稽核工具

# 146 稽核日誌檔案大小上限
sed -i 's/max_log_file = 8/max_log_file = 32/g' /etc/audit/auditd.conf

# 147 稽核日誌達到其檔案大小上限之行為
sed -i 's/max_log_file_action = ROTATE/max_log_file_action = keep_logs/g' /etc/audit/auditd.conf

auditrules='/etc/audid/rules.d/audit.rules'

# 148 紀錄系統管理者活動 啟用
sed -i '$a -w /etc/sudoers -p wa -k scope' ${auditrules}
sed -i '$a -w /etc/sudoers.d/ -p wa -k scope' ${auditrules}

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

# 223 通行碼