# 系統設定與維護
echo "TASK [類別 系統設定與維護] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 系統設定與維護] ****************************************" >> ${FCB_ERROR}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_ERROR}

# 34 設定sudo指令使用pty
echo "34 設定sudo指令使用pty"
sudoerspath='/etc/sudoers'
index=1
while IFS= read -r line; do
    sudoers[$index]="$line"
    if grep "${sudoers[${index}]}" ${sudoerspath} >/dev/null; then
        echo "檢查OK"
    else
        sed -i '$a '"${sudoers[${index}]}" ${sudoerspath}
        echo "已新增"${sudoers[${index}]}
    fi
    index=$((index + 1))
done <<EOF
##設定sudo指令使用pty
Defaults use_pty
##sudo自訂義日誌檔案
Defaults logfile="/var/log/sudo.log"
EOF

# 35 啟用sdudo自訂義日誌檔案
echo "35 sudo自訂義日誌檔案系統"
if grep ^Defaults.*logfile=\"\/var\/log\/sudo.log\" /etc/sudoers >/dev/null; then
    if [ -f '/var/log/sudo.log' ]; then
        if stat -c "%U %G" /var/log/sudo.log | grep -E root.*root >/dev/null; then
            if stat -c "%a" /var/log/sudo.log | grep 600 >/dev/null; then
                echo 'OK: 35 sudo自訂義日誌檔案系統' >> ${FCB_SUCCESS}
            else
                chmod 600 /var/log/sudo.log
            fi
        else
            chown root:root /var/log/sudo.log
        fi
    else
        touch /var/log/sudo.log
        chown root:root /var/log/sudo.log
        chmod 600 /var/log/sudo.log
    fi
else
    sed -i '$a Defaults logfile="varlogsudo.log"' /etc/sudoers
    touch /var/log/sudo.log
    chown root:root /var/log/sudo.log
    chmod 600 /var/log/sudo.log
fi

# 36 安裝AIDE套件
echo "36 安裝AIDE套件"
if rpm -q aide >/dev/null 2>&1; then
    echo 'aide package sudo is installed'
else
    dnf install -y aide
    aide --init
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
fi

# 37 每天定期檢查檔案系統完整性
echo "37 每天定期檢查檔案系統完整性"
if [ -f '/var/spool/cron/root' ]; then
    if grep ^.*\/usr\/sbin\/aide.*--check /var/spool/cron/root >/dev/null; then
        echo 'OK: 37 定期檢查檔案系統完整性' >> ${FCB_SUCCESS}
    else
        sed -i '$a 0 5 * * * /usr/sbin/aide --check' /var/spool/cron/root
    fi
else
    touch /var/spool/cron/root
    chmod 600 root
    echo "# 檢查檔案系統完整性" >> /var/spool/cron/root
    sed -i '$a 0 5 * * * /usr/sbin/aide --check' /var/spool/cron/root
fi

if stat -c "%a" /boot/grub2/grub.cfg | grep [0-6][0][0] >/dev/null; then
    echo "OK: 39 開機載入程式設定檔案 grub.cfg 檔案權限" >> ${FCB_SUCCESS}
else
    chmod 600 /boot/grub2/grub.cfg
fi
if stat -c "%a" /boot/grub2/grubenv | grep [0-6][0][0] >/dev/null; then
    echo "OK: 39 開機載入程式設定檔案 grubenv 檔案權限" >> ${FCB_SUCCESS}
else
    chmod 600 /boot/grub2/grubenv
fi

echo '42 核心傾印功能'
if grep ^hard.*core.*0 /etc/security/limits.conf >/dev/null; then
    echo "OK: 42 hard core 0"
else
    sed -i '$a hard core 0' /etc/security/limits.conf
fi
if sysctl -a | grep ^fs.suid_dumpable.*=.*0$ >/dev/null; then
    echo "OK: 42 fs.suid_dumpable=0"
else
    sysctl -w fs.suid_dumpable=0
fi
if grep ^Storage=none$ /etc/systemd/coredump.conf >/dev/null; then
    echo "OK: 42 Storage=none"
else    
    sed -i 's/\#Storage=external/Storage=none/g' /etc/systemd/coredump.conf
fi
if grep ^ProcessSizeMax=0$ /etc/systemd/coredump.conf >/dev/null; then
    echo 'OK: 42 ProcessSizeMax=0' >> ${FCB_SUCCESS}
else
    sed -i 's/\#ProcessSizeMax=2G/ProcessSizeMax=0/g' /etc/systemd/coredump.conf
fi

echo '44 設定全系統加密原則'
if grep -E -i '^\s*(FUTURE|FIPS)\s*(\s+#.*)?$' /etc/crypto-policies/config >/dev/null; then
    echo 'OK: 44 設定全系統加密原則' >> ${FCB_SUCCESS}
else
    update-crypto-policies --set FUTURE
    update-crypto-policies
fi