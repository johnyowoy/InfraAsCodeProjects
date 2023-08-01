#!/bin/bash
# Program
#   Red Hat Enterprise Linux 8 Systemctl Security Check ShellScript
#   FCB金融組態基準-Red Hat Enterprise Linux 8
# History
#   2023/04/19    JINHAU, HUANG
# Version
#   v1.0

# success: Success
# debug: Debug information from programs
# info: Simple informational message - no intervention is required
# notice: Condition that may require attention
# warn: Warning
# err: Error
# crit: Critical condition
# alert: Condition that needs immediate intervention
# emerg: Emergency condition

# 尚未確認實作 項次
# Number
# 08~28 獨立分割磁區或邏輯磁區，fstab nodev 啟用
# ==========================================
# 37 aide crontab 時間討論
# 42 無法寫成check
# 61~72，74，78~79
# 80~91
# 96
# 108
# 158
# 185 186 187 188
# 207 208 221
# 223 已經預設 ENCRYPT_METHOD SHA512
# 230
# SSH 5 限制SSH存取 啟用
# SSH 16 PermitRootLogin參數討論, 預設no 

# 確認是否以root身分執行
if [[ $EUID -ne 0 ]]; then
    echo "This script MUST be run as root!!"
    exit 1
fi
echo '現在您正以root權限執行腳本...'

# Log異常檢視
# 符合FCB Log
FCB_LOG_SUCCESS='/root/FCB_LOG_SUCCESS.txt'
# 錯誤需修正檢視Log
FCB_LOG_ERROR='/root/FCB_LOG_ERROR.txt'
# 執行異常錯誤
FCB_LOG_FAILED='/root/FCB_LOG_FAILED.txt'
touch ${FCB_LOG_SUCCESS}
touch ${FCB_LOG_ERROR}
touch ${FCB_LOG_FAILED}

# SELinux
echo "=============================="
echo "======= SELinux Config ======="
echo "=============================="

# 184 SELinux套件 安裝
dnf install libselinux

# 185 開機載入程式啟用SELinux 啟用

# 186 SELinux政策 targeted或更嚴格之政策
# 判斷式
if grep -q "SELINUXTYPE=targeted" /etc/selinux/config; then
    echo "/etc/selinux/config SELINUXTYPE 驗證OK!" >> ${FCB_LOG_SUCCESS}
else
    sed -i 's/\(^SELINUXTYPE=.*\)/SELINUXTYPE=targeted/g' /etc/selinux/config
    echo "/etc/selinux/config 已修改 SELINUXTYPE 驗證OK!" >> ${FCB_LOG_SUCCESS}
fi

# 187 SELinux啟用狀態 enforcing
# 判斷式

# 188 未受限程序 無

# 189 移除setroubleshoot套件
dnf remove -y setroubleshoot

# 190 移除mcstrans套件
dnf remove mcstrans

# cron設定
echo "=============================="
echo "========== cron設定 =========="
echo "=============================="

# 191 啟用cron守護程序
systemctl --now enable crond

# 192 /etc/crontab檔案所有權
chown root:root /etc/crontab

# 193 /etc/crontab檔案權限
chmod 600 /etc/crontab

# 194 /etc/cron.hourly目錄所有權
chown root:root /etc/cron.hourly

# 195 /etc/cron.hourly目錄權限
chmod 700 /etc/cron.hourly

# 196 /etc/cron.daily目錄所有權
chown root:root /etc/cron.daily

# 197 /etc/cron.daily目錄權限
chmod 700 /etc/cron.daily

# 198 /etc/cron.weekly目錄所有權
chown root:root /etc/cron.weekly

# 199 /etc/cron.weekly目錄權限
chmod 700 /etc/cron.weekly

# 200 /etc/cron.monthly目錄所有權
chown root:root /etc/cron.monthly

# 201 /etc/cron.monthly目錄權限
chmod 700 /etc/cron.monthly

# 202 /etc/cron.d目錄所有權
chown root:root /etc/cron.d

# 203 /etc/cron.d目錄權限
chmod 700 /etc/cron.d

# 204 at.allow與cron.allow檔案所有權
# 205 at.allow與cron.allow檔案權限
rm /etc/cron.deny
rm /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
chmod 600 /etc/cron.allow
chmod 600 /etc/at.allow

# 206 cron日誌紀錄功能 啟用
if grep -q "cron.* /var/log/cron" /etc/rsyslog.conf; then
    echo "/etc/rsyslog.conf 驗證OK!" >> ${FCB_LOG_SUCCESS}
else
    echo "/etc/rsyslog.conf cron.*驗證「不符合FCB規定」" >> ${FCB_LOG_FAILED}
fi

# 帳號與存取控制
echo "=============================="
echo "======== 帳號與存取控制 ========"
echo "=============================="

# 209 通行碼最小長度 12個字元以上
sed -i 's/# minlen = 8/minlen = 12/g' /etc/security/pwquality.conf

# 210 通行碼必須至少包含字元類別數量
sed -i 's/# minclass = 0/minclass = 4/g' /etc/security/pwquality.conf

# 211 通行碼必須至少包含1個以上數字
sed -i 's/# dcredit = 0/dcredit = -1/g' /etc/security/pwquality.conf

# 212 通行碼必須至少包含1個以上大寫字母個數
sed -i 's/# ucredit = 0/ucredit = -1/g' /etc/security/pwquality.conf

# 213 通行碼必須至少包含1個以上小寫字母個數
sed -i 's/# lcredit = 0/lcredit = -1/g' /etc/security/pwquality.conf

# 214 通行碼必須至少包含1個以上特殊字元個數
sed -i 's/# ocredit = 0/ocredit = -1/g' /etc/security/pwquality.conf

# 215 新通行碼與舊通行碼最少3個以上相異字元數
sed -i 's/# difok = 1/difok = 3/g' /etc/security/pwquality.conf

# 216 同一類別字元可連續使用個數，4個以下但必須大於0
sed -i 's/# maxclassrepeat = 0/maxclassrepeat = 4/g' /etc/security/pwquality.conf

# 217 相同字元可連續使用個數，3個以下但必須大於0
sed -i 's/# maxrepeat = 0/maxrepeat = 3/g' /etc/security/pwquality.conf

# 218 必須禁止使用字典檔單字做為通行碼
sed -i 's/# dictcheck = 1/# dictcheck = 1/g' /etc/security/pwquality.conf

# 219 帳戶鎖定閾值
sed -i 's/# deny = 3/deny = 5/g' /etc/security/faillock.conf

# 220 帳戶鎖定時間900秒以上
sed -i 's/# unlock_time = 600/unlock_time = 900/g' /etc/security/faillock.conf

# 221 強制執行通行碼歷程紀錄 3個以上

# 222 顯示登入失敗次數與日期 啟用
sed -i '$a session required\t\t\tpam_lastlog.so showfailed' /etc/pam.d/postlogin

# 223 通行碼雜湊演算法

# 224 通行碼最短使用期限
sed -i '132 s/^.*/PASS_MIN_DAYS\t1/g' /etc/login.defs
# chage --mindays 1 (使用者帳號名稱)

# 225 通行碼到期前提醒使用者變更通行碼 14天以上
sed -i '133 s/^.*/PASS_WARN_AGE\t14/g' /etc/login.defs
# chage --warndays 14 (使用者帳號名稱)

# 226 通行碼最長使用期限 90天以下，但必須大於0
sed -i '131 s/^.*/PASS_MAX_DAYS\t90/g' /etc/login.defs
# chage --maxdays 90 (使用者帳號名稱)

# 227 通行碼到期後，帳號停用前之天數 30天以下，但須大於0
useradd -D -f 30
# chage --inactive 30 (使用者帳號名稱)

# 228 登入嘗試失敗之延遲時間 4秒以上
sed -i '14 s/^.*/FAIL_DELAY\t4/g' /etc/login.defs

# 229 新使用者帳號預設建立使用者家目錄
sed -i '262 s/^.*/CREATE_HOME\tyes/g' /etc/login.defs

# 230 要求使用者必須經過身份鑑別才能提升權限

# 231 限制每個帳號可同時登入之數量 10以下，但須大於0



echo "===================================="
echo "======= DISK and File System ======="
echo "===================================="
echo "===================================="
echo "=========== 磁碟與檔案系統 ==========="
echo "===================================="
#source ./DiskFilesystem.sh

echo "============================================="
echo "== configuration and maintenance in system =="
echo "============================================="
echo "==================================="
echo "=========== 系統設定與維護 ==========="
echo "==================================="
#source ./ConfigMachSystem.sh

echo "============================================="
echo "== ServiceSystem =="
echo "============================================="
echo "===================================="
echo "======= 系統服務、安裝與維護軟體 ======="
echo "===================================="
#source ./ServiceSystem.sh

echo "================================="
echo "===== Configuration Network ====="
echo "================================="
echo "==================================="
echo "============= 網路設定 ============="
echo "==================================="
#source ./ConfigNetwork.sh

echo "=========================="
echo "======= LOG Config ======="
echo "=========================="
echo "=========================="
echo "======== 日誌與稽核 ========"
echo "=========================="
#source ./AuditLogConfig.sh

echo "==================================="
echo "===== Firewalld Configuration ====="
echo "==================================="

# ====================================
# === Change firewalld or ntfables ===
# ====================================


echo "==================================="
echo "===== Nftables Services Stop ======"
echo "==================================="

echo "===================================="
echo "======== SSH Configuration ========="
echo "===================================="
