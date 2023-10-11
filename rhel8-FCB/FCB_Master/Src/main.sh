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
touch ${FCB_SUCCESS}
touch ${FCB_ERROR}

echo "===================================="
echo "======= DISK and File System ======="
echo "===================================="
echo "===================================="
echo "=========== 磁碟與檔案系統 ==========="
echo "===================================="
#source ./01DiskFilesystem.sh 2>> ${FCB_ERROR}

echo "============================================="
echo "== configuration and maintenance in system =="
echo "============================================="
echo "==================================="
echo "=========== 系統設定與維護 ==========="
echo "==================================="
source ./02SystemConfig.sh 2>> ${FCB_ERROR}

echo "============================================="
echo "=============== ServiceSystem ==============="
echo "============================================="
echo "===================================="
echo "======= 系統服務、安裝與維護軟體 ======="
echo "===================================="
source ./03SystemService.sh 2>> ${FCB_ERROR}

echo "============================================="
echo "=============== Installation ==============="
echo "============================================="
echo "===================================="
echo "======= 安裝與維護軟體 ======="
echo "===================================="
# source ./04Installation.sh 2>> ${FCB_ERROR}


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