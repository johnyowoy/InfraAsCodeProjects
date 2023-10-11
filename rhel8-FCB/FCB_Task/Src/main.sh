#!/bin/bash
# Program
#   Red Hat Enterprise Linux 8 Systemctl Security Check ShellScript
#   FCB金融組態基準-Red Hat Enterprise Linux 8
# History
#   2023/04/19    JINHAU, HUANG
# Version
#   v1.0

# 確認是否以root身分執行
if [[ $EUID -ne 0 ]]; then
    echo "This script MUST be run as root!!"
    exit 1
fi
echo '現在您正以root權限執行腳本...'

# Log異常檢視
# 符合FCB規範
FCB_SUCCESS="~/Log/Success/TCBFCB_TaskSuccess-$(date '+%Y%m%d-%H%M%S').log"
# 執行異常錯誤
FCB_ERROR="~/Log/Error/TCBFCB_TaskError-$(date '+%Y%m%d-%H%M%S').log"
touch ${FCB_LOG_SUCCESS}
touch ${FCB_LOG_ERROR}

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
