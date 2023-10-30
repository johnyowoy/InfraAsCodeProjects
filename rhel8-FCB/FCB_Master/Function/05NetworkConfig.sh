echo "TASK [類別 網路設定] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 網路設定] ****************************************" >> ${FCB_ERROR}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_ERROR}


echo '109 所有網路介面傳送ICMP重新導向封包'
if sysctl -a | grep ^net.ipv4.conf.all.send_redirects\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 109 所有網路介面傳送ICMP重新導向封包' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl -w net.ipv4.route.flush=1
fi

echo '110 預設網路介面傳送ICMP重新導向封包'
if sysctl -a | grep ^net.ipv4.conf.default.send_redirects\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 110 預設網路介面傳送ICMP重新導向封包' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.conf.default.send_redirects=0
fi

echo '113 所有網路介面接受ICMP重新導向封包'
if sysctl -a | grep ^net.ipv4.conf.all.accept_redirects\ =\ 0$ >/dev/null 2>&1 && sysctl -a | grep ^net.ipv6.conf.all.accept_redirects\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 113 所有網路介面接受ICMP重新導向封包' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.all.accept_redirects=0
fi

echo '114 預設網路介面接受ICMP重新導向封包'
if sysctl -a | grep ^net.ipv4.conf.default.accept_redirects\ =\ 0$ >/dev/null 2>&1 && sysctl -a | grep ^net.ipv6.conf.default.accept_redirects\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 114 預設網路介面接受ICMP重新導向封包' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.conf.default.accept_redirects=0
    sysctl -w net.ipv6.conf.default.accept_redirects=0
fi

echo '115 所有網路介面接受安全的ICMP重新導向封包'
if sysctl -a | grep ^net.ipv4.conf.all.secure_redirects\ =\ 0$ >/dev/null 2>&1 && sysctl -a | grep ^net.ipv6.conf.all.secure_redirects\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 115 所有網路介面接受安全的ICMP重新導向封包' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.conf.all.secure_redirects=0
    sysctl -w net.ipv6.conf.all.secure_redirects=0
fi

# ======================================
# 網路設定
NetworkRulesPath='/etc/sysctl.d/tcb_fcbnetwork.conf'
if [ -f "${NetworkRulesPath}" ]; then
    echo "已建立tcb_fcbnetwork.conf檔案"
else
    touch ${NetworkRulesPath}
fi
index=1
while IFS= read -r line; do
    NetworkConfig[$index]="$line"
    if grep "${NetworkConfig[${index}]}" ${NetworkRulesPath} >/dev/null; then
        echo "OK: ${NetworkConfig[${index}]}"
    else        
        echo "${NetworkConfig[${index}]}" >> ${NetworkRulesPath}
    fi
    index=$((index + 1))
done <<EOF
# 108 停用IP轉送功能
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
# 109 所有網路介面禁止傳送ICMP重新導入封包
net.ipv4.conf.all.send_redirects = 0
# 110 預設網路介面禁止傳送ICMP重新導向封包
net.ipv4.conf.default.send_redirects = 0
# 111 所有網路介面阻擋來源路由封包
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
# 112 預設網路介面阻擋來源路由封包
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
# 113 所有網路介面阻擋ICMP重新導向封包
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# 114 預設網路介面阻擋ICMP重新導向封包
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
# 115 所有網路介面阻擋安全之IMCP重新封包
net.ipv4.conf.all.secure_redirects = 0
# 116 預設網路介面阻擋安全之ICMP重新導向封包
net.ipv4.conf.default.secure_redirects = 0
# 117 所有網路介面紀錄可疑封包
net.ipv4.conf.all.log_martians = 1
# 118 預設網路介面紀錄可疑封包
net.ipv4.conf.default.log_martians = 1
# 119 不回應ICMP廣播要求
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 120 忽略 造之ICMP錯誤訊息
net.ipv4.icmp_ignore_bogus_error_responses = 1
# 121 所有網路介面啟用逆向路徑過濾功能
net.ipv4.conf.all.rp_filter = 1
# 122 預設網路介面啟用逆向路徑過濾功能
net.ipv4.conf.default.rp_filter = 1
# 123 TCP SYN cookies
net.ipv4.tcp_syncookies = 1
# 124 所有網路介面阻擋IPv6路由器公告訊息
net.ipv6.all.accept_ra = 0
# 125 預設網路介面阻擋IPv6路由器公告訊息
net.ipv6.conf.default.accept_ra = 0
EOF