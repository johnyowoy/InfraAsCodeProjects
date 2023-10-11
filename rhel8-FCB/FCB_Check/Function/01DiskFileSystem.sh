# 磁碟與檔案系統
echo "CHECK [類別 磁碟與檔案系統] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [類別 磁碟與檔案系統] ****************************************" >> ${FCB_FIX}

echo "CHECK [Print Message] ****************************************" >> ${FCB_SUCCESS}
echo "CHECK [Print Message] ****************************************" >> ${FCB_FIX}

FilePath='/etc/modprobe.d/'

echo '1 停用cramfs檔案系統'
File='cramfs.conf'
if [ -f ${FilePath}${File} ] >/dev/null 2>&1; then
    if grep -q "^install.*${File}.*\/bin\/true$" ${FilePath}${File} >/dev/null 2>&1 || grep -q "^blacklist.*${File}$" ${FilePath}${File} >/dev/null 2>&1; then
        echo "OK: 1 停用cramfs檔案系統" >> ${FCB_SUCCESS}
    else
        cat <<EOF >> ${FCB_FIX}

FIX: 1 停用${File}檔案系統
====== 不符合FCB規範 ======
# ${FilePath}${File}檔案內容有誤
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
# 在${FilePath}目錄新增或編輯「${File}」檔案
vim ${FilePath}${File}
# 並在檔案中加入以下內容：
install ${File} /bin/true
blacklist ${File}
# 開啟終端機，執行下列指令，移除${File}模組：
rmmod ${File}
EOF
    fi
else
    cat <<EOF >> ${FCB_FIX}

FIX: 1 停用${File}檔案系統
====== 不符合FCB規範 ======
# 尚未建立${FilePath}${File}檔案
====== FCB建議設定值 ======
# 停用
====== FCB設定方法值 ======
# 在${FilePath}目錄新增或編輯「${File}」檔案
vim ${FilePath}${File}
# 並在檔案中加入以下內容：
install ${File} /bin/true
blacklist ${File}
# 開啟終端機，執行下列指令，移除${File}模組：
rmmod ${File}
EOF
fi


    echo "2 停用squashfs檔案系統"
    if [ -f /etc/modprobe.d/squashfs.conf ]; then
        squashfsfile='/etc/modprobe.d/squashfs.conf'
        if grep install' 'squashfs' '\/bin\/true ${squashfsfile} >/dev/null; then
            if grep blacklist' 'squashfs ${squashfsfile} >/dev/null; then
                echo "檢查OK"
            else
                sed -i '$a blacklist squashfs' ${squashfsfile}
                rmmod squashfs
                echo ${squashfsfile}"已新增blacklist squashfs"
            fi
        else
            sed -i '$a install squashfs /bin/true' ${squashfsfile}
            if grep blacklist' 'squashfs ${squashfsfile} >/dev/null; then
                rmmod squashfs
                echo ${squashfsfile}"已新增install squashfs /bin/true"
            else
                sed -i '$a blacklist squashfs' ${squashfsfile}
                rmmod squashfs
                echo ${squashfsfile}"已新增install squashfs /bin/true"
                echo ${squashfsfile}"已新增blacklist squashfs"
            fi
        fi
    else
        touch /etc/modprobe.d/squashfs.conf
        echo "# Disable Mounting of squashfs Filesystems - modprobe" >> /etc/modprobe.d/squashfs.conf
        sed -i '$a install squashfs /bin/true' /etc/modprobe.d/squashfs.conf
        sed -i '$a blacklist squashfs' /etc/modprobe.d/squashfs.conf
        rmmod squashfs
    fi

    echo "3 停用udf檔案系統"
    if [ -f /etc/modprobe.d/udf.conf ]; then
        udffile='/etc/modprobe.d/udf.conf'
        if grep install' 'udf' '\/bin\/true ${udffile} >/dev/null; then
            if grep blacklist' 'udf ${udffile} >/dev/null; then
                echo "檢查OK"
            else
                sed -i '$a blacklist udf' ${udffile}
                rmmod udf
                echo ${udffile}"已新增blacklist udf"
            fi
        else
            sed -i '$a install udf /bin/true' ${udffile}
            if grep blacklist' 'udf ${udffile} >/dev/null; then
                rmmod udf
                echo ${udffile}"已新增install udf /bin/true"
            else
                sed -i '$a blacklist udf' ${udffile}
                rmmod udf
                echo ${udffile}"已新增install udf /bin/true"
                echo ${udffile}"已新增blacklist udf"
            fi
        fi
    else
        touch /etc/modprobe.d/udf.conf
        echo "# Disable Mounting of udf Filesystems - modprobe" >> /etc/modprobe.d/udf.conf
        sed -i '$a install udf /bin/true' /etc/modprobe.d/udf.conf
        sed -i '$a blacklist udf' /etc/modprobe.d/udf.conf
        rmmod udf
    fi

    echo "4 設定/tmp目錄之檔案系統 tmpfs"
    sed -i '$a tmpfs\t\t\t/tmp\t\t\ttmpfs\tdefaults,rw,nosuid,nodev,noexec,relatime\t0 0' /etc/fstab

    echo "5~7 啟用 設定/tmp目錄之nodev,nosuid,noexec選項"
    sed -i '$a /tmp\t\t\t/var/tmp\t\tnone\tdefaults,nodev,nosuid,noexec\t\t0 0' /etc/fstab

    # 08 設定/var目錄之檔案系統 使用獨立分割磁區或邏輯磁區

    # 09 設定/var/tmp目錄之檔案系統 使用獨立分割磁區或邏輯磁區

    # 10 設定/var/tmp目錄之nodev選項 啟用

    # 11 設定/var/tmp目錄之nosuid選項 啟用

    # 12 設定/var/tmp目錄之noexe選項 啟用

    # 13 設定/var/log目錄之檔案系統 使用獨立分割磁區或邏輯磁區

    # 30 停用autofs服務
    echo "30 停用autofs服務"
    systemctl --now disable autofs

    # 31 停用USB儲存裝置
    echo "31 停用USB儲存裝置"
    touch /etc/modprobe.d/usb-storage.conf
    echo "# disable usb storage" > /etc/modprobe.d/usb-storage.conf
    sed -i '$a install usb-storage /bin/true' /etc/modprobe.d/usb-storage.conf
    sed -i '$a blacklist usb-storage' /etc/modprobe.d/usb-storage.conf
    rmmod usb-storage
