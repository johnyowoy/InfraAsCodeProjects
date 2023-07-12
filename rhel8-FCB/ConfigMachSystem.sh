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
        sed -i 's/^gpgcheck=0/^gpgcheck=1/g' /etc/yum.conf
        echo "/etc/yum.conf 已修改 GPG簽章驗證OK!" >> ${FCB_LOG_SUCCESS}
    else
        sed -i '$a gpgcheck=1' /etc/yum.conf >> ${FCB_LOG_FAILED}
        echo "/etc/yum.conf 已新增 GPG簽章驗證!" >> ${FCB_LOG_FAILED}
    fi
    if grep -q "gpgcheck=1" /etc/dnf/dnf.conf; then
        echo "/etc/dnf/dnf.conf GPG簽章驗證OK!" >> ${FCB_LOG_SUCCESS}
    elif grep -q "gpgcheck=0" /etc/dnf/dnf.conf; then
        sed -i 's/^gpgcheck=0/^gpgcheck=1/g' /etc/dnf/dnf.conf
        echo "/etc/dnf/dnf.conf 已修改 GPG簽章驗證OK!" >> ${FCB_LOG_SUCCESS}
    else
        sed -i '$a gpgcheck=1' /etc/dnf/dnf.conf >> ${FCB_LOG_FAILED}
        echo "/etc/dnf/dnf.conf 已新增 GPG簽章驗證!" >> ${FCB_LOG_FAILED}
    fi

    # 33 安裝sudo套件
    echo "33 安裝sudo package"
    if rpm -q sudo >/dev/null 2>&1; then
        echo 'sudo package sudo is installed'
    else
        dnf install -y sudo
    fi

    # 34 設定sudo指令使用pty
    # 35 啟用sdudo自訂義日誌檔案
    echo "34 設定sudo指令使用pty"
    echo "35 sudo自訂義日誌檔案 啟用"
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
Defaults logfile="sudo.log"
EOF

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
    # 82 使用者家目錄之「.」檔案權限
    # 83 使用者家目錄之「.forward」檔案權限
    # 84 使用者家目錄之「.netrc」檔案權限
    # 85 使用者家目錄之「.rhosts」檔案權限
    getent passwd | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | while read line; do
        user=$(echo $line | cut -d: -f1)
        homepath=$(sh -c "echo ~$user")
        # 80 使用者家目錄擁有者
        chown $user:$user $homepath
        # 82 使用者家目錄之「.」檔案權限
        cd $homepath
        chmod 700 .
        # 83 使用者家目錄之「.forward」檔案權限
        if [ -f ".forward" ]; then
            rm .forward
        else
            echo "$user file .forward not exists."
        fi
        # 84 使用者家目錄之「.netrc」檔案權限
        if [ -f ".netrc" ]; then
            rm .netrc
        else
            echo "$user file .netrc not exists."
        fi
        # 85 使用者家目錄之「.rhosts」檔案權限
        if [ -f ".rhosts" ]; then
            rm .rhosts
        else
            echo "$user file .rhosts not exists."
        fi
    done
}
ConfigurationAndMaintenanceInSystem