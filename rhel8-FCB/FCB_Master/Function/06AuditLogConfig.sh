echo "TASK [類別 日誌與稽核] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 日誌與稽核] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo "132 auditd套件"
if rpm -q audit >/dev/null 2>&1 && rpm -q audit-libs >/dev/null 2>&1; then
    echo "OK: 132 auditd套件" >> ${FCB_SUCCESS}
else
    dnf install -y audit audit-libs
fi

echo "133 auditd服務"
if systemctl is-active auditd | grep active >/dev/null 2>&1; then
    echo "OK: 133 auditd服務" >> ${FCB_SUCCESS}
else
    systemctl --now enable auditd
fi

echo "134 稽核auditd服務啟動前之程序"
if cat /etc/default/grub | grep "^GRUB_CMDLINE_LINUX=.*audit=1.*" >/dev/null; then
    echo "OK: 134 稽核auditd服務啟動前之程序" >> ${FCB_SUCCESS}
else
    sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\("\)/\1 audit=1\2/' /etc/default/grub
    echo "/etc/default/grub 已「增加」稽核auditd=1"
fi

echo "135 稽核待辦事項數量限制"
if cat /etc/default/grub | grep "^GRUB_CMDLINE_LINUX=.*audit_backlog_limit=8192.*" >/dev/null; then
    echo "OK: 135 稽核待辦事項數量限制" >> ${FCB_SUCCESS}
else
    sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\("\)/\1 audit_backlog_limit=8192\2/' /etc/default/grub
    echo "/etc/default/grub 已「增加」稽核待辦事項數量限制 audit_backlog_limit=8192"
fi
grub2-mkconfig -o /boot/grub2/grub.cfg

echo "136 稽核處理失敗時通知系統管理者"
if cat /etc/aliases | grep postmaster:.*root >/dev/null; then
    echo "OK: 136 稽核處理失敗時通知系統管理者" >> ${FCB_SUCCESS}
else
    sed 's/\(^postmaster:.*\)/postmaster\troot/' /etc/aliases
    echo "稽核處理失敗 已設定通知系統管理者root"
fi

echo "137 稽核日誌「檔案」擁有者與群組"
if stat -c "%U %G" /var/log/audit/audit.log | grep -E root.*root >/dev/null; then
    echo "OK: 137 稽核日誌「檔案」擁有者與群組" >> ${FCB_SUCCESS}
else
    grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | xargs -I {} chown root:root {}
    echo "/var/log/audit/audit.log 已設定root"
fi

echo "138 稽核日誌「檔案」權限"
if stat -c "%a" /var/log/audit/audit.log | grep 600 >/dev/null; then
    echo "OK: 138 稽核日誌「檔案」權限" >> ${FCB_SUCCESS}
else
    grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | xargs -I {} chmod 600 {}
    echo "/var/log/audit 已設定600"
fi

echo "139 稽核日誌「目錄」擁有者與群組"
if stat -c "%U %G" /var/log/audit | grep -E root.*root >/dev/null; then
    echo "OK: 139 稽核日誌「目錄」擁有者與群組" >> ${FCB_SUCCESS}
else
    grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | sed 's/\(.*\)\(\/.*..*\)/\1/' | xargs -I {} chown root:root {}
    echo "/var/log/audit 已設定root:root"
fi
    
echo "140 稽核日誌「目錄」讀寫執行權限"
if stat -c "%a" /var/log/audit | grep 700 >/dev/null; then
    echo "OK: 140 稽核日誌「目錄」讀寫執行權限" >> ${FCB_SUCCESS}
else
    grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}' | sed 's/\(.*\)\(\/.*..*\)/\1/' | xargs -I {} chmod 700 {}
    echo "/var/log/audit 已設定700"
fi

echo "141 稽核「規則」「檔案」讀寫執行權限"
if stat -c "%a" /etc/audit/rules.d/audit.rules | grep 600 >/dev/null;then
    echo "OK: 141 稽核「規則」「檔案」讀寫執行權限" >> ${FCB_SUCCESS}
else
    chmod 600 /etc/audit/rules.d/audit.rules
    echo "/etc/audit/rules.d/audit.rules 已設定600"
fi

echo "142 稽核「設定」「檔案」讀寫執行權限"
if stat -c "%a" /etc/audit/auditd.conf | grep 640 >/dev/null; then
    echo "OK: 142 稽核「設定」「檔案」讀寫執行權限" >> ${FCB_SUCCESS}
else
    chmod 640 /etc/audit/auditd.conf
    echo "/etc/audit/auditd.conf 已設定640"
fi

echo "143 稽核工具讀寫執行權限"
echo "144 稽核工具擁有者與群組權限"
echo "145 啟用保護稽核工具"
if cat /etc/aide.conf | grep AuditConfig.*=.*p+i+n+u+g+s+b+acl+xattrs+sha512 >/dev/null; then
    echo "/etc/aide.conf 檢查OK"
else
    sed -i '$a AuditConfig = p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide.conf
    echo "已新增AuditConfig = p+i+n+u+g+s+b+acl+xattrs+sha512"
fi
index=1
while IFS= read -r line; do
    AuditTools[$index]="$line"
    # 143 稽核工具讀寫執行權限
    # 144 稽核工具擁有者與群組權限
    if [ -f "/sbin/${AuditTools[${index}]}" ]; then
        if stat -c "%a" /sbin/${AuditTools[${index}]} | grep 750 >/dev/null; then
            echo "/sbin/${AuditTools[${index}]}  讀寫執行權限檢查OK"
        else
            chmod 750 /sbin/${AuditTools[${index}]}
            echo "/sbin/${AuditTools[${index}]} 已設定750"
        fi
        if stat -c "%U %G" /sbin/${AuditTools[${index}]} | grep -E root.*root >/dev/null; then
            echo "/sbin/${AuditTools[${index}]}  擁有者與群組權限檢查OK"
        else
            chown root:root /sbin/${AuditTools[${index}]}
            echo "/sbin/${AuditTools[${index}]} 已設定root:root"
        fi
    else
        echo "File /sbin/${AuditTools[${index}]} does not exists"
    fi
    # 145 啟用保護稽核工具
    if [ -f "/sbin/${AuditTools[${index}]}" ]; then
        if cat /etc/aide.conf | grep /usr/sbin/${AuditTools[${index}]}.*AuditConfig >/dev/null; then
            echo "/usr/sbin/${AuditTools[${index}]}  保護稽核工具檢查OK"
        else
            sed -i '$a /usr/sbin/'${AuditTools[${index}]}' AuditConfig' /etc/aide.conf
            echo "/usr/sbin/${AuditTools[${index}]} 已新增規則"
        fi
    else
        echo "File /sbin/${AuditTools[${index}]} does not exists"
        echo "不用新增${AuditTools[${index}]}"
    fi
    index=$((index + 1))
# 稽核工具列表
done <<EOF
auditctl
aureport
ausearch
autrace
auditd
audisp-remote
audisp-syslog
augenrules
EOF

echo "146 稽核日誌檔案大小上限"
if cat /etc/audit/auditd.conf | grep ^max_log_file\ =\ 32$ >/dev/null; then
    echo "OK: 146 稽核日誌檔案大小上限" >> ${FCB_SUCCESS}
else
    sed -i 's/^max_log_file\ =.*/max_log_file\ =\ 32/g' /etc/audit/auditd.conf
    echo "/etc/audit/auditd.conf, 已修改max_log_file = 32"
fi

echo "147 稽核日誌達到其檔案大小上限之行為"
if grep ^max_log_file_action\ =\ keep_logs$ /etc/audit/auditd.conf >/dev/null; then
    echo "OK: 147 稽核日誌達到其檔案大小上限之行為" >> ${FCB_SUCCESS}
else
    sed -i 's/^max_log_file_action =.*/max_log_file_action = keep_logs/g' /etc/audit/auditd.conf
    echo "/etc/audit/auditd.conf, 已修改max_log_file_action = keep_logs"
fi
    
# 稽核日誌規則檔案
auditrulespath='/etc/audit/rules.d/audit.rules'
# Audit Log Check
index=1
while IFS= read -r line; do
    auditlog[$index]="$line"
    if grep "${auditlog[${index}]}" ${auditrulespath} >/dev/null; then
        echo "OK"
    else
        sed -i '$a '"${auditlog[${index}]}" ${auditrulespath}
        echo "已新增"${auditlog[${index}]}
    fi
    index=$((index + 1))
done <<EOF
# 148 紀錄系統管理者活動
\-w /etc/sudoers \-p wa \-k scope
\-w /etc/sudoers.d/ \-p wa \-k scope
# 149 紀錄變更登入與登出資訊事件
\-w /var/run/faillock/ \-p wa \-k logins
\-w /var/log/lastlog \-p wa \-k logins
# 150 紀錄會談啟始資訊
\-w /var/run/utmp \-p wa \-k session
\-w /var/log/wtmp \-p wa \-k logins
\-w /var/log/btmp \-p wa \-k logins
# 151 紀錄變更日期與時間事件
\-a always,exit \-F arch=b64 \-S adjtimex \-S settimeofday \-S clock_settime \-k timechange
\-a always,exit \-F arch=b32 \-S stime \-k time-change
\-w /etc/localtime \-p wa \-k timechange
# 152 紀錄變更系統強制存取控制事件'
\-w /etc/selinux/ \-p wa \-k MAC-policy
\-w /usr/share/selinux/ \-p wa \-k MAC-policy
# 153 紀錄變更系統網路環境事件
\-a always,exit \-F arch=b64 \-S sethostname \-S setdomainname \-k system-locale
\-a always,exit \-F arch=b32 \-S sethostname \-S setdomainname \-k system-locale
\-w /etc/issue \-p wa \-k system-locale
\-w /etc/issue.net \-p wa \-k system-locale
\-w /etc/hosts \-p wa \-k system-locale
\-w /etc/sysconfig/network-scripts/ \-p wa \-k system-locale
# 154 紀錄變更自主存取控制權限事件
\-a always,exit \-F arch=b64 \-S chmod \-S fchmod \-S fchmodat \-F auid>=1000 \-F auid!=4294967295 \-k perm_mod
\-a always,exit \-F arch=b64 \-S chown \-S fchown \-S fchownat \-S lchown \-F auid>=1000 \-F auid!=4294967295 \-k perm_mod
\-a always,exit \-F arch=b64 \-S setxattr \-S lsetxattr \-S fsetxattr \-S removexattr \-S lremovexattr \-S fremovexattr \-F auid>=1000 \-F auid!=4294967295 \-k perm_mod
# 155 紀錄不成功之未經授權檔案存取
\-a always,exit \-F arch=b64 \-S creat \-S open \-S openat \-S truncate \-S ftruncate \-F exit=-EACCES \-F auid>=1000 \-F auid!=4294967295 \-k access
\-a always,exit \-F arch=b64 \-S creat \-S open \-S openat \-S truncate \-S ftruncate \-F exit=-EPERM \-F auid>=1000 \-F auid!=4294967295 \-k access
# 156 紀錄變更使用者或群組資訊事件
\-w /etc/group \-p wa \-k identity
\-w /etc/passwd \-p wa \-k identity
\-w /etc/gshadow \-p wa \-k identity
\-w /etc/shadow \-p wa \-k identity
\-w /etc/security/opasswd \-p wa \-k identity
# 157 紀錄變更檔案系統掛載事件
\-a always,exit \-F arch=b64 \-S mount \-F auid>=1000 \-F auid!=4294967295 \-k mounts
\-a always,exit \-F arch=b32 \-S mount \-F auid>=1000 \-F auid!=4294967295 \-k mounts
# 159 紀錄檔案刪除事件
\-a always,exit \-F arch=b64 \-S unlink \-S unlinkat \-S rename \-S renameat \-F auid>=1000 \-F auid!=4294967295 \-k delete
\-a always,exit \-F arch=b32 \-S unlink \-S unlinkat \-S rename \-S renameat \-F auid>=1000 \-F auid!=4294967295 \-k delete
# 160 紀錄核心模組掛載與卸載事件
\-w /sbin/insmod \-p x \-k modules
\-w /sbin/rmmod \-p x \-k modules
\-w /sbin/modprobe \-p x \-k modules
\-a always,exit \-F arch=b64 \-S init_module \-S delete_module \-k modules
# 161 紀錄系統管理者活動日誌變更
\-w /var/log/sudo.log \-p wa \-k actions
# 162 紀錄chcon指令使用情形
\-a always,exit \-F path=/usr/bin/chcon \-F perm=x \-F auid>=1000 \-F auid!=4294967295 \-k perm_chng
# 163 紀錄ssh-agent程序使用情形
\-a always,exit \-F path=/usr/bin/ssh-agent \-F perm=x \-F auid>=1000 \-F auid!=4294967295 \-k privileged-ssh
# 164 紀錄unix_update程序使用情形
\-a always,exit \-F path=/sbin/unix_update \-F perm=x \-F auid>=1000 \-F auid!=4294967295 \-k privilegedunix-update
# 165 紀錄setfacl指令使用情形
\-a always,exit \-F path=/usr/bin/setfacl \-F perm=x \-F auid>=1000 \-F auid!=4294967295 \-k perm_chng
# 166 紀錄finit_module指令使用情形
\-a always,exit \-F arch=b32 \-S finit_module \-F auid>=1000 \-F auid!=4294967295 \-k module_chng
\-a always,exit \-F arch=b64 \-S finit_module \-F auid>=1000 \-F auid!=4294967295 \-k module_chng
# 167 紀錄open_by_handle_at系統呼叫使用情形
\-a always,exit \-F arch=b32 \-S open_by_handle_at \-F exit=-EPERM \-F auid>=1000 \-F auid!=4294967295 \-k perm_access
\-a always,exit \-F arch=b64 \-S open_by_handle_at \-F exit=-EPERM \-F auid>=1000 \-F auid!=4294967295 \-k perm_access
\-a always,exit \-F arch=b32 \-S open_by_handle_at \-F exit=-EACCES \-F auid>=1000 \-F auid!=4294967295 \-k perm_access
\-a always,exit \-F arch=b64 \-S open_by_handle_at \-F exit=-EACCES \-F auid>=1000 \-F auid!=4294967295 \-k perm_access
# 168 紀錄usermod指令使用情形
\-a always,exit \-F path=/usr/sbin/usermod \-F perm=x \-F auid>=1000 \-F auid!=4294967295 \-k privilegedusermod
# 169 紀錄chaacl指令使用情形
\-a always,exit \-F path=/usr/bin/chacl \-F perm=x \-F auid>=1000 \-F auid!=4294967295 \-k perm_chng
# 170 紀錄kmod指令使用情形
\-w /bin/kmod \-p x \-k modules
# 171 紀錄Pam_Faillock日誌檔案
\-w /var/log/faillock \-p wa \-k logins
# 172 紀錄execve系統呼叫使用情形
\-a always,exit \-F arch=b32 \-S execve \-C uid!=euid \-F key=execpriv
\-a always,exit \-F arch=b64 \-S execve \-C uid!=euid \-F key=execpriv
\-a always,exit \-F arch=b32 \-S execve \-C gid!=egid \-F key=execpriv
\-a always,exit \-F arch=b64 \-S execve \-C gid!=egid \-F key=execpriv
# 173 auditd設定不變模式
# Set enabled flag.
# To lock the audit configuration so that it can't be changed, pass a 2 as the argument.
-e 2
EOF

echo "174~175 安裝與啟用rsyslog套件"
if rpm -q rsyslog >/dev/null 2>&1; then
    echo "rsyslog package is already installed."
else
    dnf install -y rsyslog
    systemctl --now enable rsyslog
fi

echo "176 設定rsyslog日誌檔案預設權限"
if [ -f "/etc/rsyslog.conf" ]; then
    if stat -c "%a" /etc/rsyslog.conf | grep 640 >/dev/null; then
        echo "/etc/rsyslog.conf 檢查OK"
    else
        chmod 640 /etc/rsyslog.conf
        echo "/etc/rsyslog.conf 已設定640"
    fi
else
    echo "/etc/rsyslog.conf file not found, no set."
fi
if [ -f "/etc/rsyslog.d/"*".conf" ]; then
    if stat -c "%a" /etc/rsyslog.d/*.conf | grep 640 >/dev/null; then
        echo "/var/log/audit/audit.log 檢查OK"
    else
        chmod 640 /etc/rsyslog.d/*.conf
        echo "/etc/rsyslog.d/*.conf 已設定640"
    fi
else
    echo "/etc/rsyslog.d 資料夾沒有檔案，不用設定。"
fi
    
echo "177 設定rsyslog日誌紀錄規則"
if [ -f "/etc/rsyslog.conf" ]; then
    if grep .*/var/log/secure$ /etc/rsyslog.conf | awk '{print $1}' | grep [a][u][t][h][.][*] >/dev/null; then
        echo "檢查OK"
    else
        sed -i 's/\(.*\)\(\/var\/log\/secure\)/auth\.\*;\1\2/' /etc/rsyslog.conf
        echo "已增加auth.*"
    fi
    if grep .*/var/log/secure$ /etc/rsyslog.conf | awk '{print $1}' | grep [a][u][t][h][p][r][i][v][.][*] >/dev/null; then
    echo "檢查OK"
    else
        sed -i 's/\(.*\)\(\/var\/log\/secure\)/authpriv\.\*;\1\2/' /etc/rsyslog.conf
        echo "已增加authpriv.*"
    fi
    if grep .*/var/log/messages$ /etc/rsyslog.conf | awk '{print $1}' | grep [d][a][e][m][o][n][.][*] >/dev/null; then
        echo "檢查OK"
    else
        sed -i 's/\(.*\)\(\/var\/log\/messages\)/daemon\.\*;\1\2/' /etc/rsyslog.conf
        echo "已增加daemon.*"
    fi
else
    echo "/etc/rsyslog.conf file not found, no set."
    echo "Can't config FCB ID 177."
fi

echo "178 /var/log/messages「檔案」擁有者與群組"
if stat -c "%U %G" /var/log/messages | grep -E root.*root >/dev/null; then
    echo "/var/log/messages 檢查OK"
else
    chown root:root /var/log/messages
    echo "/var/log/messages 已設定root:root"
fi

echo "179 /var/log「目錄」擁有者與群組"
if stat -c "%U %G" /var/log | grep -E root.*root >/dev/null; then
    echo "/var/log 檢查OK"
else
    chown root:root /var/log
    echo "/var/log 已設定root:root"
fi

# 180 設定journald將日誌發送到rsyslog
sed -i 's/#ForwardToSyslog=no/ForwardToSyslog=yes/g' /etc/systemd/journald.conf

# 181 設定journald壓縮日誌檔案
sed -i 's/#Compress=yes/Compress=yes/g' /etc/systemd/journald.conf

# 182 設定journald將日誌檔案永久保存於磁碟
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf

# 183 設定/var/log目錄下所有日誌檔案權限
find /var/log -type f -perm /g=w,g=x,o=w,o=x -exec chmod 644 {} \;
