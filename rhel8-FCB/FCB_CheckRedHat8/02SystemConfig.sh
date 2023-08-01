# 系統設定與維護
function SystemConfig () {
    # Log異常檢視
    # 符合FCB規範
    FCB_SUCCESS="/root/FCB_DOCS/$(date '+%Y%m%d')FCB_SUCCESS.log"
    # 需修正檢視
    FCB_CHECK="/root/FCB_DOCS/$(date '+%Y%m%d')FCB_CHECK.log"
    # 執行異常錯誤
    FCB_ERROR="/root/FCB_DOCS/$(date '+%Y%m%d')FCB_ERROR.log"

    # 32 GPG簽章驗證
    echo "32 GPG簽章驗證"
    if grep -q "gpgcheck=1" /etc/yum.conf; then
        echo "/etc/yum.conf GPG簽章驗證OK!" >> ${FCB_SUCCESS}
    else
        echo "32 /etc/yum.conf GPG簽章驗證不符合規範, 請修正!" >> ${FCB_CHECK}
        echo "====== 不符合 ======" >> ${FCB_CHECK}
        cat /etc/yum.conf | grep gpgcheck=.* >> ${FCB_CHECK}
        echo "====== 請修正 ======" >> ${FCB_CHECK}
        echo "gpgcheck=1" >> ${FCB_CHECK}
    fi
    if [ -f "/etc/dnf.conf" ]; then
        if grep -q "gpgcheck=1" /etc/dnf/dnf.conf; then
            echo "/etc/dnf/dnf.conf GPG簽章驗證OK!" >> ${FCB_SUCCESS}
        else
            echo "32 /etc/dnf.conf GPG簽章驗證不符合規範, 請修正!" >> ${FCB_CHECK}
            echo "====== 不符合 ======" >> ${FCB_CHECK}
            cat /etc/dnf.conf | grep gpgcheck=.* >> ${FCB_CHECK}
            echo "====== 請修正 ======" >> ${FCB_CHECK}
            echo "gpgcheck=1" >> ${FCB_CHECK}
        fi
    else
        echo "/etc/dnf.conf file not found, no set!"
    fi

    # 33 安裝sudo套件
    echo "33 安裝sudo package"
    if rpm -q sudo >/dev/null 2>&1; then
        echo '33 sudo package 已安裝' >> ${FCB_SUCCESS}
    else
        echo '33 sudo package 未安裝, 不符合規範請修正' >> ${FCB_CHECK}
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
            echo "34~35 檢查OK"
        else
            echo "34~35 未新增"${sudoers[${index}]}", 不符合規範請修正" >> ${FCB_CHECK}
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
        echo '36 aide package 已有安裝' >> ${FCB_SUCCESS}
    else
        echo '36 aide package 尚未安裝, 不符合FCB規範, 請進行安裝' >> ${FCB_CHECK}
    fi

    # 37 每天定期檢查檔案系統完整性
    echo "37 每天定期檢查檔案系統完整性"
    if [ -f '/var/spool/cron/root' ]; then
        if grep ^.*\/usr\/sbin\/aide.*--check /var/spool/cron/root >/dev/null; then
            echo '37 檔案系統完整性 已加入排成 檢查ok' >> ${FCB_SUCCESS}
        else
            echo '37 檔案系統完整性 尚未加入排成 請修正' >> ${FCB_CHECK}
            echo '0 5 * * * /usr/sbin/aide --check' >> ${FCB_CHECK}
        fi
    else
        echo 'cron root file does not exists.' >> ${FCB_CHECK}
    fi

    # 38 39 開機載入程式設定檔 檔案擁有者與權限
    if stat -c "%U %G" /boot/grub2/grub.cfg | grep -E root.*root >/dev/null; then
        echo "38 開機載入程式設定檔案 grub.cfg 檔案擁有者檢查OK" >> ${FCB_SUCCESS}
    else
        echo "38 開機載入程式設定檔案 grub.cfg 檔案擁有者不符合規範 請修正檔案擁有者為root" >> ${FCB_CHECK}
    fi
    if stat -c "%U %G" /boot/grub2/grubenv | grep -E root.*root >/dev/null; then
        echo "38 開機載入程式設定檔案 grubenv 檔案擁有者檢查OK" >> ${FCB_SUCCESS}
    else
        echo "38 開機載入程式設定檔案 grubenv 檔案擁有者不符合規範 請修正檔案擁有者為root" >> ${FCB_CHECK}
    fi
    if stat -c "%a" /boot/grub2/grub.cfg | grep 600 >/dev/null; then
        echo "39 開機載入程式設定檔案 grub.cfg 檔案權限檢查OK" >> ${FCB_SUCCESS}
    else
        echo "39 開機載入程式設定檔案 grub.cfg 檔案權限不符合規範 請修正檔案權限為600" >> ${FCB_CHECK} 
    fi
    if stat -c "%a" /boot/grub2/grubenv | grep 600 >/dev/null; then
        echo "39 開機載入程式設定檔案 grubenv 檔案權限檢查OK" >> ${FCB_SUCCESS}
    else
        echo "39 開機載入程式設定檔案 grubenv 檔案權限不符合規範 請修正檔案權限為600" >> ${FCB_CHECK} 
    fi
    
    # echo '40 設定開機載入程式密碼'
    # grub2-mkconfig -o /boot/grub2/grub.cfg
    # grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

    echo '41 單一使用者模式身分驗證'
    if grep ^ExecStart=-\/usr\/lib\/systemd\/systemd-sulogin-shell.*rescue /usr/lib/systemd/system/rescue.service >/dev/null; then
        echo '41 單一使用者模式身分驗證 檢查OK' >> ${FCB_SUCCESS}
    else
        echo '41 單一使用者模式身分驗證 不符合規定' >> ${FCB_CHECK}
    fi

    echo '42 核心傾印功能'
    if grep hard.*core.*0 /etc/security/limits.conf >/dev/null; then
        echo '42 hard core 0 檢查ok' >> ${FCB_SUCCESS}
    else
        echo '42 hard core 不符合規範, 請修正hard core 0' >> ${FCB_CHECK}
    fi
    if grep fs.suid_dumpable.*=.*0 /etc/sysctl.conf >/dev/null; then
        echo 'fs.suid_dumpable=0 檢查ok' >> ${FCB_SUCCESS}
    else
        echo 'fs.suid_dumpable 不符合規範, 請修正 fs.suid_dumpable = 0' >> ${FCB_CHECK} 
        echo '指令參考 sysctl -w fs.suid_dumpable=0 >> /etc/sysctl.conf' >> ${FCB_CHECK}
    fi

    echo '43 記憶體位址空間配置隨機載入'
    if grep kernel.randomize_va_space.*=.*2 /etc/sysctl.conf >/dev/null; then
        echo '43 kernel.randomize_va_space=2 檢查ok' >> ${FCB_SUCCESS}
    else
        echo '43 kernel.randomize_va_space 不符合規範, 請修正 kernel.randomize_va_space = 2' >> ${FCB_CHECK}
        echo '指令參考 sysctl -w kernel.randomize_va_space=2 >> /etc/sysctl.conf' >> ${FCB_CHECK}
    fi

    echo '44 設定全系統加密原則'
    if grep -E -i '^\s*(FUTURE|FIPS)\s*(\s+#.*)?$' /etc/crypto-policies/config >/dev/null; then
        echo '44 設定全系統加密原則 檢查ok' >> ${FCB_SUCCESS}
    else
        echo '44 全系統加密原則 不符合規範, 請修正為FUTURE或FIPS' >> ${FCB_SUCCESS}
    fi

    echo '61 其他使用者寫入具有全域寫入權限檔案'
    # 檢查/是否有other具有可寫入權限的檔案
    files=$(find / -xdev -type f -perm -0002)
    # 檢查是否找到other具有可寫入權限的檔案
    if [ -n "$files" ]; then
        echo '61 以下檔案是other具有可寫入權限' >> ${FCB_SUCCESS}
        echo "$files" >> ${FCB_SUCCESS}
        find / -xdev -type f -perm -0002 -exec chmod o-w {} \;
        echo '目前檔案已移除other具有可寫入權限' >> ${FCB_SUCCESS}
    else
        echo '61 沒有找到其他使用者寫入具有全域寫入權限檔案, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '62 檢查所有檔案與目錄之「擁有者」'
    # 找出/的所有檔案為不合法使用者
    files=$(find / -xdev -nouser)
    # 檢查/的所有檔案是否為合法使用者
    if [ -n "$files" ]; then
        echo '62 以下檔案為不合法使用者，請針對找到的檔案與目錄指定合法使用者或移除' >> ${FCB_CHECK}
        echo '語法參考 chown (使用者) (檔案名稱或目錄名稱) 或是 rm (檔案名稱或目錄名稱)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '62 掃描後根目錄所有檔案皆為合法使用者, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '63 檢查所有檔案與目錄之擁有「群組」'
    # 找出/的所有檔案為不合法群組
    files=$(find / -xdev -nouser)
    # 檢查/的所有檔案是否為合法群組
    if [ -n "$files" ]; then
        echo '63 以下檔案為不合法群組，請針對找到的檔案與目錄指定合法群組或移除' >> ${FCB_CHECK}
        echo '語法參考 chgrp (群組) (檔案名稱或目錄名稱) 或是 rm (檔案名稱或目錄名稱)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '63 掃描後根目錄所有檔案皆為合法群組, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '64 所有具有全域寫入權限目錄之擁有者'
    # 找出/的所有具有全域寫入權限目錄之擁有者
    files=$(find / -xdev -type d -perm -0002 -uid +999 -print)
    # 檢查/的具有全域寫入權限目錄之擁有者
    if [ -n "$files" ]; then
        echo '64 以下目錄為具有全域寫入權限目錄之擁有者, 請設定目錄擁有者為root或其他系統帳號' >> ${FCB_CHECK}
        echo '語法參考 chown (使用者) (目錄名稱)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '64 掃描根目錄, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '65 所有具有全域寫入權限目錄之擁有群組'
    # 找出/的所有具有全域寫入權限目錄之擁有群組
    files=$(find / -xdev -type d -perm -0002 -gid +999 -print)
    # 檢查/的具有全域寫入權限目錄之擁有群組
    if [ -n "$files" ]; then
        echo '65 以下目錄為具有全域寫入權限目錄之擁有群組, 請針對找到的設定目錄擁有者為root或其他系統群組(sys, bin或應用程式群組)' >> ${FCB_CHECK}
        echo '語法參考 chgrp (群組) (目錄名稱)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '65 掃描根目錄, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '66 系統命令檔案權限'
    # 找出/的所有具有全域寫入權限目錄之擁有群組
    files=$(find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /0022 -exec ls -la {} \;)
    # 檢查/的具有全域寫入權限目錄之擁有群組
    if [ -n "$files" ]; then
        echo '66 以下為系統命令檔案, 請針對找到的系統命令檔案設定755或更低權限' >> ${FCB_CHECK}
        echo '語法參考 chmod (權限設定) (系統檔案名稱)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '66 已掃描/bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '67 系統命令檔案擁有者'
    files=$(find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -exec ls -la {} \;)
    if [ -n "$files" ]; then
        echo '67 以下為「系統命令檔案」, 請針對找到的系統命令檔案設定「擁有者為root」' >> ${FCB_CHECK}
        echo '語法參考 chown (權限擁有者) (系統檔案名稱)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '67 已掃描/bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '68 系統命令檔案擁有群組'
    files=$(find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -exec ls -la {} \;)
    if [ -n "$files" ]; then
        echo '68 以下為「系統命令檔案」, 請針對找到的系統命令檔案設定「群組擁有者為root」' >> ${FCB_CHECK}
        echo '語法參考 chown (權限群組) (系統檔案名稱)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '68 已掃描/bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '69 程式庫檔案權限'
    files=$(find -L /lib /lib64 /usr/lib64 -perm /0022 -type f -exec ls -al {} \;)
    if [ -n "$files" ]; then
        echo '69 以下為「程式庫檔案」, 請針對找到的程式庫檔案設定「權限更改為755或更低權限」' >> ${FCB_CHECK}
        echo '語法參考 chmod (檔案權限) (程式庫檔案)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '69 已掃描/lib /lib64 /usr/lib64, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '70 程式庫檔案擁有者'
    files=$(find -L /lib /lib64 /usr/lib64 ! -user root -exec ls -al {} \;)
    if [ -n "$files" ]; then
        echo '70 以下為「程式庫檔案」, 請針對找到的程式庫檔案設定「擁有者更改為root」' >> ${FCB_CHECK}
        echo '語法參考 chown root (程式庫檔案)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '70 已掃描/lib /lib64 /usr/lib64, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '71 程式庫檔案擁有權組'
    files=$(find -L /lib /lib64 /usr/lib64 ! -group root -exec ls -al {} \;)
    if [ -n "$files" ]; then
        echo '71 以下為「程式庫檔案」, 請針對找到的程式庫檔案設定「擁有群組更改為root」' >> ${FCB_CHECK}
        echo '語法參考 chgrp root (程式庫檔案)' >> ${FCB_CHECK}
        echo "$files" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '71 已掃描/lib /lib64 /usr/lib64, 檢查ok' >> ${FCB_SUCCESS}
    fi

    echo '72 帳號不使用空白密碼'
    emptyfiles=$(awk -F: '($2 == "" ) { print $1 " does not have a password "}' /etc/shadow)
    if [ -n "$emptyfiles" ]; then
        echo '72 以下帳號必須具有密碼或鎖定' >> ${FCB_CHECK}
        echo "$emptyfiles" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '72 帳號已具有密碼或鎖定' >> ${FCB_SUCCESS}
    fi

    echo '73 root帳號的路徑變數'
    RPCV="$(sudo -Hiu root env | grep '^PATH=' | cut -d= -f2)"
    RPCV2="$(echo "$RPCV" | grep -q "::" && echo "root's path contains a empty directory (::)")"
    RPCV3="$(echo "$RPCV" | grep -q ":$" && echo "root's path contains a trailing (:)")"
    if [ "$RPCV2" ]; then
        echo '73 root帳號 PATH有異常, 請手動修正' >> ${FCB_CHECK}
        echo "${RPCV2}" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '73 root PATH 檢查OK' >> ${FCB_SUCCESS}
    fi
    if [ "$RPCV3" ]; then
        echo '73 root帳號 PATH有異常, 請手動修正' >> ${FCB_CHECK}
        echo "${RPCV3}" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
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

    echo '75 76 77 passwd shadow group不允許存在「+」符號'
    index=1
    while IFS= read -r line; do
        auditlog[$index]="$line"
        if grep '^\+' ${auditlog[$index]} >/dev/null; then
            echo "${auditlog[$index]} 字首存在「+」符號，請移除" >> ${FCB_CHECK}
            grep -n '^\+' ${auditlog[$index]} >> ${FCB_CHECK}
            echo '========== END ==========' >> ${FCB_CHECK}
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
        echo '78 以下帳號UID=0, 是具有系統管理權限' >> ${FCB_CHECK}
        echo "$emptyfiles" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    else
        echo '78 無其他帳號UID=0' >> ${FCB_SUCCESS}
    fi

    echo '86 檢查/etc/passwd檔案設定的群組'
    for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
        grep -q -P "^.*?:[^:]*:$i:" /etc/group
        if [ $? -ne 0 ]; then
            echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group" >> ${FCB_CHECK}
        fi
    done

    echo '87 唯一的UID'
    cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x ; do
    [ -z "$x" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
        users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
        echo "87 有相同UID, Duplicate UID ($2): $users" >> ${FCB_CHECK}
        echo "語法指令參考 usermod -u (UID) (帳號名稱)" >> ${FCB_CHECK}
        echo '========== END ==========' >> ${FCB_CHECK}
    fi
    done

    echo '88 唯一的GID'
    cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do
    echo "88 有相同的GID, Duplicate GID ($x) in /etc/group" >> ${FCB_CHECK}
    echo "語法指令參考 groupmod -g (GID) (群組名稱)"
    echo '========== END ==========' >> ${FCB_CHECK}
    done

    echo '89 唯一的使用者帳號名稱'
    cut -d: -f1 /etc/passwd | sort | uniq -d | while read x ; do
    echo "89 偵測到相同使用者帳號名稱, Duplicate login name ${x} in /etc/passwd" >> ${FCB_CHECK}
    echo '========== END ==========' >> ${FCB_CHECK}
    done

    echo '90 唯一的群組名稱'
    cut -d: -f1 /etc/group | sort | uniq -d | while read x ; do
    echo "90 偵測到相同群組名稱, Duplicate group name ${x} in /etc/group" >> ${FCB_CHECK}
    echo '========== END ==========' >> ${FCB_CHECK}
    done
}
SystemConfig