
# 建立ansible群組並且將使用者加入群組
groupadd ansible
usermod -aG ansible
if grep '^%ansible.*ALL=(ALL).*NOPASSWD:\ ALL$' /etc/sudoers >/dev/null; then
    echo "ansible群組已存在設定"
else
   sed -i '$a %ansible\ ALL=(ALL)\ NOPASSWD:\ ALL' /etc/sudoers
   echo "OK: /etc/sudoers設定完成"
fi
