#!/bin/bash
# Program
#   Red Hat Enterprise Linux 8 Systemctl Security Check ShellScript
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

# 確認是否以root身分執行
if [[ $EUID -ne 0 ]]; then
    echo "This script MUST be run as root!!"
    exit 1
fi
echo '現在您正以root權限執行腳本...'

# Log異常檢視
# 符合FCB規範
FCB_SUCCESS="../Log/Success/TCBFCB_CheckSuccess-$(date '+%Y%m%d-%H%M%S').log"
# 需修正檢視
FCB_FIX="../Log/Fix/TCBFCB_CheckFix-$(date '+%Y%m%d-%H%M%S').log"
# 執行異常錯誤
FCB_ERROR="../Log/Error/TCBFCB_CheckError-$(date '+%Y%m%d-%H%M%S').log"
touch ${FCB_SUCCESS}
touch ${FCB_ERROR}
touch ${FCB_FAILED}

CheckPath="../Function/Check/"
echo "===================================="
echo "=========== 磁碟與檔案系統 ==========="
echo "===================================="
#source ./01DiskFilesystemCheck.sh 2>> ${FCB_ERROR}

echo "==================================="
echo "=========== 系統設定與維護 ==========="
echo "==================================="
source .${CheckPath}02SystemCheck.sh 2>> ${FCB_ERROR}

echo "===================================="
echo "======= 系統服務、安裝與維護軟體 ======="
echo "===================================="
source ${CheckPath}03SystemServiceCheck.sh 2>> ${FCB_ERROR}

echo "===================================="
echo "======= 安裝與維護軟體 ======="
echo "===================================="
source ${CheckPath}04InstallCheck.sh 2>> ${FCB_ERROR}

echo "==================================="
echo "============= 網路設定 ============="
echo "==================================="
source ${CheckPath}05NetworkCheck.sh 2>> ${FCB_ERROR}

echo "=========================="
echo "======== 日誌與稽核 ========"
echo "=========================="
source ${CheckPath}06AuditLogCheck.sh

echo "=========================="
echo "======== SElinux ========"
echo "=========================="
source ${CheckPath}07SELinuxCheck.sh 2>> ${FCB_ERROR}

echo "=========================="
echo "======== cron設定 ========"
echo "=========================="
source ${CheckPath}08CronCheck.sh 2>> ${FCB_ERROR}

echo "==================================="
echo "===== Firewalld Configuration ====="
echo "==================================="

echo "===================================="
echo "======== SSH Configuration ========="
echo "===================================="
source ${CheckPath}11SSHCheck.sh 2>> ${FCB_ERROR}

# 檢查錯誤檔案是否有內容
if [[ -s ${FCB_ERROR} ]]; then
    echo "腳本執行時發生錯誤，請查看 ${FCB_ERROR} 以取得詳細資訊。"
else
    echo "類別腳本執行完成，未發現程式異常錯誤。"
fi
