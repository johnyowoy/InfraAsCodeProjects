echo "TASK [類別 SSH設定] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 SSH設定] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo '262 sshd守護程序'
if rpm -q openssh-server >/dev/null 2>&1; then
    echo 'OK: 262 sshd守護程序' >> ${FCB_SUCCESS}
else
    dnf install openssh-server
    systemctl --now enable sshd
fi

echo '263 SSH協定版本'
if grep ^Protocol\ 2$ /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 263 SSH協定版本' >> ${FCB_SUCCESS}
else
    sed -i '24a Protocol 2' /etc/ssh/sshd_config
EOF
fi

echo '264 /etc/ssh/sshd_config檔案所有權'
if stat -c "%U %G" /etc/ssh/sshd_config | grep ^root\ root$ >/dev/null 2>&1; then
    echo 'OK: 264 /etc/ssh/sshd_config檔案所有權' >> ${FCB_SUCCESS}
else
    chown root:root /etc/ssh/sshd_config
fi

echo '265 /etc/ssh/sshd_config檔案權限'
if stat -c "%a" /etc/ssh/sshd_config | grep [0-6][0][0] >/dev/null 2>&1; then
    echo 'OK: 265 /etc/ssh/sshd_config檔案權限' >> ${FCB_SUCCESS}
else
    chmod 600 /etc/ssh/sshd_config
fi

echo '267 SSH主機私鑰檔案所有權'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -c "%U %G" {} \; | grep '^root root$'
 >/dev/null 2>&1; then
    echo 'OK: 267 SSH主機私鑰檔案所有權' >> ${FCB_SUCCESS}
else    
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \;
fi

echo '268 SSH主機私鑰檔案權限'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -c "%a" {} \; | grep [0-6][0][0] >/dev/null 2>&1; then
    echo 'OK: 268 SSH主機私鑰檔案權限' >> ${FCB_SUCCESS}
else
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 600 {} \;
fi

echo '269 SSH主機公鑰檔案所有權'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat -c "%U %G" {} \; | grep '^root root$' >/dev/null 2>&1; then
    echo 'OK: 269 SSH主機公鑰檔案所有權' >> ${FCB_SUCCESS}
else
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;
fi

echo '270 SSH主機公鑰檔案權限'
if find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat -c "%a" {} \; | grep [0-6][0-4][0-4] >/dev/null 2>&1; then
    echo 'OK: 270 SSH主機公鑰檔案權限' >> ${FCB_SUCCESS}
else
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 644 {} \;
fi

echo '271 SSH加密演算法'
if grep '^Ciphers aes128-ctr,aes192-ctr,aes256-ctr$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 271 SSH加密演算法' >> ${FCB_SUCCESS}
else
    sed -i '$a Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config
fi

echo '272 SSH日誌記錄等級'
if grep '^LogLevel VERBOSE$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 272 SSH日誌記錄等級' >> ${FCB_SUCCESS}
else
    sed -i '35s/^#LogLevel.*/LogLevel VERBOSE/g' /etc/ssh/sshd_config
fi

echo '273 SSH X11Forwarding功能'
if grep '^X11Forwarding no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 273 SSH X11Forwarding功能' >> ${FCB_SUCCESS}
else
    sed -i '101s/^#X11Forwarding.*/X11Forwarding no/g' /etc/ssh/sshd_config
fi

echo '274 SSH MaxAuthTries參數'
if grep '^MaxAuthTries 4$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 274 SSH MaxAuthTries參數' >> ${FCB_SUCCESS}
else
    sed -i '42s/^#MaxAuthTries.*/MaxAuthTries 4/g' /etc/ssh/sshd_config
fi

echo '275 SSH IgnoreRhosts參數'
if grep '^IgnoreRhosts yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 275 SSH IgnoreRhosts參數' >> ${FCB_SUCCESS}
else
    sed -i '62s/^#IgnoreRhosts.*/IgnoreRhosts yes/g' /etc/ssh/sshd_config
fi

echo '276 SSH HostbasedAuthentication參數'
if grep '^HostbasedAuthentication no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 276 SSH HostbasedAuthentication參數' >> ${FCB_SUCCESS}
else
    sed -i '57s/^#HostbasedAuthentication.*/HostbasedAuthentication no/g' /etc/ssh/sshd_config
fi

echo '278 SSH PermitEmptyPasswords參數'
if grep '^PermitEmptyPasswords no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 278 SSH PermitEmptyPasswords參數' >> ${FCB_SUCCESS}
else
    sed -i '66s/^#PermitEmptyPasswords.*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
fi

echo '279 SSH PermitUserEnvironment參數'
if grep '^PermitUserEnvironment no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 279 SSH PermitUserEnvironment參數' >> ${FCB_SUCCESS}
else
    sed -i '108s/^#PermitUserEnvironment.*/PermitUserEnvironment no/g' /etc/ssh/sshd_config
fi

echo '280 SSH逾時時間'
if grep '^ClientAliveInterval 600$' /etc/ssh/sshd_config >/dev/null 2>&1 && grep '^ClientAliveCountMax 0$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 280 SSH逾時時間' >> ${FCB_SUCCESS}
else
    sed -i '110s/^#ClientAliveInterval.*/ClientAliveInterval 600/g' /etc/ssh/sshd_config
    sed -i '111s/^#ClientAliveCountMax.*/ClientAliveCountMax 0/g' /etc/ssh/sshd_config
fi

echo '281 SSH LoginGraceTime參數'
if grep '^LoginGraceTime 60$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 281 SSH LoginGraceTime參數' >> ${FCB_SUCCESS}
else
    sed -i '39s/^#LoginGraceTime.*/LoginGraceTime 60/g' /etc/ssh/sshd_config
fi

echo '283 SSH AllowTcpForwarding參數'
if grep '^AllowTcpForwarding no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 283 SSH AllowTcpForwarding參數' >> ${FCB_SUCCESS}
else
    sed -i '99s/^#AllowTcpForwarding.*/AllowTcpForwarding no/g' /etc/ssh/sshd_config
fi

echo '284 SSH MaxStartups參數'
if grep '^maxstartups 10:30:60$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 284 SSH MaxStartups參數' >> ${FCB_SUCCESS}
else
    sed -i '$a maxstartups 10:30:60' /etc/ssh/sshd_config
fi

echo '285 SSH MaxSessions參數'
if grep '^MaxSessions 4$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 285 SSH MaxSessions參數' >> ${FCB_SUCCESS}
else
    sed -i '43s/^#MaxSessions.*/MaxSessions 4/g' /etc/ssh/sshd_config
fi

echo '286 SSH StrictModes參數'
if grep '^StrictModes yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 286 SSH StrictModes參數' >> ${FCB_SUCCESS}
else
    sed -i '41s/^#StrictModes.*/StrictModes yes/g' /etc/ssh/sshd_config
fi

echo '287 SSH Compression參數'
if grep '^Compression delayed$' /etc/ssh/sshd_config >/dev/null 2>&1 || grep '^Compression no$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 287 SSH Compression參數' >> ${FCB_SUCCESS}
else
    sed -i '109s/^#Compression.*/Compression no/g' /etc/ssh/sshd_config
fi

echo '288 SSH IgnoreUserKnownHosts參數'
if grep '^IgnoreUserKnownHosts yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 288 SSH IgnoreUserKnownHosts參數' >> ${FCB_SUCCESS}
else
    sed -i '60s/^#IgnoreUserKnownHosts.*/IgnoreUserKnownHosts yes/g' /etc/ssh/sshd_config
fi

echo '289 SSH PrintLastLog參數'
if grep '^PrintLastLog yes$' /etc/ssh/sshd_config >/dev/null 2>&1; then
    echo 'OK: 289 SSH PrintLastLog參數' >> ${FCB_SUCCESS}
else
    sed -i '106s/^#PrintLastLog.*/PrintLastLog yes/g' /etc/ssh/sshd_config
fi
