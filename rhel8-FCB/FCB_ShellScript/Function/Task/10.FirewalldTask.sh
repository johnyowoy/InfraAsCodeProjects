echo "TASK [類別 Firewalld配置] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 Firewalld配置] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

cat <<EOF >> ${FCB_SUCCESS}
採用Firewalld時停用iptables服務
採用Firewalld時停用nftables服務
EOF

echo '246 iptables服務'
if systemctl is-enabled iptables >/dev/null 2>&1 && systemctl is-active iptables >/dev/null 2>&1; then
    systemctl --now mask iptables
    echo '246 iptables服務 已停用服務'
else
    echo 'OK: 246 iptables服務' >> ${FCB_SUCCESS}
fi

echo '247 nftables服務'
if systemctl is-enabled nftables >/dev/null 2>&1 && systemctl is-active nftables >/dev/null 2>&1; then
    systemctl --now mask nftables
    echo '247 nftables服務 已停用服務'
else
    echo 'OK: 247 nftables服務' >> ${FCB_SUCCESS}
fi

echo '248 firewalld防火牆預設區域'
default_zone=$(firewall-cmd --get-default-zone)
if [ -n "$default_zone" ]; then
    echo "目前firewalld的預設區域是: $default_zone"
    echo 'OK: 248 firewalld防火牆預設區域' >> ${FCB_SUCCESS}
else
    firewall-cmd --set-default-zone=public
    echo 'firewalld防火牆預設區域已設定public'
fi