# 有問題的
# 208
# 209
# 220
# 221
# 222
# 228
# 231
# 232
# 234
# 237
# 238
# 241

# 不用做
# 235, 236, 239
# 系統服務
echo "CHECK [類別 帳號與存取控制] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 帳號與存取控制] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

echo '210 密碼最小長度'
if grep ^minlen.*=.*12$ /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 210 密碼最小長度' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 210 密碼最小長度
====== 不符合FCB規範 ======
$(grep minlen.*=.* /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 12個字元以上
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
minlen = 12
EOF
fi

echo '211 密碼必須至少包含字元類別數量'
if grep ^minclass.*=.*4$ /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 211 密碼必須至少包含字元類別數量' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 211 密碼必須至少包含字元類別數量
====== 不符合FCB規範 ======
$(grep minclass.* /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# minclass = 4
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
minclass = 4
EOF
fi

echo '212 密碼必須至少包含數字個數'
if grep ^dcredit.*=.*-1 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 212 密碼必須至少包含數字個數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 212 密碼必須至少包含數字個數
====== 不符合FCB規範 ======
$(grep dcredit /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 1個以上
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
dcredit = -1
EOF
fi

echo '213 密碼必須至少包含大寫字母個數'
if grep ^ucredit.*=.*-1 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 213 密碼必須至少包含大寫字母個數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 213 密碼必須至少包含大寫字母個數
====== 不符合FCB規範 ======
$(grep ucredit /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 1個以上
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
ucredit = -1
EOF
fi

echo '214 密碼必須至少包含小寫字母個數'
if grep ^lcredit.*=.*-1 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 214 密碼必須至少包含小寫字母個數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 214 密碼必須至少包含小寫字母個數
====== 不符合FCB規範 ======
$(grep lcredit /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 1個以上
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
lcredit = -1
EOF
fi

echo '215 密碼必須至少包含特殊字元個數'
if grep ^ocredit.*=.*-1 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 215 密碼必須至少包含特殊字元個數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 215 密碼必須至少包含特殊字元個數
====== 不符合FCB規範 ======
$(grep ocredit /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 1個以上
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
ocredit = -1
EOF
fi

echo '216 新密碼與舊密碼最少相異字元數'
if grep ^difok.*=.*3 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 216 新密碼與舊密碼最少相異字元數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 216 新密碼與舊密碼最少相異字元數
====== 不符合FCB規範 ======
$(grep difok /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 3個以上
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
difok = 3
EOF
fi

echo '217 同一類別字元可連續使用個數'
if grep ^maxclassrepeat.*=.*4 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 217 同一類別字元可連續使用個數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 217 同一類別字元可連續使用個數
====== 不符合FCB規範 ======
$(grep maxclassrepeat /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 4個以下，但須大於0
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
maxclassrepeat = 4
EOF
fi

echo '218 相同字元可連續使用個數'
if grep ^maxrepeat.*=.*3 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 218 相同字元可連續使用個數' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 218 相同字元可連續使用個數
====== 不符合FCB規範 ======
$(grep maxrepeat /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# 3個以下，但須大於0
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
maxrepeat = 3
EOF
fi

echo '219 必須禁止使用字典檔單字做為密碼'
if grep ^dictcheck.*=.*1 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 219 必須禁止使用字典檔單字做為密碼' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 219 必須禁止使用字典檔單字做為密碼
====== 不符合FCB規範 ======
$(grep dictcheck /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# dictcheck = 1
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
dictcheck = 1
EOF
fi

echo '219 必須禁止使用字典檔單字做為密碼'
if grep ^dictcheck.*=.*1 /etc/security/pwquality.conf >/dev/null 2>&1; then
    echo 'OK: 219 必須禁止使用字典檔單字做為密碼' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 219 必須禁止使用字典檔單字做為密碼
====== 不符合FCB規範 ======
$(grep dictcheck /etc/security/pwquality.conf)
====== FCB建議設定值 ======
# dictcheck = 1
====== FCB設定方法值 ======
# 編輯/etc/security/pwquality.conf檔案，新增或修改成以下內容：
dictcheck = 1
EOF
fi


echo '223 顯示登入失敗次數與日期'
if grep ^session.*required.*pam_lastlog.so.*showfailed /etc/pam.d/postlogin >/dev/null 2>&1; then
    echo 'OK: 223 顯示登入失敗次數與日期' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 223 顯示登入失敗次數與日期
====== 不符合FCB規範 ======
尚未設定
====== FCB建議設定值 ======
# 啟用
====== FCB設定方法值 ======
# 編輯/etc/pam.d/postlogin檔案，新增或修改以下內容至檔案最上方：
session required pam_lastlog.so showfailed
EOF
fi

echo '224 密碼雜湊演算法'
if grep ^ENCRYPT_METHOD.*SHA512 /etc/login.defs$ >/dev/null 2>&1; then
    echo 'OK: 224 密碼雜湊演算法' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 224 密碼雜湊演算法
====== 不符合FCB規範 ======
$(grep ENCRYPT_METHOD /etc/login.defs)
====== FCB建議設定值 ======
# SHA512
====== FCB設定方法值 ======
# 編輯/etc/login.defs檔案，新增或修改成以下內容：
ENCRYPT_METHOD SHA512
EOF
fi

echo '225 密碼最短使用期限'
if grep ^PASS_MIN_DAYS.*1$ /etc/login.defs >/dev/null 2>&1; then
    echo 'OK: 225 密碼最短使用期限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 225 密碼最短使用期限
====== 不符合FCB規範 ======
$(grep ^PASS_MIN_DAYS /etc/login.defs)
====== FCB建議設定值 ======
# PASS_MIN_DAYS 1
====== FCB設定方法值 ======
# 編輯/etc/login.defs檔案，設定PASS_MIN_DAYS參數如下：
PASS_MIN_DAYS 1
EOF
fi

echo '226 密碼最長使用期限'
if grep ^PASS_WARN_AGE.*14$ /etc/login.defs >/dev/null 2>&1; then
    echo 'OK: 226 密碼最長使用期限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 226 密碼最長使用期限
====== 不符合FCB規範 ======
$(grep ^PASS_WARN_AGE /etc/login.defs)
====== FCB建議設定值 ======
# 14天以上
====== FCB設定方法值 ======
# 編輯/etc/login.defs檔案，設定PASS_WARN_AGE參數如下：
PASS_WARN_AGE 14
EOF
fi

echo '227 密碼最長使用期限'
if grep ^PASS_MAX_DAYS.*90$ /etc/login.defs >/dev/null 2>&1; then
    echo 'OK: 227 密碼最長使用期限' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 227 密碼最長使用期限
====== 不符合FCB規範 ======
$(grep ^PASS_MAX_DAYS.*)
====== FCB建議設定值 ======
# 90天
====== FCB設定方法值 ======
# 編輯/etc/login.defs檔案，設定PASS_MAX_DAYS參數如下：
PASS_MAX_DAYS 90
EOF
fi

echo '229 登入嘗試失敗之延遲時間'
if grep ^FAIL_DELAY.*4$ /etc/login.defs >/dev/null 2>&1; then
    echo 'OK: 229 登入嘗試失敗之延遲時間' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 229 登入嘗試失敗之延遲時間
====== 不符合FCB規範 ======
$(grep FAIL_DELAY /etc/login.defs)
====== FCB建議設定值 ======
# 4秒以上
====== FCB設定方法值 ======
# 編輯/etc/login.defs檔案，將FAIL_DELAY參數值設為4以上，範例如下：
FAIL_DELAY 4
EOF
fi

echo '230 新使用者帳號預設建立使用者家目錄'
if grep ^CREATE_HOME.*yes$ /etc/login.defs >/dev/null 2>&1; then
    echo 'OK: 230 新使用者帳號預設建立使用者家目錄' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 230 新使用者帳號預設建立使用者家目錄
====== 不符合FCB規範 ======
$(grep CREATE_HOME /etc/login.defs)
====== FCB建議設定值 ======
# yes
====== FCB設定方法值 ======
# 編輯/etc/login.defs檔案，設定CREATE_HOME參數如下：
CREATE_HOME yes
EOF
fi

echo '233 kbd套件'
if rpm -q kbd >/dev/null 2>&1; then
    echo 'OK: 233 kbd套件' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 233 kbd套件
====== 不符合FCB規範 ======
$(rpm -q kbd)
====== FCB建議設定值 ======
# 安裝
====== FCB設定方法值 ======
dnf install kbd
EOF
fi

echo ''
if  >/dev/null 2>&1; then
    echo 'OK: ' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======

====== FCB建議設定值 ======

====== FCB設定方法值 ======

EOF
fi

echo ''
if  >/dev/null 2>&1; then
    echo 'OK: ' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======

====== FCB建議設定值 ======

====== FCB設定方法值 ======

EOF
fi

echo ''
if  >/dev/null 2>&1; then
    echo 'OK: ' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======

====== FCB建議設定值 ======

====== FCB設定方法值 ======

EOF
fi

echo ''
if  >/dev/null 2>&1; then
    echo 'OK: ' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======

====== FCB建議設定值 ======

====== FCB設定方法值 ======

EOF
fi

echo ''
if  >/dev/null 2>&1; then
    echo 'OK: ' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======

====== FCB建議設定值 ======

====== FCB設定方法值 ======

EOF
fi

echo ''
if  >/dev/null 2>&1; then
    echo 'OK: ' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======

====== FCB建議設定值 ======

====== FCB設定方法值 ======

EOF
fi

echo ''
if  >/dev/null 2>&1; then
    echo 'OK: ' >> ${FCB_SUCCESS}
else
    cat <<EOF >> ${FCB_FIX}

FIX: 
====== 不符合FCB規範 ======

====== FCB建議設定值 ======

====== FCB設定方法值 ======

EOF
fi