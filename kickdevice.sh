#!/bin/sh
#脚本功能，踢出信号较好的2.4g设备使之连接到5g，如果踢出后没有连到5g，则加入踢出白名单，因为这样的设备可能会执着于2.4，踢出会导致网络不稳定
#用contab轮询即可
curl 127.0.0.1/Main_WStatus2g_Content.asp | grep 'M  \-[0-9][0-9]' > /tmp/2gmaclistt
#不确定5g支持设备踢出阈值40，支持5g踢出设备踢出阈值48
awk '$9>-40 {print $1}' /tmp/2gmaclistt > /tmp/2gmaclistmin
awk '$9>-48 {print $1}' /tmp/2gmaclistt > /tmp/2gmaclist
touch /etc/storage/mac2g.txt
touch /etc/storage/mac5g.txt

awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /etc/storage/mac2g.txt /tmp/2gmaclist > /tmp/2gmacsame.txt
if [ -s /tmp/2gmacsame.txt ] ; then
        awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/2gmacsame.txt /tmp/2gmaclist > /tmp/2gmacuniq.txt
else
        cat /tmp/2gmaclist > /tmp/2gmacuniq.txt
fi

awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /etc/storage/mac5g.txt /tmp/2gmacuniq.txt > /tmp/25gmackill.txt

if [ -s /tmp/25gmackill.txt ] ; then
    awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/25gmackill.txt /tmp/2gmacuniq.txt > /tmp/2gmactest.txt
else
        cat /tmp/2gmacuniq.txt > /tmp/2gmactest.txt
fi
awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /tmp/2gmactest.txt /tmp/2gmaclistmin > /tmp/2gmackill.txt
while read line
do
echo $line
iwpriv ra0 set DisConnectSta=$line
iwpriv ra0 set DisConnectSta=$line
logger -t "【test2g】" "$line被踢掉"
done < /tmp/2gmackill.txt
while read line
do
echo $line
iwpriv ra0 set DisConnectSta=$line
logger -t "【剔除25g】" "$line被踢掉"
done < /tmp/25gmackill.txt

curl 127.0.0.1/Main_WStatus_Content.asp | grep 'M  \-[0-9][0-9]' > /tmp/5gmaclistt
awk '{print $1}' /tmp/5gmaclistt > /tmp/5gmaclist

awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /etc/storage/mac5g.txt /tmp/5gmaclist > /tmp/5gmacsame.txt
if [ -s /tmp/5gmacsame.txt ] ; then
    awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/5gmacsame.txt /tmp/5gmaclist > /tmp/5gmacuniq.txt
else
        cat /tmp/5gmaclist > /tmp/5gmacuniq.txt
fi

cat /tmp/5gmacuniq.txt >> /etc/storage/mac5g.txt
awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /tmp/5gmacuniq.txt /tmp/2gmackill.txt > /tmp/25gmac.txt
if [ -s /tmp/25gmac.txt ] ; then
    awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/25gmac.txt /tmp/2gmackill.txt >> /etc/storage/mac2g.txt
else
        cat /tmp/2gmackill.txt >> /etc/storage/mac2g.txt
fi