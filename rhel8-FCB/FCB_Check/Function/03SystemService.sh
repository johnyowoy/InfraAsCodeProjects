# 系統服務
echo "CHECK [類別 系統服務] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 系統服務] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

echo '92 xinetd套件'
if rpm -q "xinetd" >/dev/null 2>&1; then
    cat <<EOF >> ${FCB_FIX}

FIX: 92 xinetd套件
====== 不符合FCB規範 ======
$(rpm -q xinetd)
====== FCB建議設定值 ======
# 移除
====== FCB設定方法值 ======
(方法一)
yum remove xinetd
(方法二)
dnf remove xinetd
EOF
else
    echo 'OK: 92 xinetd套件' >> ${FCB_SUCCESS}
fi

echo '93 chrony校時設定'
if grep ^server.*stdtime.tcbbank.com.tw.*iburst$ /etc/chrony.conf >/dev/null 2>&1; then
    echo 'OK: 93 chrony校時設定' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 93 chrony校時設定
====== 不符合FCB規範 ======
尚未設定
====== FCB建議設定值 ======
# 設定1個以上校時來源
====== FCB設定方法值 ======
# 編輯/etc/chrony.conf檔案，新增或修改NTP伺服器設定，範例如下：
# 依據本行設定規範
server server stdtime.tcbbank.com.tw iburst
EOF
fi

echo '94 rsyncd服務'
if systemctl is-active rsyncd | grep inactive >/dev/null 2>&1; then
    echo 'OK: 94 rsyncd服務' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 94 rsyncd服務
====== 不符合FCB規範 ======
$(systemctl is-active rsyncd)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
systemctl --now disable rsyncd
EOF
fi

echo '95 avahi-daemon服務'
if systemctl is-active avahi-daemon | grep inactive >/dev/null 2>&1; then
    echo 'OK: 95 avahi-daemon服務' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 95 avahi-daemon服務
====== 不符合FCB規範 ======
$(rpm -q avahi)
$(systemctl is-active avahi-daemon)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
systemctl --now disable avahi-daemon
EOF
fi

echo '96 snmp服務'
if systemctl is-active snmpd | grep inactive >/dev/null 2>&1; then
    echo 'OK: 96 snmp服務' >> ${FCB_SUCCESS}
else
        cat <<EOF >> ${FCB_FIX}

FIX: 96 snmp服務
====== 不符合FCB規範 ======
$(rpm -q net-snmp)
$(systemctl is-active snmpd)
====== FCB建議設定值 ======
# 停用SNMP服務或僅啟用SNMPv3功能
====== FCB設定方法值 ======
#(1) 停用SNMP服務
# 開啟終端機，執行以下指令停用SNMP服務：
systemctl --now disable snmpd

(2) 僅啟用SNMPv3功能
# 使用「net-snmp-create-v3-user」工具設定啟用SNMPv3功能之範例如下：
# 開啟終端機，執行以下指令停止SNMP服務：
systemctl stop snmpd
# 執行以下指令設定SNMPv3並建立SNMPv3使用者，設定為僅允許讀取、身分驗證使用SHA及傳輸加密使用AES：
net-snmp-create-v3-user -ro -A (使用者密碼) -a SHA -X (傳輸加密用密碼) -x AES (使用者名稱)
# 執行以下指令編輯/etc/snmp/snmpd.conf檔案：
vim /etc/snmp/snmpd.conf
# 將包含com2sec、group、view及access參數之行內容註解(新增#符號於行首)，以停用SNMPv1與SNMPv2，範例如下：
com2sec notConfigUser  default       public
group   notConfigGroup v1           notConfigUser
group   notConfigGroup v2c          notConfigUser
view    systemview    included   .1.3.6.1.2.1.1
view    systemview    included   .1.3.6.1.2.1.25.1.1
access  notConfigGroup  """"      any       noauth    exact  systemview none none

# 執行以下指令重新啟動SNMP服務，令設定生效僅啟用SNMPv3：
systemctl start snmpd"
EOF
fi

echo '97 Squid服務'
if systemctl is-active squid | grep inactive >/dev/null 2>&1; then
    echo 'OK: 97 Squid服務' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======
$(rpm -q aquid)
$(systemctl is-active squid)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
systemctl --now disable squid
EOF
fi

echo '98 Samba服務'
if systemctl is-active smb | grep inactive >/dev/null 2>&1; then
    echo 'OK: 98 Samba服務' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 98 Samba服務
====== 不符合FCB規範 ======
$(rpm -q samba)
$(systemctl is-active smb)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
systemctl --now disable smb
EOF
fi

echo '99 FTP伺服器'
if systemctl is-active vsftpd | grep inactive >/dev/null 2>&1; then
    echo 'OK: 99 FTP伺服器' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 99 FTP伺服器
====== 不符合FCB規範 ======
$(systemctl is-active vsftpd)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
systemctl --now disable vsftpd
EOF
fi

echo '100 NIS伺服器'
if systemctl is-active ypserv | grep inactive >/dev/null 2>&1; then
    echo 'OK: 100 NIS伺服器' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======
$(systemctl is-active ypserv)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
systemctl --now disable ypserv
EOF
fi

echo '101 kdump服務'
if systemctl is-active kdump | grep active >/dev/null 2>&1; then
    echo 'OK: 101 kdump服務' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======
$(systemctl is-active kdump)
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
systemctl --now enable kdump.service
EOF
fi