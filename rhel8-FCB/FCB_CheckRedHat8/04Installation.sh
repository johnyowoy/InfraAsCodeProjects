# 安裝與維護軟體
echo "TASK [類別 安裝與維護軟體] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 安裝與維護軟體] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo '102 NIS用戶端套件'
if rpm -q ypbind >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 102 NIS用戶端套件
====== 不符合FCB規範 ======
$(rpm -q ypbind)
====== FCB建議設定值 ======
# 移除
====== FCB設定方法值 ======
dnf remove ypbind
EOF
else
    echo 'OK: 102 NIS用戶端套件' >> ${FCB_SUCCESS}
fi

echo '103 telnet用戶端套件'
if rpm -q telnet >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 103 telnet用戶端套件
====== 不符合FCB規範 ======
$(rpm -q telnet)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
dnf remove telnet
EOF
else
    echo 'OK: 103 telnet用戶端套件' >> ${FCB_SUCCESS}
fi

echo '104 telnet伺服器套件'
if rpm -q telnet-server >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 104 telnet伺服器套件
====== 不符合FCB規範 ======
$(rpm -q telnet-server)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
dnf remove telnet-server
EOF
else
    echo 'OK: 104 telnet伺服器套件' >> ${FCB_SUCCESS}
fi

echo '105 rsh伺服器套件'
if rpm -q rsh-server >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 105 rsh伺服器套件
====== 不符合FCB規範 ======
$(rpm -q rsh-server)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
dnf remove rsh-server
EOF
else
    echo 'OK: 105 rsh伺服器套件' >> ${FCB_SUCCESS}
fi

echo '106 tftp伺服器套件'
if rpm -q tftp-server >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 106 tftp伺服器套件
====== 不符合FCB規範 ======
$(rpm -q tftp-server)
====== FCB建議設定值 ======
# 移除
====== FCB設定方法值 ======
dnf remove tftp-server
EOF
else
echo 'OK: 106 tftp伺服器套件' >> ${FCB_SUCCESS}
fi

echo '107 更新套件後移除舊版本元件'
if grep ^clean_requirements_on_remove=True$ /etc/yum.conf >/dev/null 2>&1 || grep ^clean_requirements_on_remove=True$ /etc/dnf/dnf.conf >/dev/null 2>&1; then
    echo 'OK: 107 更新套件後移除舊版本元件' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 107 更新套件後移除舊版本元件
====== 不符合FCB規範 ======

====== FCB建議設定值 ======
# clean_requirements_on_remove=True
====== FCB設定方法值 ======
# 編輯/etc/yum.conf與/etc/dnf/dnf.conf檔案，新增或修改成以下內容：
clean_requirements_on_remove=True
EOF
fi