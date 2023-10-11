# 系統服務
echo "TASK [類別 系統服務] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 系統服務] ****************************************" >> ${FCB_ERROR}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_ERROR}

if grep ^server.*server.*stdtime.tcbbank.com.tw.*iburst$ /etc/chrony.conf >/dev/null; then
    echo "93 chrony校時設定" >> ${FCB_SUCCESS}
else
    sed -i '3a server server stdtime.tcbbank.com.tw iburst' /etc/chrony.conf
    sed -i 's/pool 2.rhel.pool.ntp.org iburst/# pool 2.rhel.pool.ntp.org iburst/g' /etc/chrony.conf
fi