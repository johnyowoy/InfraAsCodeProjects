echo "TASK [類別 SELinux] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 SELinux] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo '185 SELinux套件'
if rpm -q libselinux >/dev/null 2>&1; then
    echo 'OK: 185 SELinux套件' >> ${FCB_SUCCESS}
else
    dnf install -y libselinux
fi

echo '188 SELinux啟用狀態'
if grep ^SELinux=enforcing /etc/selinux/config >/dev/null 2>&1; then
    echo 'OK: 188 SELinux啟用狀態' >> ${FCB_SUCCESS}
else
    sed -i 's/^SELINUX=.*/SELINUX=enforcing/g' /etc/selinux/config
fi