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

# ==============
# 問題討論項次
# ==============
# 96 有些套件沒有snmpv3，只有snmpv2
# ==============
# 回報給資安科
# ==============
# 尚未確認實作 項次
# Number
# 08~28 獨立分割磁區或邏輯磁區，fstab nodev 啟用
# ==========================================
# 系統設定與維護
# 37 定期檢查檔案系統完整性 aide crontab 時間討論
# 88
# 91 shadow 需要討論，技術問題
# 93 chrony校時設定
# 108
# 119 不回應ICMP廣播請求
# 158
# 161 sudo logfile
# 189
# 207 208 221
# 223 已經預設 ENCRYPT_METHOD SHA512
# 230
# 266
# 277
# SSH 5

# 確認是否以root身分執行
if [[ $EUID -ne 0 ]]; then
    echo "This script MUST be run as root!!"
    exit 1
fi
echo '現在您正以root權限執行腳本...'

# Log異常檢視
# 符合FCB規範
FCB_SUCCESS="~/Log/Success/TCBFCB_CheckSuccess-$(date '+%Y%m%d-%H%M%S').log"
# 需修正檢視
FCB_FIX="~/Log/Fix/TCBFCB_CheckFix-$(date '+%Y%m%d-%H%M%S').log"
# 執行異常錯誤
FCB_ERROR="~/Log/Error/TCBFCB_CheckError-$(date '+%Y%m%d-%H%M%S').log"
touch ${FCB_SUCCESS}
touch ${FCB_ERROR}
touch ${FCB_FAILED}

echo "===================================="
echo "======= DISK and File System ======="
echo "===================================="
echo "===================================="
echo "=========== 磁碟與檔案系統 ==========="
echo "===================================="
source ./01DiskFilesystem.sh 2>> ${FCB_ERROR}

echo "============================================="
echo "== configuration and maintenance in system =="
echo "============================================="
echo "==================================="
echo "=========== 系統設定與維護 ==========="
echo "==================================="
#source ./02SystemConfig.sh 2>> ${FCB_ERROR}

echo "============================================="
echo "== ServiceSystem =="
echo "============================================="
echo "===================================="
echo "======= 系統服務、安裝與維護軟體 ======="
echo "===================================="
#source ./03SystemService.sh 2>> ${FCB_ERROR}

echo "============================================="
echo "== Installation =="
echo "============================================="
echo "===================================="
echo "======= 安裝與維護軟體 ======="
echo "===================================="
#source ./04Installation.sh 2>> ${FCB_ERROR}


echo "================================="
echo "===== Configuration Network ====="
echo "================================="
echo "==================================="
echo "============= 網路設定 ============="
echo "==================================="
#source ./05NetworkConfig.sh 2>> ${FCB_ERROR}

echo "=========================="
echo "======= LOG Config ======="
echo "=========================="
echo "=========================="
echo "======== 日誌與稽核 ========"
echo "=========================="
#source ./06AuditLogConfig.sh

echo "=========================="
echo "======= SELinux Config ======="
echo "=========================="
echo "=========================="
echo "======== SElinux ========"
echo "=========================="
#source ./07SELinuxConfig.sh 2>> ${FCB_ERROR}

echo "=========================="
echo "======= Cron Config ======="
echo "=========================="
echo "=========================="
echo "======== cron設定 ========"
echo "=========================="
#source ./08CronConfig.sh 2>> ${FCB_ERROR}

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

# 檢查錯誤檔案是否有內容
if [[ -s ${FCB_ERROR} ]]; then
    echo "腳本執行時發生錯誤，請查看 ${FCB_ERROR} 以取得詳細資訊。"
else
    echo "類別腳本執行完成，未發現程式異常錯誤。"
fi
