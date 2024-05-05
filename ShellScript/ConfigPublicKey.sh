# Set User Public Key
# 1. 建立 ~/.ssh 檔案，注意權限需要為 700
if [ -d "~/.ssh" ]; then
    echo "Folder .ssh does exists"
else
    mkdir ~/.ssh
fi

if stat -c "%a" ~/.ssh | grep 700 >/dev/null; then
    echo ".ssh 權限檢查OK"
else
    chmod 700 ~/.ssh
    echo ".ssh 已設定700"
fi
cd ~
read -p "請輸入您的Public Key (EX: xxx.pub): " pubkey
if [ -f "$pubkey" ]; then
    mv $pubkey ~/.ssh
    cd .ssh
    # 2. 將公鑰檔案內的資料使用 cat 轉存到 authorized_keys 內
    cat $pubkey >> authorized_keys
    # 檔案的權限設定為644
    chmod 644 authorized_keys
    chmod 644 $pubkey
else
    echo "File $pubkey does not exists"
fi
