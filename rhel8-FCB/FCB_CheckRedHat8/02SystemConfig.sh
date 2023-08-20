# 系統設定與維護
# 符合FCB規範
FCB_SUCCESS="/root/FCB_DOCS/TCBFCB_SuccessCheck-$(date '+%Y%m%d').log"
# 需修正檢視
FCB_FIX="/root/FCB_DOCS/TCBFCB_FixCheck-$(date '+%Y%m%d').log"
# 執行異常錯誤
FCB_ERROR="/root/FCB_DOCS/TCBFCB_ErrorCheck-$(date '+%Y%m%d').log"
# 顯示日期時間
echo "$(date '+%Y/%m/%d %H:%M:%S')" >> ${FCB_SUCCESS}
echo "$(date '+%Y/%m/%d %H:%M:%S')" >> ${FCB_FIX}

echo "TASK [類別 系統設定與維護] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 系統設定與維護] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo "32 GPG簽章驗證"
if grep -q "gpgcheck=1" /etc/yum.conf; then
    echo "OK: 32 GPG簽章驗證" >> ${FCB_SUCCESS}
else
    echo "FIX: 32 GPG簽章驗證!" >> ${FCB_FIX}
    echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
    cat /etc/yum.conf | grep gpgcheck=.* >> ${FCB_FIX}
    echo "====== FCB設定建議值 ======" >> ${FCB_FIX}
    echo "gpgcheck=1" >> ${FCB_FIX}
fi
if [ -f "/etc/dnf.conf" ]; then
    if grep -q "gpgcheck=1" /etc/dnf/dnf.conf; then
        echo "OK: 32 GPG簽章驗證 (dnf)!" >> ${FCB_SUCCESS}
    else
        echo "FIX: 32 GPG簽章驗證 (dnf)" >> ${FCB_FIX}
        echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
        cat /etc/dnf.conf | grep gpgcheck=.* >> ${FCB_FIX}
        echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
        echo "gpgcheck=1" >> ${FCB_FIX}
    fi
else
    echo "/etc/dnf.conf file not found, no set!"
fi

# 33 安裝sudo套件
echo "33 安裝sudo package"
if rpm -q sudo >/dev/null 2>&1; then
    echo 'OK: 33 sudo 套件' >> ${FCB_SUCCESS}
else
    cat << EOF >> ${FCB_FIX}

FIX: 33 sudo 套件
====== 不符合FCB規範 ======
$(rpm -q sudo)
====== FCB建議設定值 ======
安裝sudo package
EOF
fi

# 34 設定sudo指令使用pty
echo "34 設定sudo指令使用pty"
if grep ^Defaults.*use_pty /etc/sudoers >/dev/null; then
    echo 'OK: 34 設定sudo指令使用pty' >> ${FCB_SUCCESS}
else
    cat << EOF >> ${FCB_FIX}

FIX: 34 設定sudo指令使用pty
====== 不符合FCB規範 ======
/etc/sudoers檔案內容尚未設定 Defaults use_pty
====== FCB建議設定值 ======
Defaults use_pty
====== FCB設定方法值 ======
# /etc/sudoers檔案或 /etc/sudoers.d/目錄下的檔案，新增以下內容：
Defaults use_pty
EOF
fi

# 35 啟用sdudo自訂義日誌檔案
echo "35 sudo自訂義日誌檔案系統"
if grep ^Defaults.*logfile=\"\/var\/log\/sudo.log\" /etc/sudoers >/dev/null; then
    if [ -f '/var/log/sudo.log' ]; then
        if stat -c "%U %G" /var/log/sudo.log | grep -E root.*root >/dev/null; then
            if stat -c "%a" /var/log/sudo.log | grep 600 >/dev/null; then
                echo 'OK: 35 sudo自訂義日誌檔案系統' >> ${FCB_SUCCESS}
            else
                echo "FIX: 35 sudo自訂義日誌檔案系統" >> ${FCB_FIX}
                echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
                stat -c "檔案名稱 %n 檔案權限 %a" /var/log/sudo.log >> ${FCB_FIX}
                echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
                echo "chmod 600 /var/log/sudo.log" >> ${FCB_FIX}
            fi
        else
            echo "FIX: 35 sudo自訂義日誌檔案系統" >> ${FCB_FIX}
            echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
            stat -c "檔案名稱 %n 檔案擁有者 %U 檔案群組 %G" /var/log/sudo.log >> ${FCB_FIX}
            echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
            echo "chown root:root /var/log/sudo.log" >> ${FCB_FIX}
        fi
    else
        echo "FIX: 35 sudo自訂義日誌檔案系統" >> ${FCB_FIX}
        echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
        echo "/var/log/sudo.log 檔案不存在" >> ${FCB_FIX}
        echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
        echo "touch /var/log/sudo.log" >> ${FCB_FIX}
    fi
else
    echo "FIX: 35 sudo自訂義日誌檔案系統" >> ${FCB_FIX}
    echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
    echo "檢查/etc/sudoers檔案內容尚未設定 Defaults logfile=/var/log/sudo.log" >> ${FCB_FIX}
    echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
    echo "/etc/sudoers檔案新增以下內容：" >> ${FCB_FIX}
    echo "Defaults logfile=\"/var/log/sudo.log\"" >> ${FCB_FIX}
fi

# 36 安裝AIDE套件
echo "36 AIDE套件"
if rpm -q aide >/dev/null 2>&1; then
    echo 'OK: 36 aide package 已有安裝' >> ${FCB_SUCCESS}
else
    cat << EOF >> ${FCB_FIX}

FIX: 36 AIDE套件
====== 不符合FCB規範 ======
$(rpm -q aide)
====== FCB建議設定值 ======
# 安裝aide套件
dnf install aide
# 初始化aide
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
EOF
fi

# 37 每天定期檢查檔案系統完整性
echo "37 每天定期檢查檔案系統完整性"
if [ -f '/var/spool/cron/root' ]; then
    if grep ^.*\/usr\/sbin\/aide.*--check /var/spool/cron/root >/dev/null; then
        echo 'OK: 37 定期檢查檔案系統完整性' >> ${FCB_SUCCESS}
    else
        cat << EOF >> ${FCB_FIX}

FIX: 37 定期檢查檔案系統完整性
====== 不符合FCB規範 ======
尚未加入排成
====== FCB建議設定值 ======
# 設定每天5點進行檔案系統完整性檢查
====== FCB設定方法值 ======
crontab -u root -e
0 5 * * * /usr/sbin/aide --check
EOF
    fi
else
    cat << EOF >> ${FCB_FIX}

FIX: 37 定期檢查檔案系統完整性
====== 不符合FCB規範 ======
/var/spool/cron/root file does not exists.
====== FCB建議設定值 ======
# 設定每天5點進行檔案系統完整性檢查
====== FCB設定方法值 ======
crontab -u root -e
0 5 * * * /usr/sbin/aide --check
EOF
fi

# 38 39 開機載入程式設定檔 檔案擁有者與權限
echo "38 39 開機載入程式設定檔 檔案擁有者與權限"
if stat -c "%U %G" /boot/grub2/grub.cfg | grep -E root.*root >/dev/null; then
    echo "OK: 38 開機載入程式設定檔案 grub.cfg 檔案擁有者" >> ${FCB_SUCCESS}
else
    echo 'FIX: 38 開機載入程式設定檔案 grub.cfg 檔案擁有者' >> ${FCB_FIX}
    echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
    stat -c "檔案名稱 %n 檔案擁有者 %U 檔案群組 %G" /boot/grub2/grub.cfg >> ${FCB_FIX}
    echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
    echo "chown root:root /boot/grub2/grub.cfg" >> ${FCB_FIX}
fi
if stat -c "%U %G" /boot/grub2/grubenv | grep -E root.*root >/dev/null; then
    echo "OK: 38 開機載入程式設定檔案 grubenv 檔案擁有者" >> ${FCB_SUCCESS}
else
    echo 'FIX: 38 開機載入程式設定檔案 grubenv 檔案擁有者' >> ${FCB_FIX}
    echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
    stat -c "檔案名稱 %n 檔案擁有者 %U 檔案群組 %G" /boot/grub2/grubenv >> ${FCB_FIX}
    echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
    echo "chown root:root /boot/grub2/grubenv" >> ${FCB_FIX}
fi
if stat -c "%a" /boot/grub2/grub.cfg | grep [0-6][0][0] >/dev/null; then
    echo "OK: 39 開機載入程式設定檔案 grub.cfg 檔案權限" >> ${FCB_SUCCESS}
else
    echo 'FIX: 39 開機載入程式設定檔案 grub.cfg 檔案權限' >> ${FCB_FIX}
    echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
    stat -c "檔案名稱 %n 檔案權限 %a" /boot/grub2/grub.cfg >> ${FCB_FIX}
    echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
    echo "chmod 600 /boot/grub2/grub.cfg" >> ${FCB_FIX}
fi
if stat -c "%a" /boot/grub2/grubenv | grep [0-6][0][0] >/dev/null; then
    echo "OK: 39 開機載入程式設定檔案 grubenv 檔案權限" >> ${FCB_SUCCESS}
else
    echo 'FIX: 39 開機載入程式設定檔案 grubenv 檔案權限' >> ${FCB_FIX}
    echo "====== 不符合FCB規範 ======" >> ${FCB_FIX}
    stat -c "檔案名稱 %n 檔案權限 %a" /boot/grub2/grubenv >> ${FCB_FIX}
    echo "====== FCB建議設定值 ======" >> ${FCB_FIX}
    echo "chmod 600 /boot/grub2/grubenv" >> ${FCB_FIX}
fi

echo '40 開機載入程式之密碼'
if grep password_pbkdf2 /boot/grub2/grub.cfg >/dev/null || grep password_pbkdf2 /boot/efi/EFI/redhat/grub.cfg >/dev/null; then
    echo "OK: 40 開機載入程式之密碼" >> ${FCB_SUCCESS}
else
    cat << EOF >> ${FCB_FIX}

FIX: 40 開機載入程式之密碼
====== 不符合FCB規範 ======
密碼尚未設定
====== FCB建議設定值 ======
# 設定密碼
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，使用grub2-setpassword建立一組密碼：
grub2-setpassword
# Enter password: (輸入密碼)
# Confirm password: (再次輸入密碼)
# 執行以下指令更新grub2設定檔：
grub2-mkconfig -o /boot/grub2/grub.cfg
# 或者
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
EOF
fi

echo '41 單一使用者模式身分驗證'
if grep ^ExecStart=-\/usr\/lib\/systemd\/systemd-sulogin-shell.*rescue /usr/lib/systemd/system/rescue.service >/dev/null || grep ^ExecStart=-\/usr\/lib\/systemd\/systemd-sulogin-shell.*emergency /usr/lib/systemd/system/rescue.service >/dev/null; then
    echo 'OK: 41 單一使用者模式身分驗證' >> ${FCB_SUCCESS}
else
    cat << EOF >> ${FCB_FIX}

FIX: 41 單一使用者模式身分驗證
====== 不符合FCB規範 ======
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
# 編輯/usr/lib/systemd/system/rescue.service檔案，新增或修改成以下內容：
ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue
# 編輯/usr/lib/systemd/system/emergency.service檔案，新增或修改成以下內容：
ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency
EOF
fi

echo '42 核心傾印功能'
if grep ^hard.*core.*0 /etc/security/limits.conf >/dev/null; then
    if grep ^fs.suid_dumpable.*=.*0 /etc/sysctl.conf >/dev/null; then
        if grep ^Storage=none$ /etc/systemd/coredump.conf >/dev/null; then
            if grep ^ProcessSizeMax=0$ /etc/systemd/coredump.conf >/dev/null; then
                echo 'OK: 42 核心傾印功能' >> ${FCB_SUCCESS}
            else
                cat <<EOF >> ${FCB_FIX}

FIX: 42 核心傾印功能
====== 不符合FCB規範 ======
$(grep ProcessSizeMax /etc/systemd/coredump.conf)
====== FCB建議設定值 ======
ProcessSizeMax=0
====== FCB設定方法值 ======
# 編輯/etc/systemd/coredump.conf 檔案，修改以下內容：
ProcessSizeMax=0
EOF
            fi
        else
            cat <<EOF >> ${FCB_FIX}

FIX: 42 核心傾印功能
====== 不符合FCB規範 ======
$(grep Storage /etc/systemd/coredump.conf)
====== FCB建議設定值 ======
Storage=none
====== FCB設定方法值 ======
# 編輯/etc/systemd/coredump.conf 檔案，修改以下內容：
Storage=none
EOF
        fi
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 42 核心傾印功能
====== 不符合FCB規範 ======
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
# (方法一)編輯/etc/sysctl.conf 或/etc/sysctl.d/目錄下檔案，設定參數如下：
fs.suid_dumpable = 0
# (方法二)開啟終端機，執行以下指令，設定核心參數：
sysctl -w fs.suid_dumpable=0
EOF
    fi
else
    cat <<EOF >> ${FCB_FIX}

FIX: 42 核心傾印功能
====== 不符合FCB規範 ======
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
# 編輯/etc/security/limits.conf 檔案或/etc/security/limits.d/目錄下檔案，新增以下內容：
hard core 0
EOF
fi

echo '43 記憶體位址空間配置隨機載入'
if grep ^kernel.randomize_va_space.*=.*2 /etc/sysctl.conf >/dev/null; then
    echo 'OK: 43 記憶體位址空間配置隨機載入' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 43 記憶體位址空間配置隨機載入
====== 不符合FCB規範 ======
/etc/sysctl.conf 尚未設定記憶體位址空間配置隨機載入
====== FCB建議說明值 ======
# 隨機配置堆疊(Stack)、記憶體映射函數(mmap)、vDSO 頁面及堆積(Heap)
====== FCB建議設定值 ======
# 2
====== FCB設定方法值 ======
# (方法一)編輯/etc/sysctl.conf 或 /etc/sysctl.d/目錄下檔案，設定參數如下：
sysctl -w kernel.randomize_va_space = 2
# (方法二)開啟終端機，執行以下指令，設定核心參數：
sysctl -w kernel.randomize_va_space=2 >> /etc/sysctl.conf
EOF
fi

echo '44 設定全系統加密原則'
if grep -E -i '^\s*(FUTURE|FIPS)\s*(\s+#.*)?$' /etc/crypto-policies/config >/dev/null; then
    echo 'OK: 44 設定全系統加密原則' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 44 全系統加密原則
====== 不符合FCB規範 ======
$(cat /etc/crypto-policies/config)
====== FCB建議說明值 ======
# 設定全系統加密原則使用FUTURE 或 FIPS 原則，避免使用較舊且易被攻擊之加密演算法
# FUTURE: 採取保守之安全原則，可承受近期相關攻擊，不允許使用 SHA-1 演算法，要求 RSA 密鑰與Diffie-Hellman 金鑰至少為3,072 位元
# FIPS: 符合 FIPS140-2 要求原則，使用內建之 fipsmode-setup 工具，將作業系統切換到 FIPS 模式
====== FCB建議設定值 ======
# FUTURE 或 FIPS
====== FCB設定方法值 ======
# (方法一)執行以下指令，將系統設定為「FUTURE」原則：
update-crypto-policies --set FUTURE
# 接續執行以下指令，以套用更新後之全系統加密原則：
update-crypto-policies
# (方法二)執行以下指令，將系統設定為「FIPS」原則，並重新開機，以使生效：
fips-mode-setup --enable
EOF
fi

# 45~60
echo "45~60 檢查passwd shadow group gshadow 檔案擁有者 群組 權限"
index=1
while IFS= read -r line; do
    AuditTools[$index]="$line"
    if [ -f "/etc/${AuditTools[${index}]}" ]; then
        if stat -c "%U %G" /etc/${AuditTools[${index}]} | grep -E root.*root >/dev/null; then
            echo "OK: ${AuditTools[${index}]} 檔案擁有者與群組" >> ${FCB_SUCCESS}
        else
            cat <<EOF >> ${FCB_FIX}

FIX: ${AuditTools[${index}]} 檔案擁有者與群組
====== 不符合FCB規範 ======
$(stat -c "檔名%n 擁有者%U 群組%G" /etc/${AuditTools[${index}]})
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root ${AuditTools[${index}]}
EOF
        fi
    else
        echo "File /etc/${AuditTools[${index}]} does not exists" >> ${FCB_FIX}
    fi
    index=$((index + 1))
# 檔案擁有者與群組
done <<EOF
passwd
shadow
group
gshadow
passwd-
shadow-
group-
gshadow-
EOF

index=1
while IFS= read -r line; do
    AuditTools[$index]="$line"
    if [ -f "/etc/${AuditTools[${index}]}" ]; then
        if stat -c "%a" /etc/${AuditTools[${index}]} | grep [0-6][0-4][0-4] >/dev/null; then
            echo "OK: ${AuditTools[${index}]} 檔案權限" >> ${FCB_SUCCESS}
        else
            cat <<EOF >> ${FCB_FIX}

FIX: ${AuditTools[${index}]} 檔案擁有者與群組
====== 不符合FCB規範 ======
$(stat -c "檔名%n 權限%a" /etc/${AuditTools[${index}]})
====== FCB建議設定值 ======
# 644或更低權限
====== FCB設定方法值 ======
chmod 600 ${AuditTools[${index}]}
EOF
        fi
    else
        echo "File /etc/${AuditTools[${index}]} does not exists" >> ${FCB_FIX}
    fi
    index=$((index + 1))
# 檔案擁有者與群組
done <<EOF
passwd
group
passwd-
group-
EOF

index=1
while IFS= read -r line; do
    AuditTools[$index]="$line"
    if [ -f "/etc/${AuditTools[${index}]}" ]; then
        if stat -c "%a" /etc/${AuditTools[${index}]} | grep 0 >/dev/null; then
            echo "OK: /etc/${AuditTools[${index}]} 檔案權限" >> ${FCB_SUCCESS}
        else
            cat <<EOF >> ${FCB_FIX}

FIX: ${AuditTools[${index}]} 檔案擁有者與群組
====== 不符合FCB規範 ======
$(stat -c "檔名%n 權限%a" /etc/${AuditTools[${index}]})
====== FCB建議設定值 ======
# 000
====== FCB設定方法值 ======
chmod 0 ${AuditTools[${index}]}
EOF
        fi
    else
        echo "File /etc/${AuditTools[${index}]} does not exists" >> ${FCB_FIX}
    fi
    index=$((index + 1))
# 檔案擁有者與群組
done <<EOF
shadow
gshadow
shadow-
gshadow-
EOF

echo '61 其他使用者寫入具有全域寫入權限檔案'
# 檢查是否找到other具有可寫入權限的檔案
if [ -n "$(find / -xdev -type f -perm -0002)" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 61 其他使用者寫入具有全域寫入權限檔案
====== 不符合FCB規範 ======
# 以下檔案是other具有可寫入權限
$(find / -xdev -type f -perm -0002)
====== FCB建議設定值 ======
# 禁止寫入
====== FCB設定方法值 ======
# 根目錄找出具有全域寫入權限之檔案:
find / -xdev -type f -perm -0002
# 針對所找到之檔案，執行下列指令，以移除其他身分寫入權限：
chmod o-w (檔案名稱)
EOF
else
    echo 'OK: 61 其他使用者寫入具有全域寫入權限檔案' >> ${FCB_SUCCESS}
fi

echo '62 檢查所有檔案與目錄之「擁有者」'
# 找出/的所有檔案為不合法使用者
# 檢查/的所有檔案是否為合法使用者
if [ -n "$(find / -xdev -nouser)" ]; then
    echo '62 以下檔案為不合法使用者，請針對找到的檔案與目錄指定合法使用者或移除' >> ${FCB_FIX}
    echo '語法參考 chown (使用者) (檔案名稱或目錄名稱) 或是 rm (檔案名稱或目錄名稱)' >> ${FCB_FIX}
    echo "$files" >> ${FCB_FIX}
    echo '========== END ==========' >> ${FCB_FIX}
    cat <<EOF >> ${FCB_FIX}

FIX: 62 檢查所有檔案與目錄之「擁有者」
====== 不符合FCB規範 ======
# 以下檔案為不合法使用者，請針對找到的檔案與目錄指定合法使用者或移除
$(find / -xdev -nouser)
====== FCB建議設定值 ======
# 所有檔案與目錄擁有者皆為合法使用者
====== FCB設定方法值 ======
# 根目錄找出擁有者不是合法使用者之檔案或目錄：
find / -xdev -nouser
# 針對所找到之檔案與目錄指定合法使用者或移除：
chmod (使用者) (檔案名稱或目錄名稱)
或是
rm (檔案名稱或目錄名稱)
EOF
else
    echo 'OK: 62 檢查所有檔案與目錄之「擁有者」皆為合法使用者' >> ${FCB_SUCCESS}
fi

echo '63 檢查所有檔案與目錄之擁有「群組」'
# 找出/的所有檔案為不合法群組
# 檢查/的所有檔案是否為合法群組
if [ -n "$(find / -xdev -nogroup)" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 63 檢查所有檔案與目錄之擁有「群組」
====== 不符合FCB規範 ======
# 以下檔案為不合法群組，請針對找到的檔案與目錄指定合法群組或移除
$(find / -xdev -nogroup)
====== FCB建議設定值 ======
# 所有檔案與目錄擁有群組皆為合法群組
====== FCB設定方法值 ======
chgrp (群組) (檔案名稱或目錄名稱)
或是
rm (檔案名稱或目錄名稱)
=========================
EOF
else
    echo 'OK: 63 檢查所有檔案與目錄皆為合法群組' >> ${FCB_SUCCESS}
fi

echo '64 所有具有全域寫入權限目錄之擁有者'
# 找出/的所有具有全域寫入權限目錄之擁有者
# 檢查/的具有全域寫入權限目錄之擁有者
if [ -n "$(find / -xdev -type d -perm -0002 -uid +999 -print)" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 64 所有具有全域寫入權限目錄之擁有者
====== 不符合FCB規範 ======
# 以下目錄為具有全域寫入權限目錄之擁有者
$(find / -xdev -type d -perm -0002 -uid +999 -print)
====== FCB建議設定值 ======
# 請設定目錄擁有者為root或其他系統帳號
====== FCB設定方法值 ======
chown root (目錄名稱)
=========================
EOF
else
    echo 'OK: 64 檢查所有具有全域寫入權限目錄之擁有者皆為root或其他系統帳號' >> ${FCB_SUCCESS}
fi

echo '65 所有具有全域寫入權限目錄之擁有群組'
# 找出/的所有具有全域寫入權限目錄之擁有群組
# 檢查/的具有全域寫入權限目錄之擁有群組
if [ -n "$(find / -xdev -type d -perm -0002 -gid +999 -print)" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 65 所有具有全域寫入權限目錄之擁有群組
====== 不符合FCB規範 ======
以下目錄為具有全域寫入權限目錄之擁有群組
$(find / -xdev -type d -perm -0002 -gid +999 -print)
====== FCB建議設定值 ======
# root或其他系統群組
====== FCB設定方法值 ======
chgrp root (目錄名稱)
=========================
EOF
else
    echo 'OK: 65 檢查所有具有全域寫入權限目錄之擁有群組皆為root或其他系統群組' >> ${FCB_SUCCESS}
fi

echo '66 系統命令檔案權限'
# 找出/的所有具有全域寫入權限目錄之擁有群組
files=$(find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /0022 -exec ls -la {} \;)
# 檢查/的具有全域寫入權限目錄之擁有群組
if [ -n "${files}" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 66 系統命令檔案權限
====== 不符合FCB規範 ======
以下為系統命令檔案
${files}
====== FCB建議設定值 ======
# 755或更低權限
====== FCB設定方法值 ======
chmod 755 (系統命令檔案名稱)
=========================
EOF
else
    echo 'OK: 66 系統命令檔案權限' >> ${FCB_SUCCESS}
fi

echo '67 系統命令檔案擁有者'
files=$(find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -exec ls -la {} \;)
if [ -n "${files}" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 67 系統命令檔案擁有者
====== 不符合FCB規範 ======
以下為「系統命令檔案」
${files}
====== FCB建議設定值 ======
# # 請針對找到的系統命令檔案設定「擁有者為root」
====== FCB設定方法值 ======
chown root (系統命令檔案名稱)
=========================
EOF
else
    echo 'OK: 67 系統命令檔案擁有者' >> ${FCB_SUCCESS}
fi

echo '68 系統命令檔案擁有群組'
files=$(find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -exec ls -la {} \;)
if [ -n "${files}" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 68 系統命令檔案擁有群組
====== 不符合FCB規範 ======
以下為「系統命令檔案」
${files}
====== FCB建議設定值 ======
# 請針對找到的系統命令檔案設定「群組擁有者為root」
====== FCB設定方法值 ======
chgrp root (系統命令檔案名稱)
=========================
EOF
else
    echo 'OK: 68 系統命令檔案擁有群組' >> ${FCB_SUCCESS}
fi

echo '69 程式庫檔案權限'
files="$(find -L /lib /lib64 /usr/lib64 -perm /0022 -type f -exec ls -al {} \;)"
if [ -n "${files}" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 69 程式庫檔案權限
====== 不符合FCB規範 ======
以下為「程式庫檔案」
${files}
====== FCB建議設定值 ======
# 請針對找到的程式庫檔案設定「權限更改為755或更低權限」
====== FCB設定方法值 ======
chmod 755 (程式庫檔案名稱)
=========================
EOF
else
    echo 'OK: 69 程式庫檔案權限' >> ${FCB_SUCCESS}
fi

echo '70 程式庫檔案擁有者'
files=$(find -L /lib /lib64 /usr/lib64 ! -user root -exec ls -al {} \;)
if [ -n "$files" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 70 程式庫檔案擁有者
====== 不符合FCB規範 ======
以下為「程式庫檔案」
${files}
====== FCB建議設定值 ======
# 請針對找到的程式庫檔案設定「擁有者更改為root」
====== FCB設定方法值 ======
chown root (程式庫檔案名稱)
=========================
EOF
else
    echo 'OK: 70 程式庫檔案擁有者' >> ${FCB_SUCCESS}
fi

echo '71 程式庫檔案擁有群組'
files=$(find -L /lib /lib64 /usr/lib64 ! -group root -exec ls -al {} \;)
if [ -n "$files" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 71 程式庫檔案擁有群組
====== 不符合FCB規範 ======
以下為「程式庫檔案」
${files}
====== FCB建議設定值 ======
# 請針對找到的程式庫檔案設定「擁有群組更改為root」
====== FCB設定方法值 ======
chgrp root (程式庫檔案名稱)
=========================
EOF
else
    echo 'OK: 71 程式庫檔案擁有群組' >> ${FCB_SUCCESS}
fi

echo '72 帳號不使用空白密碼'
emptyfiles=$(awk -F: '($2 == "" ) { print $1 " does not have a password "}' /etc/shadow)
if [ -n "$emptyfiles" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 72 帳號不使用空白密碼
====== 不符合FCB規範 ======
以下帳號尚未設定密碼或鎖定
${emptyfiles}
====== FCB建議設定值 ======
# 帳號必須具有通行碼或被鎖定
====== FCB設定方法值 ======
# 設定帳號通行碼
passwd (帳號名稱)
# 或是
# 鎖定帳號
passwd -l (帳號名稱)
=========================
EOF
else
    echo 'OK: 72 帳號已具有密碼或鎖定' >> ${FCB_SUCCESS}
fi

echo '73 root帳號的路徑變數'
RPCV="$(sudo -Hiu root env | grep '^PATH=' | cut -d= -f2)"
RPCV2="$(echo "$RPCV" | grep -q "::" && echo "root's path contains a empty directory (::)")"
RPCV3="$(echo "$RPCV" | grep -q ":$" && echo "root's path contains a trailing (:)")"
if [ "$RPCV2" ]; then
    echo '73 root帳號 PATH有異常, 請手動修正' >> ${FCB_FIX}
    echo "${RPCV2}" >> ${FCB_FIX}
    echo '========== END ==========' >> ${FCB_FIX}
else
    echo '73 root PATH 檢查OK' >> ${FCB_SUCCESS}
fi
if [ "$RPCV3" ]; then
    echo '73 root帳號 PATH有異常, 請手動修正' >> ${FCB_FIX}
    echo "${RPCV3}" >> ${FCB_FIX}
    echo '========== END ==========' >> ${FCB_FIX}
else
    echo '73 root PATH 檢查OK' >> ${FCB_SUCCESS}
fi

echo '74 root帳號路徑變數不包含world-writable或group-writable目錄'
RPCV="$(sudo -Hiu root env | grep '^PATH=' | cut -d= -f2)"
for x in $(echo "$RPCV" | tr ":" " "); do
    if [ -d "$x" ]; then
        ls -ldH "$x" | awk 'substr($1,6,1) != "-" {print $9, "is group writable"}
        substr($1,9,1) != "-" {print $9, "is world writable"}'
    else
        echo "$x is not a directory" >> ${FCB_SUCCESS}
    fi
done

echo << EOF
75 passwd不允許存在「+」符號
76 shadow不允許存在「+」符號
77 group不允許存在「+」符號
EOF
index=1
while IFS= read -r line; do
    auditlog[$index]="$line"
    if grep '^\+' ${auditlog[$index]} >/dev/null; then
        echo "${auditlog[$index]} 字首存在「+」符號，請移除" >> ${FCB_FIX}
        grep -n '^\+' ${auditlog[$index]} >> ${FCB_FIX}
        echo '========== END ==========' >> ${FCB_FIX}
    else
        echo "${auditlog[${index}]}不存在「+」符號, 檢查OK" >> ${FCB_SUCCESS}
    fi
    index=$((index + 1))
done <<EOF
/etc/passwd
/etc/shadow
/etc/group
EOF

echo '78 UID=0之帳號'
emptyfiles=$(awk -F: '($3 == 0 ) { print $1}' /etc/passwd | grep -v root)
if [ -n "$emptyfiles" ]; then
    echo '78 以下帳號UID=0, 是具有系統管理權限' >> ${FCB_FIX}
    echo "$emptyfiles" >> ${FCB_FIX}
    echo '========== END ==========' >> ${FCB_FIX}
else
    echo '78 無其他帳號UID=0' >> ${FCB_SUCCESS}
fi

# 79 使用者家目錄權限
# 取得所有使用者清單，nologin /bin/false, root不用顯示
getent passwd | cut -d ':' -f 1,6,7 | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | cut -d ':' -f 2 | while read line; do
    homepath=$(echo $line | cut -d: -f1)
    if stat -c "%a" $homepath | grep 700 >/dev/null; then
        echo "79 使用者家目錄($homepath)權限檢查OK" >> ${FCB_SUCCESS}
    else
        echo "79 使用者家目錄($homepath), 不符合FCB規範" >> ${FCB_FIX}
        echo "79 群組不具寫入(g-w)權限, 其他使用者不具讀取、寫入及執行(o-rwx)權限" >> ${FCB_FIX}
    fi
done

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
        echo "$user 家目錄存在.forward, 請移除" >> ${FCB_FIX}
    else
        echo "$user home, file .forward not exists." >> ${FCB_SUCCESS}
    fi
    # 84 使用者家目錄之「.netrc」檔案權限
    if [ -f ".netrc" ]; then
        echo "$user 家目錄存在.netrc, 請移除" >> ${FCB_FIX}
    else
        echo "$user home, file .netrc not exists." >> ${FCB_SUCCESS}
    fi
    # 85 使用者家目錄之「.rhosts」檔案權限
    if [ -f ".rhosts" ]; then
        echo "$user 家目錄存在.rhosts, 請移除" >> ${FCB_FIX}
    else
        echo "$user home, file .rhosts not exists." >> ${FCB_SUCCESS}
    fi
done

echo '86 檢查/etc/passwd檔案設定的群組'
for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
    grep -q -P "^.*?:[^:]*:$i:" /etc/group
    if [ $? -ne 0 ]; then
        echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group" >> ${FCB_FIX}
    fi
done

echo '87 唯一的UID'
cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x ; do
    [ -z "$x" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
        users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
        echo "87 有相同UID, Duplicate UID ($2): $users" >> ${FCB_FIX}
        echo "語法指令參考 usermod -u (UID) (帳號名稱)" >> ${FCB_FIX}
        echo '========== END ==========' >> ${FCB_FIX}
    fi
done

echo '88 唯一的GID'
cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do
echo "88 有相同的GID, Duplicate GID ($x) in /etc/group" >> ${FCB_FIX}
echo "語法指令參考 groupmod -g (GID) (群組名稱)"
echo '========== END ==========' >> ${FCB_FIX}
done

echo '89 唯一的使用者帳號名稱'
cut -d: -f1 /etc/passwd | sort | uniq -d | while read x ; do
echo "89 偵測到相同使用者帳號名稱, Duplicate login name ${x} in /etc/passwd" >> ${FCB_FIX}
echo '========== END ==========' >> ${FCB_FIX}
done

echo '90 唯一的群組名稱'
cut -d: -f1 /etc/group | sort | uniq -d | while read x ; do
echo "90 偵測到相同群組名稱, Duplicate group name ${x} in /etc/group" >> ${FCB_FIX}
echo '========== END ==========' >> ${FCB_FIX}
done

echo '91 shadow群組成員'
if awk -F: '($1=="shadow")' /etc/group >/dev/null; then
    echo '91 shadow不能包含任何使用者 請移除此使用者' >> ${FCB_FIX}
    awk -F: '($1=="shadow")' /etc/group >> ${FCB_FIX}
else
    echo '91 shadow群組成員無使用者 檢查ok' >> ${FCB_SUCCESS}
fi
