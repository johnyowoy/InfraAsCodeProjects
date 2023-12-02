echo "CHECK [類別 SSH設定] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 SSH設定] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

echo '262 sshd守護程序'
if rpm -q openssh-server >/dev/null 2>&1; then
    echo 'OK: 262 sshd守護程序' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 262 sshd守護程序
====== 不符合FCB規範 ======
$(rpm -q openssh-server)
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
dnf install openssh-server
systemctl --now enable sshd
EOF
fi

echo '263 SSH協定版本'
if grep ^Protocol\ 2$ /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 263 SSH協定版本' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 263 SSH協定版本
====== 不符合FCB規範 ======
# 尚未設定
====== FCB建議設定值 ======
# Protocol 2
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，新增或修改成以下內容，以設定使用SSH-2：
Protocol 2
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
# 注意：請先通知SSH服務使用者，再重啟SSH服務，以避免影響使用者作業
EOF
fi

echo '264 /etc/ssh/sshd_config檔案所有權'
if stat -c "%U %G" /etc/ssh/sshd_config | grep ^root\ root$ >/dev/null 2>&1; then
    echo 'OK: 264 /etc/ssh/sshd_config檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 264 /etc/ssh/sshd_config檔案所有權
====== 不符合FCB規範 ======
stat -c "%U %G" /etc/ssh/sshd_config
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，設定/etc/ssh/sshd_config檔案擁有者與群組：
chown root:root /etc/ssh/sshd_config
# 執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
# 注意：請先通知SSH服務使用者，再重啟SSH服務，以避免影響使用者作業
EOF
fi

echo '265 /etc/ssh/sshd_config檔案權限'
if stat -c "%a" /etc/ssh/sshd_config | grep [0-6][0][0] >/dev/null 2>&1; then
    echo 'OK: 265 /etc/ssh/sshd_config檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 265 /etc/ssh/sshd_config檔案權限
====== 不符合FCB規範 ======
stat -c "%a" /etc/ssh/sshd_config
====== FCB建議設定值 ======
# 600或更低權限
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，設定/etc/ssh/sshd_config檔案權限為600或更低權限：
chmod 600 /etc/ssh/sshd_config
# 執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
# 注意：請先通知SSH服務使用者，再重啟SSH服務，以避免影響使用者作業
EOF
fi

echo '266 限制存取SSH'
if grep ^AllowUsers /etc/ssh/sshd_config >/dev/null 2>&1 && grep ^AllowGroups /etc/ssh/sshd_config >/dev/null 2>&1 && grep ^DenyUsers /etc/ssh/sshd_config >/dev/null 2>&1 && grep ^DenyGroups /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 266 限制存取SSH' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 266 限制存取SSH
====== 不符合FCB規範 ======
# 尚未設定
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
AllowUsers (使用者清單)
AllowGroups (群組清單)
DenyUsers (使用者清單)
DenyGroups (使用者清單)
# AllowUsers參數設定smith與jones使用者的範例如下：
AllowUsers smith jones
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
# 注意：請先通知SSH服務使用者，再重啟SSH服務，以避免影響使用者作業
EOF
fi

echo '267 SSH主機私鑰檔案所有權'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -c "%U %G" {} \; | grep '^root root$'
 >/dev/null 2>&1; then
    echo 'OK: 267 SSH主機私鑰檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 267 SSH主機私鑰檔案所有權
====== 不符合FCB規範 ======
$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -c "%n, %U %G" {} \;)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，設定SSH主機私鑰檔案擁有者與群組：
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \;"
EOF
fi

echo '268 SSH主機私鑰檔案權限'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -c "%a" {} \; | grep [0-6][0][0] >/dev/null 2>&1; then
    echo 'OK: 268 SSH主機私鑰檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 268 SSH主機私鑰檔案權限
====== 不符合FCB規範 ======
$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -c "%a" {} \;)
====== FCB建議設定值 ======
# 600或更低權限
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，設定SSH主機私鑰檔案權限為600或更低權限：
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 600 {} \;
EOF
fi

echo '269 SSH主機公鑰檔案所有權'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat -c "%U %G" {} \; | grep '^root root$' >/dev/null 2>&1; then
    echo 'OK: 269 SSH主機公鑰檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 269 SSH主機公鑰檔案所有權
====== 不符合FCB規範 ======
$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat -c "%n, %U %G" {} \;)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，設定SSH主機公鑰檔案擁有者與群組：
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;
EOF
fi

echo '270 SSH主機公鑰檔案權限'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat -c "%a" {} \; | grep [0-6][0-4][0-4] >/dev/null 2>&1; then
    echo 'OK: 270 SSH主機公鑰檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 270 SSH主機公鑰檔案權限
====== 不符合FCB規範 ======
$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat -c "%a" {} \;)
====== FCB建議設定值 ======
# 644或更低權限
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，設定SSH主機公鑰檔案權限為644或更低權限：
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 644 {} \;
EOF
fi

echo '271 SSH加密演算法'
if grep '^Ciphers aes128-ctr,aes192-ctr,aes256-ctr$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 271 SSH加密演算法' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 271 SSH加密演算法
====== 不符合FCB規範 ======
# 尚未設定
====== FCB建議設定值 ======
# Ciphers aes128-ctr,aes192-ctr,aes256-ctr
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，新增或修改成以下內容：
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '272 SSH日誌記錄等級'
if grep '^LogLevel VERBOSE$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 272 SSH日誌記錄等級' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 272 SSH日誌記錄等級
====== 不符合FCB規範 ======
# 尚未設定
====== FCB建議設定值 ======
# VERBOSE 或 INFO
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
LogLevel VERBOSE
# or
LogLevel INFO
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '273 SSH X11Forwarding功能'
if grep '^X11Forwarding no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 273 SSH X11Forwarding功能' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 273 SSH X11Forwarding功能
====== 不符合FCB規範 ======
# 尚未設定
====== FCB建議設定值 ======
# X11Forwarding no
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
X11Forwarding no
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '274 SSH MaxAuthTries參數'
if grep '^MaxAuthTries 4$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 274 SSH MaxAuthTries參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 274 SSH MaxAuthTries參數
====== 不符合FCB規範 ======
$(grep MaxAuthTries /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# 4以下，但須大於0
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
MaxAuthTries 4
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '275 SSH IgnoreRhosts參數'
if grep '^IgnoreRhosts yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 275 SSH IgnoreRhosts參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 275 SSH IgnoreRhosts參數
====== 不符合FCB規範 ======
$(grep 'IgnoreRhosts' /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# yes
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
IgnoreRhosts yes
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '276 SSH HostbasedAuthentication參數'
if grep '^HostbasedAuthentication no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 276 SSH HostbasedAuthentication參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 276 SSH HostbasedAuthentication參數
====== 不符合FCB規範 ======
$(grep HostbasedAuthentication /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# no
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
HostbasedAuthentication no
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '277 SSH PermitRootLogin參數'
if grep '^PermitRootLogin no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 277 SSH PermitRootLogin參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 277 SSH PermitRootLogin參數
====== 不符合FCB規範 ======
$(grep 'PermitRootLogin' /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# no
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
PermitRootLogin no
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '278 SSH PermitEmptyPasswords參數'
if grep '^PermitEmptyPasswords no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 278 SSH PermitEmptyPasswords參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 278 SSH PermitEmptyPasswords參數
====== 不符合FCB規範 ======
$(grep 'PermitEmptyPasswords' /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# PermitEmptyPasswords no
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
PermitEmptyPasswords no
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '279 SSH PermitUserEnvironment參數'
if grep '^PermitUserEnvironment no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 279 SSH PermitUserEnvironment參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 279 SSH PermitUserEnvironment參數
====== 不符合FCB規範 ======
$(grep PermitUserEnvironment /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# PermitUserEnvironment no
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
PermitUserEnvironment no
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '280 SSH逾時時間'
if grep '^ClientAliveInterval 600$' /etc/ssh/sshd_config >/dev/null 2>&1 && grep '^ClientAliveCountMax 0$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 280 SSH逾時時間' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 280 SSH逾時時間
====== 不符合FCB規範 ======
$(grep 'ClientAliveInterval' /etc/ssh/sshd_config)
$(grep 'ClientAliveCountMax' /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# ClientAliveInterval 600
# ClientAliveCountMax 0
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
ClientAliveInterval 600
ClientAliveCountMax 0
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
#systemctl restart sshd
EOF
fi

echo '281 SSH LoginGraceTime參數'
if grep '^LoginGraceTime 60$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 281 SSH LoginGraceTime參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 281 SSH LoginGraceTime參數
====== 不符合FCB規範 ======
$(grep LoginGraceTime /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# 60以下，但須大於0
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
LoginGraceTime 60
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '282 SSH UsePAM參數'
if grep '^UsePAM yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 282 SSH UsePAM參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 282 SSH UsePAM參數
====== 不符合FCB規範 ======
$(grep UsePAM /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# UsePAM yes
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
UsePAM yes
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '283 SSH AllowTcpForwarding參數'
if grep '^AllowTcpForwarding no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 283 SSH AllowTcpForwarding參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 283 SSH AllowTcpForwarding參數
====== 不符合FCB規範 ======
$(grep 'AllowTcpForwarding' /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# AllowTcpForwarding no
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
AllowTcpForwarding no
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '284 SSH MaxStartups參數'
if grep '^maxstartups 10:30:60$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 284 SSH MaxStartups參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 284 SSH MaxStartups參數
====== 不符合FCB規範 ======
# 尚未設定
====== FCB建議設定值 ======
# maxstartups 10:30:60
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下，當未經身分驗證連線數量達到10個後，將以30%機率拒絕後續連線；當未經身分驗證連線數量達到60個後，將全部拒絕後續連線： 
maxstartups 10:30:60
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '285 SSH MaxSessions參數'
if grep '^MaxSessions 4$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 285 SSH MaxSessions參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 285 SSH MaxSessions參數
====== 不符合FCB規範 ======
$(grep MaxSessions /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# 4以下，但須大於0
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，設定參數如下：
MaxSessions 4
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '286 SSH StrictModes參數'
if grep '^StrictModes yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 286 SSH StrictModes參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 286 SSH StrictModes參數
====== 不符合FCB規範 ======
$(grep StrictModes /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# StrictModes yes
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，新增或修改StrictModes參數為以下內容：
StrictModes yes
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '287 SSH Compression參數'
if grep '^Compression delayed$' /etc/ssh/sshd_config >/dev/null 2>&1 || grep '^Compression no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 287 SSH Compression參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 287 SSH Compression參數
====== 不符合FCB規範 ======
$(grep Compression /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# delayed或no
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，新增或修改Compression參數為「delayed」或「no」，範例如下：
Compression no
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '288 SSH IgnoreUserKnownHosts參數'
if grep '^IgnoreUserKnownHosts yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 288 SSH IgnoreUserKnownHosts參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 288 SSH IgnoreUserKnownHosts參數
====== 不符合FCB規範 ======
$(grep 'IgnoreUserKnownHosts' /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# IgnoreUserKnownHosts yes
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，新增或修改成以下內容：
IgnoreUserKnownHosts yes
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '289 SSH PrintLastLog參數'
if grep '^PrintLastLog yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 289 SSH PrintLastLog參數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 289 SSH PrintLastLog參數
====== 不符合FCB規範 ======
$(grep PrintLastLog /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# PrintLastLog yes
====== FCB設定方法值 ======
# 編輯/etc/ssh/sshd_config檔案，新增或修改成以下內容：
PrintLastLog yes
# 開啟終端機，執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
fi

echo '290 shosts.equiv檔案'
if [[ -z $(find / -name shosts.equiv 2>/dev/null) ]]; then
    echo 'OK: 290 shosts.equiv檔案不存在' >> ${FCB_SUCCESS}
else
    cat <<EOF >> "${FCB_FIX}"

FIX: 290 shosts.equiv檔案
====== 不符合FCB規範 ======
$(find / -name shosts.equiv 2>/dev/null)
====== FCB建議設定值 ======
# 移除
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，尋找任何「shosts.equiv」檔案：
find / -name shosts.equiv
# 若發現「shosts.equiv」檔案，執行指令移除檔案，範例如下：
rm /etc/ssh/shosts.equiv
EOF
fi

echo '291 .shosts檔案'
found_shosts=$(find / -name '*.shosts' 2>/dev/null)
if [[ -z $found_shosts ]]; then
    echo 'OK: 291 .shosts檔案' >> "${FCB_SUCCESS}"
else
    cat <<EOF >> "${FCB_FIX}"

FIX: 291 .shosts檔案
====== 不符合FCB規範 ======
${found_shosts}
====== FCB建議設定值 ======
# 移除
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，尋找任何「.shosts」檔案：
find / -name '*.shosts'
# 若發現「.shosts」檔案，執行指令移除檔案，範例如下：
rm $HOME/.shosts
EOF
fi

echo '292 覆寫全系統加密原則'
if grep '.*CRYPTO_POLICY.*' /etc/ssh/sshd_config >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 292 覆寫全系統加密原則
====== 不符合FCB規範 ======
$(grep '.*CRYPTO_POLICY.*' /etc/ssh/sshd_config)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，以停用覆寫全系統加密原則：
sed -ri "s/^\s*(CRYPTO_POLICY\s*=.*)$/# \1/" /etc/sysconfig/sshd
# 執行以下指令，重新啟動SSH服務使其生效：
systemctl restart sshd
EOF
else
    echo 'OK: 292 覆寫全系統加密原則' >> ${FCB_SUCCESS}
fi