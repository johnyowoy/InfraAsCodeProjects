#!/bin/bash
# Program:
#     Main
# History:
#     2024-07-29 JinHau, Huang

## Kubernetes Config
while true
do
    read -p "是否設定K8s (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        source K8sConfig-RedHatBased.sh
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done

while true
do
    read -p "是否設定Ansible (Y/N): " yn
    if [ "${yn}" == "Y" ] || [ "${yn}" == "y" ]; then
        echo "OK~~~"
        source AnsibleConfig.sh
        break
    elif [ "${yn}" == "N" ] || [ "${yn}" == "n" ]; then
        echo "OK, Continue..."
        break
    else
        echo "請輸入 Y/y 或 N/n"
    fi
done