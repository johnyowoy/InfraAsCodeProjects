echo "TASK [類別 Cron設定] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 Cron設定] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo '196 /etc/cron.hourly目錄權限'
if stat -c "%a" /etc/cron.hourly | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 196 /etc/cron.hourly目錄權限' >> ${FCB_SUCCESS}
else
    chmod 700 /etc/cron.hourly
fi

echo '197 /etc/cron.daily目錄所有權'
if stat -c "%U %G" /etc/cron.daily | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 197 /etc/cron.daily目錄所有權' >> ${FCB_SUCCESS}
else
    chown root:root /etc/cron.daily
fi

echo '198 /etc/cron.daily目錄權限'
if stat -c "%a" /etc/cron.daily | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 198 /etc/cron.daily目錄權限' >> ${FCB_SUCCESS}
else
    chmod 700 /etc/cron.daily
fi

echo '199 /etc/cron.weekly目錄所有權'
if stat -c "%U %G" /etc/cron.weekly | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 199 /etc/cron.weekly目錄所有權' >> ${FCB_SUCCESS}
else
    chown root:root /etc/cron.weekly
fi

echo '200 /etc/cron.weekly目錄權限'
if stat -c "%a" /etc/cron.weekly | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 200 /etc/cron.weekly目錄權限' >> ${FCB_SUCCESS}
else
    chmod 700 /etc/cron.weekly
fi

echo '201 /etc/cron.monthly目錄所有權'
if stat -c "%U %G" /etc/cron.monthly | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 201 /etc/cron.monthly目錄所有權' >> ${FCB_SUCCESS}
else
    chown root:root /etc/cron.monthly
fi

echo '202 /etc/cron.monthly目錄權限'
if stat -c "%a" /etc/cron.monthly | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 202 /etc/cron.monthly目錄權限' >> ${FCB_SUCCESS}
else
    chmod 700 /etc/cron.monthly
fi

echo '203 /etc/cron.d目錄所有權'
if stat -c "%U %G" /etc/cron.d | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 203 /etc/cron.d目錄所有權' >> ${FCB_SUCCESS}
else
    chown root:root /etc/cron.d
fi

echo '204 /etc/cron.d目錄權限'
if stat -c "%a" /etc/cron.d | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 204 /etc/cron.d目錄權限' >> ${FCB_SUCCESS}
else
    chmod 700 /etc/cron.d
fi

echo '205 at.allow與cron.allow檔案所有權'
if [ -f "/etc/cron.deny" ] && [ -f "/etc/at.deny" ]; then
    rm /etc/cron.deny
    rm /etc/at.deny
else
    echo "OK: 205 cron.deny和at.deny檔案不存在"
fi

if [ -f "/etc/cron.allow" ] && [ -f "/etc/at.allow" ]; then
    if stat -c "%U %G" /etc/cron.allow | grep ^root\ root$ >/dev/null && stat -c "%U %G" /etc/at.allow | grep ^root\ root$ >/dev/null; then
        echo "OK: 205 at.allow與cron.allow檔案所有權"
    else
        chown root:root /etc/cron.allow
        chown root:root /etc/at.allow
    fi
else
    touch /etc/cron.allow
    touch /etc/at.allow
fi

echo '206 at.allow與cron.allow檔案權限'
if [ -f "/etc/cron.deny" ] && [ -f "/etc/at.deny" ]; then
    rm /etc/cron.deny
    rm /etc/at.deny
else
    echo "OK: 206 cron.deny和at.deny檔案不存在"
fi

if [ -f "/etc/cron.allow" ] && [ -f "/etc/at.allow" ]; then
    if stat -c "%a" /etc/cron.allow | grep 600 >/dev/null && stat -c "%a" /etc/at.allow | grep 600 >/dev/null; then
        echo "OK: 206 at.allow與cron.allow檔案權限"
    else
        chmod 600 /etc/cron.allow
        chmod 600 /etc/at.allow
    fi
else
    touch /etc/cron.allow
    touch /etc/at.allow
fi