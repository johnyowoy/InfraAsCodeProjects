echo "TASK [類別 帳號與存取控制] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [類別 帳號與存取控制] ****************************************" >> ${FCB_FIX}

echo "TASK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "TASK [Print Message] ****************************************" >> ${FCB_FIX}

echo '223 顯示登入失敗次數與日期'
if grep ^session.*required.*pam_lastlog.so.*showfailed$ /etc/pam.d/postlogin >/dev/null 2>&1; then
    echo 'OK: 223 顯示登入失敗次數與日期' >> ${FCB_SUCCESS}
else
    sed -i '$a session\t\trequired\t\tpam_lastlog.so showfailed' /etc/pam.d/postlogin
fi

echo '229 登入嘗試失敗之延遲時間'
if grep ^FAIL_DELAY\ 4$ /etc/login.defs >/dev/null 2>&1; then
    echo 'OK: 229 登入嘗試失敗之延遲時間' >> ${FCB_SUCCESS}
else
    sed -i 's/^#FAIL_DELAY.*/FAIL_DELAY\ 4/g' /etc/login.defs
fi

echo '232 限制每個帳號可同時登入之數量'
if grep ^hard\ maxlogins\ 10$ /etc/security/limits.conf >/dev/null 2>&1; then
    echo 'OK: 232 限制每個帳號可同時登入之數量' >> ${FCB_SUCCESS}
else
    sed -i '$a hard maxlogins 10' /etc/security/limits.conf
fi

echo '238 Bash shell閒置時登出時間'
declare -p TMOUT 2>/dev/null | grep -- '-r' >/dev/null || { TMOUT=900; readonly TMOUT; export TMOUT; }
declare -p TMOUT 2>/dev/null | grep -- '-r' >/dev/null || { TMOUT=900; readonly TMOUT; export TMOUT; }

echo '240 root帳號所屬群組'
usermod -g 0 root

echo '241 所有使用者帳號的預設umask'
if grep umask\ 027$ /etc/bashrc >/dev/null 2>&1; then
    echo 'OK: 241 所有使用者帳號的預設umask' >> ${FCB_SUCCESS}
else
    sed -i '69s/umask\ [0-9][0-9][0-9]/umask\ 027/g' /etc/bashrc
fi

echo '242 在/etc/login.defs設定所有使用者的預設umask'
if grep ^UMASK.*027$ /etc/login.defs >/dev/null 2>&1; then
    echo 'OK: 242 /etc/login.defs設定所有使用者的預設umask' >> ${FCB_SUCCESS}
else
    sed -i '117s/^UMASK.*/UMASK\t\t027/g' /etc/login.defs
fi