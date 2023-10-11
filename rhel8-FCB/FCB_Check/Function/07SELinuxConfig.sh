# 系統服務
echo "CHECK [類別 SELinux] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 SELinux] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

echo '185 SELinux套件'
if rpm -q libselinux >/dev/null 2>&1; then
    echo 'OK: 185 SELinux套件' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 185 SELinux套件
====== 不符合FCB規範 ======
$(rpm -q libselinux)
====== FCB建議設定值 ======
# 安裝
====== FCB設定方法值 ======
dnf install libselinux
EOF
fi

echo '186 開機載入程式啟用SELinux'
if grep ^GRUB_CMDLINE_LINUX=.*selinux=0.* /etc/default/grub >/dev/null 2>&1 && grep ^GRUB_CMDLINE_LINUX=.*enforcing=0.* /etc/default/grub >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 186 開機載入程式啟用SELinux
====== 不符合FCB規範 ======
# /etc/default/grub, GRUB_CMDLINE_LINUX有selinux=0或enforcing=0 參數
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
# 編輯/etc/default/grub
# GRUB_CMDLINE_LINUX那行移除selinux=0和enforcing=0 
EOF
else
    echo 'OK: 186 開機載入程式啟用SELinux' >> ${FCB_SUCCESS}
fi

echo '187 SElinux政策'
if grep ^SELINUXTYPE=targeted$ /etc/selinux/config >/dev/null 2>&1; then
    echo 'OK: 187 SElinux政策' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 187 SElinux政策
====== 不符合FCB規範 ======
$(grep ^SELINUXTYPE=.* /etc/selinux/config)
====== FCB建議設定值 ======
# targeted或更嚴格之政策
====== FCB設定方法值 ======
# 編輯/etc/selinux/config檔案，設定SELINUXTYPE參數如下：
SELINUXTYPE=targeted
EOF
fi

echo '188 SELinux啟用狀態'
if grep ^SELinux=enforcing /etc/selinux/config >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 188 SELinux啟用狀態
====== 不符合FCB規範 ======
$(grep ^SELinux=.* /etc/selinux/config)
====== FCB建議設定值 ======
# enforcing
====== FCB設定方法值 ======
# 編輯/etc/selinux/config檔案，設定SELINUX參數如下：
SELINUX=enforcing
EOF
else
    echo 'OK: 188 SELinux啟用狀態' >> ${FCB_SUCCESS}
fi

echo '189 未受限程序'
if ps -eZf | grep unconfined_service_t >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 189 未受限程序
====== 不符合FCB規範 ======
$(ps -eZf | grep unconfined_service_t)
====== FCB建議設定值 ======
# 無未受限程序
====== FCB設定方法值 ======

EOF
else
    echo 'OK: 189 未受限程序' >> ${FCB_SUCCESS}
fi

echo '190 setroubleshoot套件'
if rpm -q setroubleshoot >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 190 setroubleshoot套件
====== 不符合FCB規範 ======
$(rpm -q setroubleshoot)
====== FCB建議設定值 ======
# 移除
====== FCB設定方法值 ======
dnf remove setroubleshoot
EOF
else
    echo 'OK: 190 setroubleshoot套件' >> ${FCB_SUCCESS}
fi

echo '191 mcstrans套件'
if rpm -q mcstrans >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 191 mcstrans套件
====== 不符合FCB規範 ======
$(rpm -q mcstrans)
====== FCB建議設定值 ======
# 移除
====== FCB設定方法值 ======
dnf remove mcstrans
EOF
else
    echo 'OK: 191 mcstrans套件' >> ${FCB_SUCCESS}
fi
