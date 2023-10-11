echo "===================================="
echo "======== SSH Configuration ========="
echo "===================================="

# 1 sshd守護程序 啟用
dnf install -y openssh-server
systemctl --now enable sshd

# 2 ssh協定版本
sed -i '20a Protocol 2' /etc/ssh/sshd_config

# 3 /etc/ssh/sshd_config檔案所有權
chown root:root /etc/ssh/sshd_config

# 4 /etc/ssh/sshd_config檔案權限
chmod 600 /etc/ssh/sshd_config

# 5 限制存取SSH

# 6 SSH主機私鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:ssh_keys {} \;

# 7 SSH主機私鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 640 {} \;

# 8 SSH主機公鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;

# 9 SSH主機公鑰檔案所有權
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 644 {} \;

# 10 SSH加密演算法
sed -i '34a Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config

# 11 SSH日誌紀錄等級 啟用
sed -i 's/#LogLevel INFO/LogLevel INFO/g' /etc/ssh/sshd_config

# 12 SSH X11 Forwarding功能 設定no
sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config

# 13 SSH MaxAuthTries參數
sed -i 's/#MaxAuthTries 6/MaxAuthTries 4/g' /etc/ssh/sshd_config

# 14 SSH IgnoreRhosts參數
sed -i 's/#IgnoreRhosts yes/IgnoreRhosts yes/g' /etc/ssh/sshd_config

# 15 SSH HostbasedAuthentication參數
sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config

# 16 SSH PermitRootLogin參數

# 17 SSH PermitEmptyPasswords參數
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config

# 18 SSH PermitUserEnvironment參數
sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment no/g' /etc/ssh/sshd_config

# 19 SSH逾時時間
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 600/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/g' /etc/ssh/sshd_config

# 20 SSH LoginGraceTime參數
sed -i 's/#LoginGraceTime 2m/LoginGraceTime 60m/g' /etc/ssh/sshd_config

# 21 SSH UsePAM參數 (預設已設定)

# 22 SSH AllowTcpForwarding參數
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config

# 23 SSH MaxStartups參數
sed -i 's/#MaxStartups 10:30:100/MaxStartups 10:30:60/g' /etc/ssh/sshd_config

# 24 SSH MaxSession參數
sed -i 's/#MaxSessions 10/MaxSessions 4/g' /etc/ssh/sshd_config

# 25 SSH StrictModes參數
sed -i 's/#StrictModes yes/StrictModes yes/g' /etc/ssh/sshd_config

# 26 SSH Compression參數
sed -i 's/#Compression delayed/Compression no/g' /etc/ssh/sshd_config

# 27 SSH IgnoreUserKnownHosts參數
sed -i 's/#IgnoreUserKnownHosts no/IgnoreUserKnownHosts yes/g' /etc/ssh/sshd_config

# 28 SSH PrintLastLog參數
sed -i 's/#PrintLastLog yes/PrintLastLog yes/g' /etc/ssh/sshd_config

# 29 移除shosts.equiv檔案
find / -name shosts.equiv -exec rm {} \;

# 30 移除.shosts檔案
find / -name *.shosts -exec rm {} \;

# 31 停用覆寫全系統加密原則 (預設停用)

systemctl restart sshd
