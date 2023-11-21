echo "CHECK [類別 Cron設定] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 Cron設定] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

echo '192 cron守護程序'
if systemctl is-active crond | grep active >/dev/null 2>&1; then
    echo 'OK: 192 cron守護程序(start)' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 192 cron守護程序
====== 不符合FCB規範 ======
$(systemctl is-active crond)
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
systemctl --now enable crond
EOF
fi

if systemctl is-enabled crond | grep enabled >/dev/null 2>&1; then
    echo 'OK: 192 cron守護程序(enabled)' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 192 cron守護程序
====== 不符合FCB規範 ======
$(systemctl is-enabled crond)
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
systemctl enable crond
EOF
fi

echo '193 /etc/crontab檔案所有權'
if stat -c "%U %G" /etc/crontab | grep ^root.*root$ >/dev/null 2>&1; then
    echo 'OK: 193 /etc/crontab檔案所有權' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 193 /etc/crontab檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%n, %U:%G" /etc/crontab)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/crontab
EOF
fi

echo '194 /etc/crontab檔案權限'
if stat -c "%a" /etc/crontab | grep [0-6][0-4][0-4] >/dev/null 2>&1; then
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
$(stat -c "%a" /etc/cron.hourly)
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
$(stat -c "%U %G" /etc/cron.daily)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.daily
EOF
fi

echo '198 /etc/cron.daily目錄權限'
if stat -c "%a" /etc/cron.daily | grep [0-7][0][0] >/dev/null 2>&1; then
    echo 'OK: 198 /etc/cron.daily目錄權限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 198 /etc/cron.daily目錄權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/cron.daily)
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
$(stat -c "%n, %a" /etc/cron.monthly)
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
$(stat -c "%n, %U:%G" /etc/cron.d)
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

echo '205 at.allow與cron.allow檔案所有權'
if [ -f "/etc/cron.deny" ] && [ -f "/etc/at.deny" ]; then
    cat << EOF >> ${FCB_FIX}

FIX: 205 at.allow與cron.allow檔案所有權
====== 不符合FCB規範 ======
$(ll /etc | grep cron.deny)
$(ll /etc | grep at.deny)
====== FCB建議設定值 ======
# 移除cron.deny和at.deny
====== FCB設定方法值 ======
rm /etc/cron.deny
rm /etc/at.deny
EOF
else
    echo "OK: 205 cron.deny和at.deny檔案不存在"
fi

if [ -f "/etc/cron.allow" ] && [ -f "/etc/at.allow" ]; then
    if stat -c "%U %G" /etc/cron.allow | grep ^root\ root$ >/dev/null && stat -c "%U %G" /etc/at.allow | grep ^root\ root$ >/dev/null; then
        echo "OK: 205 at.allow與cron.allow檔案所有權"
    else
        cat << EOF >> ${FCB_FIX}

FIX: 205 at.allow與cron.allow檔案所有權
====== 不符合FCB規範 ======
$(stat -c "%U %G" /etc/cron.allow)
$(stat -c "%U %G" /etc/at.allow)
====== FCB建議設定值 ======
# root:root
====== FCB設定方法值 ======
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
EOF
    fi
else
    cat << EOF >> ${FCB_FIX}

FIX: 205 at.allow與cron.allow檔案所有權
====== 不符合FCB規範 ======
# at.allow或cron.allow檔案不存在
====== FCB建議設定值 ======
# 新增檔案cron.allow和at.allow
====== FCB設定方法值 ======
touch /etc/cron.allow
touch /etc/at.allow
EOF
fi

echo '206 at.allow與cron.allow檔案權限'
if [ -f "/etc/cron.deny" ] && [ -f "/etc/at.deny" ]; then
    cat << EOF >> ${FCB_FIX}

FIX: 206 at.allow與cron.allow檔案權限
====== 不符合FCB規範 ======
$(ll /etc | grep cron.deny)
$(ll /etc | grep at.deny)
====== FCB建議設定值 ======
# 移除cron.deny和at.deny
====== FCB設定方法值 ======
rm /etc/cron.deny
rm /etc/at.deny
EOF
else
    echo "OK: 206 cron.deny和at.deny檔案不存在"
fi

if [ -f "/etc/cron.allow" ] && [ -f "/etc/at.allow" ]; then
    if stat -c "%a" /etc/cron.allow | grep 600 >/dev/null && stat -c "%a" /etc/at.allow | grep 600 >/dev/null; then
        echo "OK: 206 at.allow與cron.allow檔案權限"
    else
        cat << EOF >> ${FCB_FIX}

FIX: 206 at.allow與cron.allow檔案權限
====== 不符合FCB規範 ======
$(stat -c "%a" /etc/cron.allow)
$(stat -c "%a" /etc/at.allow)
====== FCB建議設定值 ======
# 600
====== FCB設定方法值 ======
chmod 600 /etc/cron.allow
chmod 600 /etc/at.allow
EOF
    fi
else
    cat << EOF >> ${FCB_FIX}

FIX: 206 at.allow與cron.allow檔案權限
====== 不符合FCB規範 ======
# at.allow或cron.allow檔案不存在
====== FCB建議設定值 ======
# 新增檔案cron.allow和at.allow
====== FCB設定方法值 ======
touch /etc/cron.allow
touch /etc/at.allow
EOF
fi

echo '207 cron日誌記錄功能'
if grep ^cron.*\/var\/log\/cron$ /etc/rsyslog.conf >/dev/null 2>&1; then
    echo 'OK: 207 cron日誌記錄功能' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 207 cron日誌記錄功能
====== 不符合FCB規範 ======
# 尚未設定
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
# 編輯/etc/rsyslog.conf，新增
cron.*    /var/log/cron
EOF
fi