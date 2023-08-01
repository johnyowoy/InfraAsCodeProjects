# 系統服務、安裝與維護軟體
function SystemService () {
    echo "95 disable avahi-daemon service"
    echo "96 disable snmp service"
    echo "97 disable squid service"
    echo "98 disable Samba service"
    echo "99 disable FTP service"
    echo "100 disable NIS service"
    declare -a package_names=("avahi" "net-snmp" "squid" "samba" "vsftpd" "ypserv")
    declare -a service_names=("avahi-daemon" "snmpd" "squid" "smb" "vsftpd" "ypserv")
    for index in ${!package_names[@]}; do
        package_name=${package_names[$index]}
        service_name=${service_names[$index]}
        
        if rpm -q "$package_name" >/dev/null 2>&1; then
            echo "package $package_name is installed"
            echo "Disabling service: $service_name"
            systemctl --now disable $service_name
        else
            echo "package $package_name is NOT installed."
        fi
    done

    echo "92 102~106  移除xinetd套件 NIS用戶端 telnet用戶端 telnet伺服器 rsh伺服器 tftp伺服器"
    declare -a remove_package_names=("xinetd" "ypbind" "telnet" "telnet-server" "rsh-server" "tftp-server")
    for remove_package_name in ${remove_package_names[@]}; do
        if rpm -q "$remove_package_name" >/dev/null 2>&1; then
            echo "removing package: $remove_package_name"
            dnf remove $remove_package_name
        else
            echo "package $remove_package_name is NOT installed."
        fi
    done

    echo "101 enable kdump service"
    systemctl --now enable kdump.service

    echo "107 更新套件後移除舊版本元件"
    sed -i '$a clean_requirements_on_remove=True' /etc/yum.conf
    sed -i '$a clean_requirements_on_remove=True' /etc/dnf.conf

    echo "93 chrony校時設定"
    echo "94 disable rsyncd service"
}
SystemService