# 系統服務
echo "CHECK [類別 cron設定] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 cron設定] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

echo '192 cron守護程序'
if systemctl is-enabled crond | grep enabled >/dev/null 2>&1; then
    echo 'OK: 192 cron守護程序' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 192 cron守護程序
====== 不符合FCB規範 ======
$(systemctl is-enabled crond)
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
systemctl --now enable crond
EOF
fi

echo '193 /etc/crontab檔案所有權'
if stat -c "%U %G" /etc/crontab | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 193 /etc/crontab檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 193 /etc/crontab檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/crontab)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/crontab
EOF
fi

echo '194 /etc/crontab檔案權限'
if stat -c "%a" /etc/crontab | grep [0-6][0][0] >/dev/null 2>&1; then
    echo 'OK: 194 /etc/crontab檔案權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 194 /etc/crontab檔案權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/crontab)
====== FCB建議設定值 ======
# 600或更低權限
====== FCB設定方法值 ======
chmod 600 /etc/crontab
EOF
fi

echo '195 /etc/cron.hourly目錄所有權'
if stat -c "%U %G" /etc/cron.hourly | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 195 /etc/cron.hourly目錄所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 195 /etc/cron.hourly目錄所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/cron.hourly)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.hourly
EOF
fi

echo '196 /etc/cron.hourly目錄權限'
if stat -c "%a" /etc/cron.hourly | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 196 /etc/cron.hourly目錄權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 196 /etc/cron.hourly目錄權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/cron.hourly)
====== FCB建議設定值 ======
# 700或更低權限
====== FCB設定方法值 ======
chmod 700 /etc/cron.hourly
EOF
fi

echo '197 /etc/cron.daily目錄所有權'
if stat -c "%U %G" /etc/cron.daily | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 197 /etc/cron.daily目錄所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 197 /etc/cron.daily目錄所有權
====== 不符合FCB規範 ======
$(stat -c "%n, %U:%G" /etc/cron.daily)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.daily
EOF
fi

echo '198 /etc/cron.daily目錄權限'
if stat -c "%a" /etc/cron.daily >/dev/null 2>&1; then
    echo 'OK: 198 /etc/cron.daily目錄權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 198 /etc/cron.daily目錄權限
====== 不符合FCB規範 ======
$(stat -c "%n, %a" /etc/cron.daily)
====== FCB建議設定值 ======
# 700或更低權限
====== FCB設定方法值 ======
chmod 700 /etc/cron.daily
EOF
fi

echo '199 /etc/cron.weekly目錄所有權'
if stat -c "%U %G" /etc/cron.weekly | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 199 /etc/cron.weekly目錄所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 199 /etc/cron.weekly目錄所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/cron.weekly)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.weekly
EOF
fi

echo '200 /etc/cron.weekly目錄權限'
if stat -c "%a" /etc/cron.weekly | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 200 /etc/cron.weekly目錄權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 200 /etc/cron.weekly目錄權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/cron.weekly)
====== FCB建議設定值 ======
# 700或更低權限
====== FCB設定方法值 ======
chmod 700 /etc/cron.weekly
EOF
fi

echo '201 /etc/cron.monthly目錄所有權'
if stat -c "%U %G" /etc/cron.monthly | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 201 /etc/cron.monthly目錄所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 201 /etc/cron.monthly目錄所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/cron.monthly)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.monthly
EOF
fi

echo '202 /etc/cron.monthly目錄權限'
if stat -c "%a" /etc/cron.monthly | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 202 /etc/cron.monthly目錄權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 202 /etc/cron.monthly目錄權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/cron.monthly)
====== FCB建議設定值 ======
# 700或更低權限
====== FCB設定方法值 ======
chmod 700 /etc/cron.monthly
EOF
fi

echo '203 /etc/cron.d目錄所有權'
if stat -c "%U %G" /etc/cron.d | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 203 /etc/cron.d目錄所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 203 /etc/cron.d目錄所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/cron.d)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.d
EOF
fi

echo '204 /etc/cron.d目錄權限'
if stat -c "%a" /etc/cron.d | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 204 /etc/cron.d目錄權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 204 /etc/cron.d目錄權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/cron.d)
====== FCB建議設定值 ======
# 700或更低權限
====== FCB設定方法值 ======
chmod 700 /etc/cron.d
EOF
fi

echo '205 at.allow檔案所有權'
if [ -f '/etc/at.d/at.allow' ]; then
    if stat -c "%U %G" /etc/at.d/at.allow | grep ^root.*root$ >/dev/null 2>&1; then
        echo 'OK: 205 at.allow檔案所有權' >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 205 at.allow檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/at.d/at.allow)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/at.d/at.allow
EOF
    fi
else
    cat <<EOF >> ${FCB_FIX}

FIX: 205 at.allow檔案所有權
====== 不符合FCB規範 ======
尚未建立at.allow檔案
====== FCB建議設定值 ======
# 請建立/etc/at.d/at.allow檔案
====== FCB設定方法值 ======
touch /etc/at.d/at.allow
EOF
fi

if [ -f '/etc/cron.d/cron.allow' ]; then
    if stat -c "%U %G" /etc/cron.d/cron.allow | grep ^root.*root$ >/dev/null 2>&1; then
        echo 'OK: 205 cron.allow檔案所有權' >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 205 cron.allow檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/cron.d/cron.allow)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.d/cron.allow
EOF
    fi
else
    cat <<EOF >> ${FCB_FIX}

FIX: 205 cron.allow檔案所有權
====== 不符合FCB規範 ======
尚未建立cron.allow檔案
====== FCB建議設定值 ======
# 請建立/etc/cron.d/cron.allow檔案
====== FCB設定方法值 ======
touch /etc/cron.d/cron.allow
EOF
fi

echo '206 at.allow與cron.allow檔案權限'
if [ -f '/etc/at.d/at.allow' ]; then
    if stat -c "%a" /etc/at.d/at.allow | grep [0-6][0][0] >/dev/null 2>&1; then
        echo 'OK: 206 at.allow' >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 206 at.allow檔案權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/at.d/at.allow)
====== FCB建議設定值 ======
# 600或更低權限
====== FCB設定方法值 ======
chmod 600 /etc/at.d/at.allow
EOF
    fi
else
    cat <<EOF >> ${FCB_FIX}

FIX: 206 at.allow檔案權限
====== 不符合FCB規範 ======
尚未建立at.allow檔案
====== FCB建議設定值 ======
# 請建立/etc/at.d/at.allow檔案
====== FCB設定方法值 ======
touch /etc/at.d/at.allow
EOF
fi

if [ -f '/etc/cron.d/cron.allow' ]; then
    if stat -c "%a" /etc/cron.d/cron.allow | grep ^root.*root$ >/dev/null 2>&1; then
        echo 'OK: 206 cron.allow檔案權限' >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 206 cron.allow檔案權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/cron.d/cron.allow)
====== FCB建議設定值 ======
# 600或更低權限
====== FCB設定方法值 ======
chmod 600 /etc/cron.d/cron.allow
EOF
    fi
else
    cat <<EOF >> ${FCB_FIX}

FIX: 206 cron.allow檔案權限
====== 不符合FCB規範 ======
尚未建立cron.allow檔案
====== FCB建議設定值 ======
# 請建立/etc/cron.d/cron.allow檔案
====== FCB設定方法值 ======
touch /etc/cron.d/cron.allow
EOF
fi

echo '207 cron日誌記錄功能'
if grep cron /etc/rsyslog.conf /etc/rsyslog.d/*.conf >/dev/null 2>&1; then
    echo 'OK: 207 cron日誌記錄功能' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 207 cron日誌記錄功能
====== 不符合FCB規範 ======

====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
# 若無發現cron日誌記錄功能設定，請編輯/etc/rsyslog.conf檔案或/etc/rsyslog.d/目錄下的檔案，新增或修改成以下內容，以記錄所有cron訊息：
cron.* /var/log/cron.log"
EOF
fi