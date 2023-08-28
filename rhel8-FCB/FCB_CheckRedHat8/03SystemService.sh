# 系統服務
# 符合FCB規範
FCB_SUCCESS="/root/FCB_DOCS/TCBFCB_SuccessCheck-$(date '+%Y%m%d').log"
# 需修正檢視
FCB_FIX="/root/FCB_DOCS/TCBFCB_FixCheck-$(date '+%Y%m%d').log"
# 執行異常錯誤
FCB_ERROR="/root/FCB_DOCS/TCBFCB_ErrorCheck-$(date '+%Y%m%d').log"
# 顯示日期時間
echo "$(date '+%Y/%m/%d %H:%M:%S')" >> ${FCB_SUCCESS}
echo "$(date '+%Y/%m/%d %H:%M:%S')" >> ${FCB_FIX}

echo "TASK [類別 系統服務] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 系統服務] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo "95 disable avahi-daemon service"
echo "96 disable snmp service"
echo "97 disable squid service"
echo "98 disable Samba service"
echo "99 disable FTP service"
echo "100 disable NIS service"
declare -a fcb_id=("95" "96" "97" "98" "99" "100")
declare -a package_names=("avahi" "net-snmp" "squid" "samba" "vsftpd" "ypserv")
declare -a service_names=("avahi-daemon" "snmpd" "squid" "smb" "vsftpd" "ypserv")
for index in ${!package_names[@]}; do
    fcb_id=${fcb_id[$index]}
    package_name=${package_names[$index]}
    service_name=${service_names[$index]}
    if rpm -q "$package_name" >/dev/null 2>&1; then
        cat <<EOF >> ${FCB_FIX}

FIX: $fcb_id disable $package_name service
====== 不符合FCB規範 ======
$(rpm -q "$package_name")
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
systemctl --now disable $service_name
=========================
EOF
    else
        echo "OK: $fcb_id $(rpm -q "$package_name")" >> ${FCB_SUCCESS}
    fi
done

echo "92 102~106  移除xinetd套件 NIS用戶端 telnet用戶端 telnet伺服器 rsh伺服器 tftp伺服器"
declare -a fcb_id=("92" "102" "103" "104" "105" "106")
declare -a remove_package_names=("xinetd" "ypbind" "telnet" "telnet-server" "rsh-server" "tftp-server")
for index in ${!remove_package_names[@]}; do
    fcb_id=${fcb_id[$index]}
    remove_package_name=${remove_package_names[$index]}
    if rpm -q "$remove_package_name" >/dev/null 2>&1; then
        cat <<EOF >> ${FCB_FIX}

FIX: $fcb_id disable $remove_package_name service
====== 不符合FCB規範 ======
$(rpm -q "$remove_package_name")
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
(方法一) yum remove $remove_package_name
(方法二) dnf remove $remove_package_name
=========================
EOF
    else
        echo "OK: $fcb_id $(rpm -q "$remove_package_name")" >> ${FCB_SUCCESS}
    fi
done

echo "101 kdump 服務"
if systemctl is-active kdump.service | grep active >/dev/null; then
    echo "OK: 101 kdump服務" >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 101 kdump服務
====== 不符合FCB規範 ======
$(systemctl is-active kdump.service)
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
systemctl --now enable kdump.service
=========================
EOF
fi

echo "107 更新套件後移除舊版本元件"
if grep clean_requirements_on_remove=True$ /etc/yum.conf >/dev/null; then
    echo "OK: 107 更新套件後移除舊版本元件" >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 107 更新套件後移除舊版本元件
====== 不符合FCB規範 ======
$(grep ^clean_requirements_on_remove=.* /etc/yum.conf)
尚未設定
====== FCB建議設定值 ======
# TRUE
====== FCB設定方法值 ======
# 編輯/etc/yum.conf, 新增或修改以下內容：
clean_requirements_on_remove=True
=========================
EOF
fi

if [ -f "/etc/dnf.conf" ]; then
    if grep clean_requirements_on_remove=True$ /etc/dnf.conf >/dev/null; then
        echo "OK: 107 更新套件後移除舊版本元件" >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 107 更新套件後移除舊版本元件
====== 不符合FCB規範 ======
$(grep ^clean_requirements_on_remove=.* /etc/dnf.conf)
尚未設定
====== FCB建議設定值 ======
# TRUE
====== FCB設定方法值 ======
# 編輯/etc/dnf.conf, 新增或修改以下內容：
clean_requirements_on_remove=True
=========================
EOF
    fi
else
    echo "OK: 107 dnf.conf檔案不存在" >> ${FCB_SUCCESS}
fi

echo "93 chrony校時設定"
echo "94 disable rsyncd service"