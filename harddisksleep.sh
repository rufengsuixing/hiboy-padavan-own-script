#!/bin/sh
# hdparm无法休眠，显示错误，-y 和 -Y 选项报错
# sdparm无法修改休眠数据
# 自制替代脚本 contab加入即可
hdidle=`nvram get hdidle`
if [ ! -f /tmp/idledata ] ; then
    nvram set hdidle=0
else
    grep "`cat /tmp/idledata`" /proc/diskstats
    if [ "$?" -eq "0" ] ; then
        if [ "$hdidle" -eq 0 ] ; then
            sync
            sleep 30
            sdparm --readonly --command=stop /dev/sda
            logger -t "【idlehd】" "硬盘强制休眠"
            nvram set hdidle=1
        fi
    else
        nvram set hdidle=0
    fi
fi
cat /proc/diskstats | grep "0 sda" > /tmp/idledata
return 0