# 系統設定與維護
echo "CHECK [類別 系統設定與維護] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 系統設定與維護] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

echo "32 GPG簽章驗證(yum)"
if grep -q "gpgcheck=1" /etc/yum.conf; then
    echo "OK: 32 GPG簽章驗證" >> ${FCB_SUCCESS}
else
    cat << EOF >> ${FCB_FIX}
FIX: 32 GPG簽章驗證(yum)
====== 不符合FCB規範 ======
$(cat /etc/yum.conf | grep gpgcheck=.*)
====== FCB設定建議值 ======
gpgcheck=1
====== FCB設定方法值 ======
# /etc/yum.conf檔案，修改以下內容：
gpgcheck=1
EOF
fi
if [ -f "/etc/dnf.conf" ]; then
    if grep -q "gpgcheck=1" /etc/dnf/dnf.conf; then
        echo "OK: 32 GPG簽章驗證 (dnf)!" >> ${FCB_SUCCESS}
    else
        cat << EOF >> ${FCB_FIX}
FIX: 32 GPG簽章驗證 (dnf)
====== 不符合FCB規範 ======
$(cat /etc/dnf.conf | grep gpgcheck=.*)
====== FCB建議設定值 ======
gpgcheck=1
====== FCB設定方法值 ======
# /etc/dnf.conf檔案，修改以下內容：
gpgcheck=1
EOF
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
    cat << EOF >> ${FCB_FIX}
FIX: 35 sudo自訂義日誌檔案系統
====== 不符合FCB規範 ======
檢查/etc/sudoers檔案內容尚未設定 Defaults logfile=/var/log/sudo.log
====== FCB建議設定值 ======
/etc/sudoers檔案新增以下內容：
Defaults logfile="/var/log/sudo.log"
EOF
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
    echo 'OK: 42 核心傾印功能' >> ${FCB_SUCCESS}
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

if sysctl -a | grep ^fs.suid_dumpable.*=.*0$ >/dev/null; then
    echo 'OK: 42 核心傾印功能' >> ${FCB_SUCCESS}
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

if grep ^Storage=none$ /etc/systemd/coredump.conf >/dev/null; then
    echo 'OK: 42 核心傾印功能' >> ${FCB_SUCCESS}
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
# ===============================================
echo '43 記憶體位址空間配置隨機載入'
if sysctl -a | grep ^kernel.randomize_va_space.*=.*2$ >/dev/null; then
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

echo '45 /etc/passwd檔案所有權'
if stat -c "%U %G" /etc/passwd | grep -E ^root.*root$ >/dev/null; then
    echo 'OK: 45 /etc/passwd檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 45 /etc/passwd檔案所有權
====== 不符合FCB規範 ======
$(stat -c "檔案名稱: %n, 檔案擁有者: %U, 檔案群組: %G" /etc/passwd)
====== FCB建議設定值 ======
# 檔案擁有者 root:root
====== FCB設定方法值 ======
chown root:root /etc/passwd
EOF
fi

echo '46 /etc/passwd檔案權限'
if stat -c "%a" /etc/passwd | grep -E [0-6][0-4][0-4] >/dev/null; then
    echo 'OK: 46 /etc/passwd檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 46 /etc/passwd檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n %a" /etc/passwd)
====== FCB建議設定值 ======
# 644或更低權限
====== FCB設定方法值 ======
chmod 644 /etc/passwd
EOF
fi

echo '47 /etc/shadow檔案所有權'
if stat -c "%U %G" /etc/shadow | grep -E ^root.*root$ >/dev/null || stat -c "%U %G" /etc/shadow | grep -E ^root.*shadow$ >/dev/null; then
    echo 'OK: 47 /etc/shadow檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 47 /etc/shadow檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%a, %U:%G" /etc/shadow)
====== FCB建議設定值 ======
# root:root或root:shadow
====== FCB設定方法值 ======
chown root:root /etc/shadow
或
chown root:shadow /etc/shadow
EOF
fi

echo '48 /etc/shadow檔案權限'
if stat -c "%a" /etc/shadow | grep -E 0 >/dev/null; then
    echo 'OK: 48 /etc/shadow檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 48 /etc/shadow檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/shadow)
====== FCB建議設定值 ======
# 0
====== FCB設定方法值 ======
chmod 0 /etc/shadow
EOF
fi

echo '49 /etc/group檔案所有權'
if stat -c "%U %G" /etc/group | grep -E ^root.*root$ >/dev/null; then
    echo 'OK: 49 /etc/group檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 49 /etc/group檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%n, %U:%G" /etc/group)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/group
EOF
fi

echo '50 /etc/group檔案權限'
if stat -c "%a" /etc/group | grep [0-6][0-4][0-4] >/dev/null; then
    echo 'OK: 50 /etc/group檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 50 /etc/group檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/group)
====== FCB建議設定值 ======
# 檔案權限為644或更低權限
====== FCB設定方法值 ======
chmod 644 /etc/group
EOF
fi

echo '51 /etc/gshadow檔案所有權'
if stat -c "%U %G" /etc/gshadow | grep -E ^root.*root$ >/dev/null; then
    echo 'OK: 51 /etc/gshadow檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 51 /etc/gshadow檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/gshadow)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chmod root:root /etc/gshadow
EOF
fi

echo '52 /etc/gshadow檔案權限'
if stat -c "%a" /etc/gshadow | grep 0 >/dev/null; then
    echo 'OK: 52 /etc/gshadow檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 52 /etc/gshadow檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/gshadow)
====== FCB建議設定值 ======
# 000
====== FCB設定方法值 ======
chmod 0 /etc/gshadow
EOF
fi

echo '53 /etc/passwd-檔案所有權'
if stat -c "%U %G" /etc/passwd- | grep -E ^root.*root$ >/dev/null; then
    echo 'OK: 53 /etc/passwd-檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 53 /etc/passwd-檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%n, %U:%G" /etc/passwd-)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/passwd-
EOF
fi

echo '54 /etc/passwd-檔案權限'
if stat -c "%a" /etc/passwd- | grep [0-6][0-4][0-4] >/dev/null; then
    echo 'OK: 54 /etc/passwd-檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 54 /etc/passwd-檔案權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/passwd-)
====== FCB建議設定值 ======
# 644或是更低權限
====== FCB設定方法值 ======
chmod 600 /etc/passwd-
EOF
fi

echo '55 /etc/shadow-檔案所有權'
if stat -c "%U %G" /etc/shadow- | grep -E ^root.*root$ >/dev/null || stat -c "%U %G" /etc/shadow- | grep -E ^root.*shadow$ >/dev/null; then
    echo 'OK: 55 /etc/shadow-檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 55 /etc/shadow-檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/shadow-)
====== FCB建議設定值 ======
# root:root或root:shadow
====== FCB設定方法值 ======
chown root:root /etc/shadow-
或
chown root:shadow /etc/shadow-"
EOF
fi

echo '56 /etc/shadow-檔案權限'
if stat -c "%a" /etc/shadow- | grep 0 >/dev/null; then
    echo 'OK: 56 /etc/shadow-檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 56 /etc/shadow-檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/shadow-)
====== FCB建議設定值 ======
# 檔案的權限為000
====== FCB設定方法值 ======
chmod 0 /etc/shadow-
EOF
fi

echo '57 /etc/group-檔案所有權'
if stat -c "%U %G" /etc/group- | grep -E ^root.*root$ >/dev/null; then
    echo 'OK: 57 /etc/group-檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 57 /etc/group-檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%n, %U:%G" /etc/group-)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chmod root:root /etc/group-
EOF
fi

echo '58 /etc/group-檔案權限'
if stat -c "%a" /etc/group- | grep [0-6][0-4][0-4] >/dev/null; then
    echo 'OK: 58 /etc/group-檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 58 /etc/group-檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/group-)
====== FCB建議設定值 ======
# 644或更低權限
====== FCB設定方法值 ======
chmod 644 /etc/group-
EOF
fi

echo '59 /etc/gshadow-檔案所有權'
if stat -c "%U %G" /etc/gshadow- | grep -E ^root.*root$ >/dev/null; then
    echo 'OK: 59 /etc/gshadow-檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 59 /etc/gshadow-檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%n, %U:%G" /etc/gshadow-)
====== FCB建議設定值 ======
# root:root或root:shadow
====== FCB設定方法值 ======
chown root:root /etc/gshadow-
或
chown root:shadow /etc/gshadow-
EOF
fi

echo '60 /etc/gshadow-檔案權限'
if stat -c "%a" /etc/gshadow- | grep 0 >/dev/null; then
    echo 'OK: 60 /etc/gshadow-檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 60 /etc/gshadow-檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/gshadow-)
====== FCB建議設定值 ======
# 檔案的權限為000
====== FCB設定方法值 ======
chmod 0 /etc/gshadow-
EOF
fi

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
# 請針對找到的系統命令檔案設定「擁有者為root」
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
files=$(find -L /lib /lib64 /usr/lib /usr/lib64 ! -group root -exec ls -la {} \;)
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
    echo 'OK: 73 root PATH' >> ${FCB_SUCCESS}
fi
if [ "$RPCV3" ]; then
    echo '73 root帳號 PATH有異常, 請手動修正' >> ${FCB_FIX}
    echo "${RPCV3}" >> ${FCB_FIX}
    echo '========== END ==========' >> ${FCB_FIX}
else
    echo 'OK: 73 root PATH' >> ${FCB_SUCCESS}
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

echo '75 passwd不允許存在「+」符號'
if grep '^\+:' /etc/passwd >/dev/null; then
        cat <<EOF >> ${FCB_FIX}

FIX: 75 passwd不允許存在「+」符號
====== 不符合FCB規範 ======
$(grep -n '^\+' /etc/passwd)
====== FCB建議設定值 ======
# 禁止存在「+」符號
====== FCB設定方法值 ======
# 編輯/etc/passwd檔案，將行首為「+」符號之列移除
=========================
EOF
else
    echo "OK: 75 passwd不允許存在「+」符號" >> ${FCB_SUCCESS}
fi

echo '76 shadow不允許存在「+」符號'
if grep '^\+:' /etc/shadow >/dev/null; then
        cat <<EOF >> ${FCB_FIX}

FIX: 76 shadow不允許存在「+」符號
====== 不符合FCB規範 ======
$(grep '^\+:' /etc/shadow)
====== FCB建議設定值 ======
# 禁止存在「+」符號
====== FCB設定方法值 ======
# 編輯/etc/shadow檔案，將行首為「+」符號之列移除
=========================
EOF
else
    echo "OK: 76 shadow不允許存在「+」符號" >> ${FCB_SUCCESS}
fi

echo '77 group不允許存在「+」符號'
if grep '^\+:' /etc/group >/dev/null; then
        cat <<EOF >> ${FCB_FIX}

FIX: 77 group不允許存在「+」符號
====== 不符合FCB規範 ======
$(grep '^\+:' /etc/group)
====== FCB建議設定值 ======
# 禁止存在「+」符號
====== FCB設定方法值 ======
# 編輯/etc/group檔案，將行首為「+」符號之列移除
=========================
EOF
else
    echo "OK: 77 group不允許存在「+」符號" >> ${FCB_SUCCESS}
fi

echo '78 UID=0之帳號'
emptyfiles=$(awk -F: '($3 == 0 ) { print $1}' /etc/passwd | grep -v root)
if [ -n "$emptyfiles" ]; then
    cat <<EOF >> ${FCB_FIX}

FIX: 78 UID=0之帳號
====== 不符合FCB規範 ======
# 78 以下帳號UID=0, 是具有系統管理權限
$(emptyfiles)
====== FCB建議設定值 ======
# 僅root帳號之UID為0
====== FCB設定方法值 ======
# 列出UID=0之帳號：
awk -F: '($3 == 0) { print $1 }' /etc/passwd
# 若存在非root帳號，則執行以下指令，移除帳號或重新設定UID：
userdel (帳號名稱)
或
usermod -u (UID) (帳號名稱)
=========================
EOF
else
    echo 'OK: 78 無其他帳號UID=0' >> ${FCB_SUCCESS}
fi

# 79 使用者家目錄權限
# 取得所有使用者清單，nologin /bin/false, root不用顯示
echo "79 使用者家目錄權限"
getent passwd | cut -d ':' -f 1,6,7 | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | cut -d ':' -f 2 | while read line; do
    homepath=$(echo $line | cut -d: -f1)
    if stat -c "%a" $homepath | grep [1-7][0][0] >/dev/null; then
        echo "OK: 79 使用者家目錄($homepath)權限" >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 79 使用者家目錄權限
====== 不符合FCB規範 ======
$(stat -c "檔案名稱 %n 檔案權限 %a" $homepath)
====== FCB建議設定值 ======
# 使用者家目錄應限制群組不具寫入(g-w)權限，其他使用者不具讀取、寫入及執行(o-rwx)權限，避免遭未經授權存取與竊取資料
# 使用者家目錄權限設定700或更低權限
====== FCB設定方法值 ======
# 使用者家目錄權限設定700
chmod 700 (使用者家目錄)
=========================
EOF
    fi
done

echo "80 81 使用者家目錄擁有者"
echo "82 使用者家目錄之「.」檔案權限"
echo "83 使用者家目錄之「.forward」檔案權限"
echo "84 使用者家目錄之「.netrc」檔案權限"
echo "85 使用者家目錄之「.rhosts」檔案權限"
getent passwd | grep -v 'halt\|sync\|shutdown\|nologin\|root\|\/bin\/false' | while read line; do
    user=$(echo $line | cut -d: -f1)
    homepath=$(sh -c "echo ~$user")
    # 80 81 使用者家目錄擁有者
    if [[ $user != $(stat -c "%U" $homepath) || $user != $(stat -c "%G" $homepath) ]] >/dev/null; then
        cat <<EOF >> ${FCB_FIX}

FIX: 80 81 使用者家目錄擁有者
====== 不符合FCB規範 ======
$(stat -c "檔案名稱: %n 檔案擁有者: %U:%G" $homepath)
====== FCB建議設定值 ======
# 家目錄使用者擁有
====== FCB設定方法值 ======
chown $user:$user $homepath
=========================
EOF
    else
        echo "OK: 80 81 使用者家目錄擁有者($homepath)" >> ${FCB_SUCCESS}
    fi
    # 82 使用者家目錄之「.」檔案權限
    cd $homepath
    if stat -c "%a" . | grep 550  >/dev/null; then
        echo "OK: 82 使用者家目錄之「.」檔案權限" >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 82 使用者家目錄之「.」檔案權限
====== 不符合FCB規範 ======
$(stat -c "資料夾名稱: %n 資料夾權限: %a" .)
====== FCB建議設定值 ======
# go-w或是更低權限
====== FCB設定方法值 ======
chmod 550 $homepath/.
=========================
EOF
    fi
    # 83 使用者家目錄之「.forward」檔案
    if [ -f ".forward" ]; then
        cat <<EOF >> ${FCB_FIX}

FIX: 83 使用者家目錄之「.forward」檔案
====== 不符合FCB規範 ======
# $user 家目錄存在.forward
====== FCB建議設定值 ======
# 移除.forward檔案
====== FCB設定方法值 ======
rm $homepath/.forward 
=========================
EOF
    else
        echo "OK: 83 $user home, file .forward not exists." >> ${FCB_SUCCESS}
    fi
    # 84 使用者家目錄之「.netrc」檔案
    if [ -f ".netrc" ]; then
        cat <<EOF >> ${FCB_FIX}

FIX: 84 使用者家目錄之「.netrc」檔案
====== 不符合FCB規範 ======
$homepath存在.netrc檔案
====== FCB建議設定值 ======
# 移除.netrc檔案
====== FCB設定方法值 ======
rm $homepath/.netrc 
=========================
EOF
    else
        echo "OK: 84 $user home, file .netrc not exists." >> ${FCB_SUCCESS}
    fi
    # 85 使用者家目錄之「.rhosts」檔案
    if [ -f ".rhosts" ]; then
        cat <<EOF >> ${FCB_FIX}

FIX: 85 使用者家目錄之「.rhosts」檔案
====== 不符合FCB規範 ======
$homepath存在.rhosts檔案
====== FCB建議設定值 ======
# 移除.rhosts檔案
====== FCB設定方法值 ======
rm $homepath/.rhosts
=========================
EOF
    else
        echo "OK: 85 $user home, file .rhosts not exists." >> ${FCB_SUCCESS}
    fi
done

echo '86 檢查/etc/passwd檔案設定的群組'
for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do
    grep -q -P "^.*?:[^:]*:$i:" /etc/group
    if [ $? -ne 0 ]; then
        cat <<EOF >> ${FCB_FIX}

FIX: 86 檢查/etc/passwd檔案設定的群組
====== 不符合FCB規範 ======
$(echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group")
====== FCB建議設定值 ======
# /etc/passwd檔案中帳號的群組皆須存在於/etc/group檔案中
====== FCB設定方法值 ======

=========================
EOF
    else
        echo "OK: 86 檢查/etc/passwd檔案設定的群組" >> ${FCB_SUCCESS}
    fi
done

echo '87 唯一的UID'
cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x ; do
    [ -z "$x" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
        users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
        cat <<EOF >> ${FCB_FIX}

FIX: 87 唯一的UID
====== 不符合FCB規範 ======
$(echo "有相同的UID, Duplicate UID ($2): $users")
====== FCB建議設定值 ======
# 為每個帳號設定唯一的UID
====== FCB設定方法值 ======
# 若有不同帳號使用相同的UID，則編輯/etc/passwd檔案，或執行以下指令，為帳號設定唯一的UID：
usermod -u (UID) (帳號名稱)
=========================
EOF
    else
        echo "OK: 87 唯一的UID" >> ${FCB_SUCCESS}
    fi
done

echo '88 唯一的GID'
cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do
    cat <<EOF >> ${FCB_FIX}

FIX: 88 唯一的GID
====== 不符合FCB規範 ======
$(echo "88 有相同的GID, Duplicate GID ($x) in /etc/group")
====== FCB建議設定值 ======
# 為每個群組設定唯一的GID
====== FCB設定方法值 ======
# 若有不同群組使用相同GID，則編輯/etc/group檔案，或執行以下指令，為群組設定唯一的GID：
groupmod -g (GID) (群組名稱)
=========================
EOF
done

echo '89 唯一的使用者帳號名稱'
cut -d: -f1 /etc/passwd | sort | uniq -d | while read x ; do
    cat <<EOF >> ${FCB_FIX}

FIX: 89 唯一的使用者帳號名稱
====== 不符合FCB規範 ======
$(echo "89 偵測到相同使用者帳號名稱, Duplicate login name ${x} in /etc/passwd")
====== FCB建議設定值 ======
# 為每個使用者帳號設定唯一的名稱
====== FCB設定方法值 ======
# 編輯/etc/passwd檔案，為帳號設定唯一不重複的帳號名稱
=========================
EOF
done

echo '90 唯一的群組名稱'
cut -d: -f1 /etc/group | sort | uniq -d | while read x ; do
    cat <<EOF >> ${FCB_FIX}

FIX: 90 唯一的群組名稱
====== 不符合FCB規範 ======
$(echo "90 偵測到相同群組名稱, Duplicate group name ${x} in /etc/group")
====== FCB建議設定值 ======
# 為每個群組設定唯一的群組名稱
====== FCB設定方法值 ======
# 編輯/etc/group檔案，為每個群組設定唯一的群組名稱
=========================
EOF
done

echo '91 shadow群組成員'
if awk -F: '($1=="shadow")' /etc/group >/dev/null; then
    echo 'OK: 91 shadow群組成員' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 91 shadow群組成員
====== 不符合FCB規範 ======
$(awk -F: '($1=="shadow")' /etc/group)
====== FCB建議設定值 ======
# shadow群組不包含任何使用者
====== FCB設定方法值 ======
# 如shadow群組有使用者帳號，請針對每個帳號執行下列步驟：
# (1) 執行以下指令，從shadow群組移除使用者帳號：
sed -ri 's/(^shadow:[^:]*:[^:]*:)([^:]+$)/\1/' /etc/group
# (2) 執行以下指令，將使用者帳號之主要群組，從shadow修改為預設群組：
usermod -g (預設群組名稱) (帳號名稱)
=========================
EOF
fi