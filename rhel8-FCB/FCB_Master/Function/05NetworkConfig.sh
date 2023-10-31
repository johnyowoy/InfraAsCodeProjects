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

echo '116 預設網路介面接受安全的ICMP重新導向封包'
if sysctl -a | grep net.ipv4.conf.default.secure_redirects\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 116 預設網路介面接受安全的ICMP重新導向封包'
else
    sysctl -w net.ipv4.conf.default.secure_redirects=0
fi

echo '119 不回應ICMP廣播要求'
if sysctl -a | grep net.ipv4.icmp_echo_ignore_broadcasts\ =\ 1$ >/dev/null 2>&1; then
    echo 'OK: 119 不回應ICMP廣播要求' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
fi

echo '120 忽略偽造之ICMP錯誤訊息'
if sysctl -a | grep ^net.ipv4.icmp_ignore_bogus_error_responses\ =\ 1$ >/dev/null 2>&1; then
    echo 'OK: 120 忽略偽造之ICMP錯誤訊息' >> ${FCB_SUCCESS}
else 
    sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
fi

echo '121 所有網路介面啟用逆向路徑過濾功能'
if sysctl -a | grep ^net.ipv4.conf.all.rp_filter\ =\ 1$ >/dev/null 2>&1; then
    echo 'OK: 121 所有網路介面啟用逆向路徑過濾功能' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.conf.all.rp_filter=1
fi

echo '122 預設網路介面啟用逆向路徑過濾功能'
if sysctl -a | grep ^net.ipv4.conf.default.rp_filter\ =\ 1$ >/dev/null 2>&1; then
    echo 'OK: 122 預設網路介面啟用逆向路徑過濾功能' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.conf.default.rp_filter=1
fi

echo '123 TCP SYN cookies'
if sysctl -a | grep ^net.ipv4.tcp_syncookies\ =\ 1$ >/dev/null 2>&1; then
    echo 'OK: 123 TCP SYN cookies' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv4.tcp_syncookies=1
fi

echo '124 所有網路介面接受IPv6路由器公告訊息'
if sysctl -a | grep ^net.ipv6.conf.all.accept_ra\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 124 所有網路介面接受IPv6路由器公告訊息' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv6.conf.all.accept_ra=0
fi

echo '125 預設網路介面接受IPv6路由器公告訊息'
if sysctl -a | grep ^net.ipv6.conf.default.accept_ra\ =\ 0$ >/dev/null 2>&1; then
    echo 'OK: 125 預設網路介面接受IPv6路由器公告訊息' >> ${FCB_SUCCESS}
else
    sysctl -w net.ipv6.conf.default.accept_ra=0
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

echo "126 停用DCCP協定"
modprobepath="/etc/modprobe.d/dccp.conf"
if [ -f "${modprobepath}" ]; then
    if grep install.*dccp.*\/bin\/true ${modprobepath} /dev/null && grep blacklist.*dccp ${modprobepath} /dev/null; then
        echo "OK: 126 停用DCCP協定" >> ${FCB_SUCCESS}
    else
        echo "126 停用DCCP協定" >> ${modprobepath}
        sed -i '$a install dccp /bin/true' ${modprobepath}
        sed -i '$a blacklist dccp' ${modprobepath}
    fi
else
    touch ${modprobepath}
    echo "126 停用DCCP協定" >> ${modprobepath}
    sed -i '$a install dccp /bin/true' ${modprobepath}
    sed -i '$a blacklist dccp' ${modprobepath}
fi

echo "127 停用SCTP協定"
modprobepath="/etc/modprobe.d/sctp.conf"
if [ -f "${modprobepath}" ]; then
    if grep install.*sctp.*\/bin\/true ${modprobepath} /dev/null && grep blacklist.*sctp ${modprobepath} /dev/null; then
        echo "OK: 127 停用SCTP協定" >> ${FCB_SUCCESS}
    else
        echo "127 停用SCTP協定" >> ${modprobepath}
        sed -i '$a install sctp /bin/true' ${modprobepath}
        sed -i '$a blacklist sctp' ${modprobepath}
    fi
else
    touch ${modprobepath}
    echo "127 停用SCTP協定" >> ${modprobepath}
    sed -i '$a install sctp /bin/true' ${modprobepath}
    sed -i '$a blacklist sctp' ${modprobepath}
fi

echo "128 停用RDS協定"
modprobepath="/etc/modprobe.d/rds.conf"
if [ -f "${modprobepath}" ]; then
    if grep install.*rds.*\/bin\/true ${modprobepath} /dev/null && grep blacklist.*rds ${modprobepath} /dev/null; then
        echo "OK: 128 停用SCTP協定" >> ${FCB_SUCCESS}
    else
        echo "128 停用RDS協定" >> ${modprobepath}
        sed -i '$a install rds /bin/true' ${modprobepath}
        sed -i '$a blacklist rds' ${modprobepath}
    fi
else
    touch ${modprobepath}
    echo "128 停用RDS協定" >> ${modprobepath}
    sed -i '$a install rds /bin/true' ${modprobepath}
    sed -i '$a blacklist rds' ${modprobepath}
fi

echo "129 停用TIPC協定"
modprobepath="/etc/modprobe.d/tipc.conf"
if [ -f "${modprobepath}" ]; then
    if grep install.*ticp.*\/bin\/true ${modprobepath} /dev/null && grep blacklist.*ticp ${modprobepath} /dev/null; then
        echo "OK: 129 停用TIPC協定"
    else
        echo "129 停用TIPC協定" >> ${modprobepath}
        sed -i '$a install tipc /bin/true' ${modprobepath}
        sed -i '$a blacklist tipc' ${modprobepath}
    fi
else
    touch ${modprobepath}
    echo "129 停用TIPC協定" >> ${modprobepath}
    sed -i '$a install tipc /bin/true' ${modprobepath}
    sed -i '$a blacklist tipc' ${modprobepath}
EOF
fi

echo "130 無線網路介面"
if nmcli radio all | grep disabled >/dev/null; then
    echo "OK: 131 網路介面混雜模式"
else
    cat <<EOF >> ${FCB_FIX}

FIX: 130 無線網路介面
====== 不符合FCB規範 ======
$(nmcli radio all)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，停用所有無線介面：
nmcli radio all off
==========================
EOF
fi

echo "131 網路介面混雜模式"
if ip link | grep -i promisc >/dev/null; then
    echo "OK: 131 網路介面混雜模式"
else
    cat <<EOF >> ${FCB_FIX}

FIX: 131 網路介面混雜模式
====== 不符合FCB規範 ======
$(ip link | grep -i promisc)
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
# 開啟終端機，執行以下指令，檢查網路介面是否處於混雜模式：
ip link | grep -i promisc
# 若發現網路介面處於混雜模式，則執行以下指令，關閉網路介面混雜模式：
ip link set dev (網路介面裝置名稱) multicast off promisc off
==========================
EOF
fi