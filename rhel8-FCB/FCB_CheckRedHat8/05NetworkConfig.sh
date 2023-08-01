# 網路設定
function ConfiguringNetworks () {
    sysctl_conf='/etc/sysctl.conf'
    echo "108 停用IP轉送功能"
    sysctl -w net.ipv4.ip_forward=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.all.forwarding=0 >> ${sysctl_conf}

    echo "109 所有網路介面禁止傳送ICMP重新導入封包"
    sysctl -w net.ipv4.conf.all.send_redirects=0 >> ${sysctl_conf}

    echo "110 預設網路介面禁止傳送ICMP重新導向封包"
    sysctl -w net.ipv4.conf.default.send_redirects=0 >> ${sysctl_conf}

    echo "111 所有網路介面阻擋來源路由封包"
    sysctl -w net.ipv4.conf.all.accept_source_route=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.all.accept_source_route=0 >> ${sysctl_conf}

    echo "112 預設網路介面阻擋來源路由封包"
    sysctl -w net.ipv4.conf.default.accept_source_route=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.default.accept_source_route=0 >> ${sysctl_conf}

    echo "113 所有網路介面阻擋ICMP重新導向封包"
    sysctl -w net.ipv4.conf.all.accept_redirects=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.all.accept_redirects=0 >> ${sysctl_conf}

    echo "114 預設網路介面阻擋ICMP重新導向封包"
    sysctl -w net.ipv4.conf.default.accept_redirects=0 >> ${sysctl_conf}
    sysctl -w net.ipv6.conf.default.accept_redirects=0 >> ${sysctl_conf}

    echo "115 所有網路介面阻擋安全之IMCP重新封包"
    sysctl -w net.ipv4.conf.all.secure_redirects=0 >> ${sysctl_conf}

    echo "116 預設網路介面阻擋安全之ICMP重新導向封包"
    sysctl -w net.ipv4.conf.default.secure_redirects=0 >> ${sysctl_conf}

    echo "117 所有網路介面紀錄可疑封包"
    sysctl -w net.ipv4.conf.all.log_martians=1 >> ${sysctl_conf}

    echo "118 預設網路介面紀錄可疑封包"
    sysctl -w net.ipv4.conf.default.log_martians=1 >> ${sysctl_conf}

    echo "119 不回應ICMP廣播要求"
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 >> ${sysctl_conf}

    echo "120 忽略 造之ICMP錯誤訊息"
    sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1 >> ${sysctl_conf}

    echo "121 所有網路介面啟用逆向路徑過濾功能"
    sysctl -w net.ipv4.conf.all.rp_filter=1 >> ${sysctl_conf}

    echo "122 預設網路介面啟用逆向路徑過濾功能"
    sysctl -w net.ipv4.conf.default.rp_filter=1 >> ${sysctl_conf}

    echo "123 TCP SYN cookies"
    sysctl -w net.ipv4.tcp_syncookies=1 >> ${sysctl_conf}

    echo "124 所有網路介面阻擋IPv6路由器公告訊息"
    sysctl -w net.ipv6.all.accept_ra=0 >> ${sysctl_conf}

    echo "125 預設網路介面阻擋IPv6路由器公告訊息"
    sysctl -w net.ipv6.conf.default.accept_ra=0 >> ${sysctl_conf}

    sysctl -p ${sysctl_conf}

    echo "126 停用DCCP協定"
    touch /etc/modprobe.d/dccp.conf
    sed -i '$a install dccp /bin/true' /etc/modprobe.d/dccp.conf
    sed -i '$a blacklist dccp' /etc/modprobe.d/dccp.conf

    echo "127 停用SCTP協定"
    touch /etc/modprobe.d/sctp.conf
    sed -i '$a install sctp /bin/true' /etc/modprobe.d/sctp.conf
    sed -i '$a blacklist sctp' /etc/modprobe.d/sctp.conf

    echo "128 停用RDS協定"
    touch /etc/modprobe.d/rds.conf
    sed -i '$a install rds /bin/true' /etc/modprobe.d/rds.conf
    sed -i '$a blacklist rds' /etc/modprobe.d/rds.conf

    echo "129 停用TIPC協定"
    touch /etc/modprobe.d/tipc.conf
    sed -i '$a install tipc /bin/true' /etc/modprobe.d/tipc.conf
    sed -i '$a blacklist tipc' /etc/modprobe.d/tipc.conf

    echo "130 停用無線網路介面"
    nmcli radio all off

    echo "131 停用網路介面混雜模式"
    if ip link | grep -i promisc >/dev/null; then
        echo "檢查OK"
    else
        echo "請使用指令"
        echo "ip link set dev (網路介面裝置名稱) multicast off promisc off"
    fi
}
ConfiguringNetworks