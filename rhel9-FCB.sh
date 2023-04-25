#!/bin/bash
# Program
#   Red Hat Enterprise Linux 9 Systemctl Security Check ShellScript
#   GCB政府組態基準-Red Hat Enterprise Linux 9
# History
#   2023/04/19    JINHAU, HUANG
# Version
#   v1.0

# 尚未確認實作 項次
# 61~72，74，78~79
# 80~91
# 確認是否以root身分執行
if [[ $EUID -ne 0 ]]; then
    echo "This script MUST be run as root!!"
    exit 1
fi

# 磁碟與檔案系統
echo "=========================="
echo "== DISK and File System =="
echo "=========================="

# cramfs檔案系統 停用

#cat <<EOF | sudo tee /etc/modprobe.d/cramfs.conf
#install cramfs /bin/true
#blacklist cramfs
#EOF

#rmmod cramfs

# squashfs檔案系統 停用

# udf檔案系統 停用

# 設定/tmp目錄之檔案系統
sed -i '$a tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0' /etc/fstab
systemctl unmask tmp.mount
systemctl enable tmp.mount
sed -i 's/Options=mode=1777,strictatime/Options=mode=1777,strictatime,noexec,nodev,nosuid/g' /etc/systemd/system/local-fs.target.wants/tmp.mount


echo "磁碟與檔案系統 設定成功。"

# 系統設定與維護
echo "==================================="
echo "== System Config and Maintenance =="
echo "==================================="

# GPG簽章驗證
if grep -q "gpgcheck=1" /etc/yum.conf; then
    echo "/etc/yum.conf GPG簽章驗證OK!"
elif grep -q "gpgcheck=0" /etc/yum.conf; then
    sed -i 's/gpgcheck=0/gpgcheck=1/g' /etc/yum.conf
else
    echo "/etc/yum.conf GPG簽章驗證「不符合FCB規定」"
    echo "/etc/yum.conf GPG簽章驗證Failed!!" >> /root/FCB_log.txt
fi

if grep -q "gpgcheck=1" /etc/dnf/dnf.conf; then
    echo "/etc/dnf/dnf.conf GPG簽章驗證OK!"
elif grep -q "gpgcheck=0" /etc/dnf.conf; then
    sed -i 's/gpgcheck=0/gpgcheck=1/g' /etc/dnf.conf
else
    echo "/etc/dnf/dnf.conf GPG簽章驗證「不符合FCB規定」" >> /root/FCB_log.txt
fi

# 設定sudo指令使用pty
sed -i '$a ##設定sudo指令使用pty' /etc/sudoers
sed -i '$a Defaults use_pty' /etc/sudoers

# 開機載入程式設定檔之所有權
# 這項原則設定決定開機載入程式(GRUB)設定檔之擁有者與群組
# GRUB 設定檔主要功能是用來記錄載入作業系統核心所使用之參數
# 將 GRUB 設定檔之擁有者與擁有群組設為 root，以防止非root 使用者變更檔案內容
# 備註：如果使用其他開機載入程式(如 LILO 或 EFIGRUB)，請比照上述原則進行設定
chown root:root /boot/grub2/grub.cfg
chown root:root /boot/grub2/grubenv

chmod 600 /boot/grub2/grub.cfg
chmod 600 /boot/grub2/grubenv

# 開機載入程式之通行碼
grub2-setpassword
grub2-mkconfig -o /boot/grub2/grub.cfg

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
    echo "Error: PATH contains invalid entries" >> /root/FCB_log.txt
    exit 1
fi

echo "PATH is valid"

# /etc/shadow檔案行首是否允許存在「+」符號
grep '^\+:' /etc/shadow
# /etc/group檔案行首是否允許存在「+」符號
grep '^\+:' /etc/group

# 使用者家目錄權限
# 使用者家目錄是系統預設之使用者主目錄，目錄下存放使用者之環境設定與個人檔案，因此任何使用者皆不應具有可寫入其他使用者家目錄之權限
# 使用者家目錄應限制群組不具寫入(g-w)權限，其他使用者不具讀取、寫入及執行(o-rwx)權限，避免遭未經授權存取與竊取資料
grep -E -v '^(halt|sync|shutdown)' /etc/passwd | awk -F:'($7 !="'"$(which nologin)"'" && $7 !="/bin/false") { print $1 " " $6 }' | while read user dir; do
    if [ ! -d "$dir" ]; then
        echo "The home directory ($dir) of user $user does not exist."
    else
        dirperm=$(ls -ld $dir | cut -f1 -d" ")
        if [ $(echo $dirperm | cut -c6) != "-" ]; then
            echo "Group Write permission set on the home directory ($dir) of user $user"
        fi
        if [ $(echo $dirperm | cut -c8) != "-" ]; then
            echo "Other Read permission set on the home directory ($dir) of user $user"
        fi
        if [ $(echo $dirperm | cut -c9) != "-" ]; then
            echo "Other Write permission set on the home directory ($dir) of user $user"
        fi
        if [ $(echo $dirperm | cut -c10) != "-" ]; then
            echo "Other Execute permission set on the home directory ($dir) of user $user"
        fi
    fi
done

# 這項原則設定決定使用者家目錄擁有者是否為使用者
# 使用者家目錄是系統預設之使用者主目錄，目錄下存放使用者之環境設定與個人檔案
# 設定使用者家目錄為使用者擁有，以確保使用者個人資料安全
grep -E -v '^(halt|sync|shutdown)' /etc/passwd | awk -F: '($7 !="'"$(which nologin)"'" && $7 !="/bin/false") { print $1 " " $6 }' | while read user dir; do
    if [ ! -d "$dir" ]; then
        echo "The home directory ($dir) of user $user does not exist."
    else
        owner=$(stat -L -c "%U" "$dir")
        if [ "$owner" != "$user" ]; then
            echo "The home directory ($dir) of user $user is owned by $owner."
        fi
    fi
done

# 這項原則設定決定使用者家目錄擁有群組是否為使用者群組
# 使用者家目錄是系統預設之使用者主目錄，目錄下存放使用者之環境設定與個人檔案
# 若使用者家目錄擁有群組 GID與使用者群組 GID 不同，將導致其他使用者可存取該使用者之檔案
# 設定使用者家目錄為使用者群組擁有，以確保使用者個人資料安全
grep -E -v '^(halt|sync|shutdown)' /etc/passwd | awk -F: '($7 !="'"$(whichnologin)"'" && $7 !="/bin/false") { print $1 " " $4 " "$6 }' | while read user gid dir; do
    if [ ! -d "$dir" ]; then
        echo "The home directory ($dir) of user $user does not exist."
    else
        owner=$(stat -L -c "%g" "$dir")
        if [ "$owner" != "$gid" ]; then
            echo "The home directory ($dir) of group $gid is owned by group $owner."
        fi
    fi
done

# 這項原則設定決定是否設定使用者家目錄之「.」檔案權限，使用者家目錄之「.」檔案包含使用者之初始化檔案與其他設定
#  限制使用者家目錄之「.」檔案寫入權限，以避免惡意人士藉由竊取或修改使用者資料，進而取得該使用者之系統權限
grep -E -v '^(halt|sync|shutdown)' /etc/passwd | awk -F: '($7 !="'"$(which nologin)"'" && $7 !="/bin/false") { print $1 " " $6 }' | while read user dir; do
    if [ ! -d "$dir" ]; then
        echo "The home directory ($dir) of user $user does not exist."
    else
        for file in $dir/.[A-Za-z0-9]*; do
            if [ ! -h "$file" -a -f "$file" ]; then
                fileperm=$(ls -ld $file | cut -f1 -d" ")
                if [ $(echo $fileperm | cut -c6) != "-" ]; then
                    echo "Group Write permission set on file $file"
                fi
                if [ $(echo $fileperm | cut -c9) != "-" ]; then
                    echo "Other Write permission set on file $file"
                fi
            fi
        done
    fi
done

# 這項原則設定決定是否移除使用者家目錄之「.forward」檔案
# 「.forward」檔案用於設定將使用者郵件轉發到指定之電子郵件信箱
# 移除「.forward」檔案以停用郵件轉發功能，避免機敏資料洩漏
grep -E -v '^(root|halt|sync|shutdown)' /etc/passwd | awk -F: '($7 != "'"$(which nologin)"'" && $7 !="/bin/false") { print $1 " " $6 }' | while read user dir; do
    if [ ! -d "$dir" ]; then
        echo "The home directory ($dir) of user $user does not exist."
    else
        if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
            echo ".forward file $dir/.forward exists"
        fi
    fi
done

# 這項原則設定決定是否移除使用者家目錄之「.netrc」檔案
# 「.netrc」檔案包含用於登入遠端 FTP 主機進行檔案傳輸之帳號與明文通行碼，移除「.netrc」檔案以避免對遠端FTP 主機造成之風險
grep -E -v '^(root|halt|sync|shutdown)' /etc/passwd | awk -F: '($7 != "'"$(which nologin)"'" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
    if [ ! -d "$dir" ]; then
        echo "The home directory ($dir) of user $user does not exist."
    else
        if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then
            echo ".netrc file $dir/.netrc exists"
        fi
    fi
done

# 這項原則設定決定是否移除使用者家目錄之「.rhosts」檔案
# 「.rhosts」檔案用於指定那個使用者可以不需要輸入通行碼即可執行 rsh 遠端連線，移除「.rhosts」檔案以避免遭惡意人士取得可攻擊其他遠端主機之資訊
grep -E -v '^(root|halt|sync|shutdown)' /etc/passwd | awk -F: '($7 != "'"$(which nologin)"'" && $7 !="/bin/false") { print $1 " " $6 }' | while read user dir; do
    if [ ! -d "$dir" ]; then
        echo "The home directory ($dir) of user $user does not exist."
    else
        for file in $dir/.rhosts; do
            if [ ! -h "$file" -a -f "$file" ]; then
                echo ".rhosts file in $dir"
            fi
        done
    fi
done

# 這項原則設定決定是否檢查/etc/passwd 檔案設定之群組，是否都存在於/etc/group 檔案中
# 在/etc/passwd 檔案中，使用者帳號設定之群組，若不存在於/etc/group 檔案中，代表群組權限管理不恰當，將可能對系統安全構成威脅
echo "檢查/etc/passwd檔案設應之群組"
for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
    grep -q -P "^.*?:[^:]*:$i:" /etc/group
    if [ $? -ne 0 ]; then
        echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group"
    fi
done

# 這項原則設定決定是否檢查/etc/passwd 檔案之使用者帳號UID(User Identifier，使用者識別碼)皆不相同
# 儘管透過 useradd 指令新增使用者帳號時，不允許建立重複之 UID，但系統管理者可手動編輯/etc/passwd 檔案並更改UID，造成 UID 重複之情形
# 為每個使用者帳號設定唯一之UID，以提供適當之存取防護
echo "唯一之UID"
cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x ; do
    [ -z "$x" ] && break set - $x
    if [ $1 -gt 1 ]; then
        users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
        echo "Duplicate UID ($2):$users"
    fi
done




# 判斷服務狀態的 Bash 指令稿
IS_ACT=`systemctl is-active xxx.service`
if [ "$IS_ACT" == "active" ]; then
  echo "xxx is active."
else
  echo "xxx is not active." >> /root/FCB_log.txt
fi