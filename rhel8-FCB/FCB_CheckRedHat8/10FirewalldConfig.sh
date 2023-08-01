#/bin/bash

echo "==================================="
echo "===== Firewalld Configuration ====="
echo "==================================="

# ====================================
# === Change firewalld or ntfables ===
# ====================================

# 1 安裝firewalld防火牆套件
dnf install -y firewalld

# 2 firewalld自動啟用服務
systemctl --now enable firewalld

# 3 停用iptables服務
systemctl --now mask iptables

# 4 停用nftables服務
systemctl --now mask nftables

# 5 firewalld防火牆設定區域
firewall-cmd --set-default-zone=public

echo "==================================="
echo "===== Nftables Services Stop ======"
echo "==================================="