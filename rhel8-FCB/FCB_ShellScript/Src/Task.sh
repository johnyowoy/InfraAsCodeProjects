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

# 執行異常錯誤
FCB_ERROR="../Log/Error/TCBFCB_TaskError-$(date '+%Y%m%d-%H%M%S').log"
touch ${FCB_SUCCESS}
touch ${FCB_ERROR}

TaskPath="../Function/Task/"
echo "===================================="
echo "=========== 磁碟與檔案系統 ==========="
echo "===================================="
#source ./01DiskFilesystemTask.sh 2>> ${FCB_ERROR}

echo "==================================="
echo "=========== 系統設定與維護 ==========="
echo "==================================="
#source ${TaskPath}02SystemTask.sh 2>> ${FCB_ERROR}

echo "===================================="
echo "======= 系統服務、安裝與維護軟體 ======="
echo "===================================="
source ${TaskPath}03SystemServiceTask.sh 2>> ${FCB_ERROR}

echo "===================================="
echo "======= 安裝與維護軟體 ======="
echo "===================================="
#source ${TaskPath}04InstallTask.sh 2>> ${FCB_ERROR}

echo "==================================="
echo "============= 網路設定 ============="
echo "==================================="
source ${TaskPath}05NetworkTask.sh 2>> ${FCB_ERROR}

echo "=========================="
echo "======== 日誌與稽核 ========"
echo "=========================="
source ${TaskPath}06AuditLogTask.sh

echo "=========================="
echo "======== SElinux ========"
echo "=========================="
source ${TaskPath}07SELinuxTask.sh 2>> ${FCB_ERROR}

echo "=========================="
echo "======== cron設定 ========"
echo "=========================="
source ${TaskPath}08CronTask.sh 2>> ${FCB_ERROR}

echo "=========================="
echo "======== 帳號與存取控制 ========"
echo "=========================="
source ${TaskPath}09AccessTask.sh 2>> ${FCB_ERROR}

echo "==================================="
echo "===== Firewalld Configuration ====="
echo "==================================="
source ${TaskPath}10FirewalldTask.sh 2>> ${FCB_ERROR}

echo "===================================="
echo "======== SSH Configuration ========="
echo "===================================="

# 檢查錯誤檔案是否有內容
if [[ -s ${FCB_ERROR} ]]; then
    echo "腳本執行時發生錯誤，請查看 ${FCB_ERROR} 以取得詳細資訊。"
else
    echo "類別腳本執行完成，未發現程式異常錯誤。"
fi
