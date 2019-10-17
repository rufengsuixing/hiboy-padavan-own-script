#!/bin/sh
#需要将smartdns设置为dnsmasq上游或者重定向模式，smartdns需要已配置好
#smartdns 全面替换dnsmasq功能，放到/etc/storage/script/dm2smd.sh下运行
[ -s /etc/storage/bin/restart_dhcpd ] || ln -s /etc/storage/script/dm2smd.sh /etc/storage/bin/restart_dhcpd

sed -i '/#programaddconfig/,$d' /opt/etc/smartdns/smartdns.conf
echo "#programaddconfig" >> /opt/etc/smartdns/smartdns.conf

sed -i 's/^conf-dir=/\#conf-dir=/' /etc/storage/dnsmasq/dnsmasq.conf
grep '#conf-dir' /etc/storage/dnsmasq/dnsmasq.conf | awk -F = '{print $2}' > /tmp/sddc
while read line
do
    for file in `ls -d $line/*[!.][!s][!m][!d]`
    do
        cp -f $file $file.smd
        sed -i '/address=/d' $file.smd
        sed -i '/server=/d' $file.smd
        sed -i 's/ipset=/ipset /' $file.smd
        echo conf-file $file.smd >> /opt/etc/smartdns/smartdns.conf
    done
done < /tmp/sddc

sed -i 's/^conf-file=/\#conf-file=/' /etc/storage/dnsmasq/dnsmasq.conf
grep '#conf-file=' /etc/storage/dnsmasq/dnsmasq.conf | awk -F = '{print $2}' > /tmp/sddc
while read line
do
    cp -f $line $line.smd
    sed -i '/address=/d' $line.smd
    sed -i '/server=/d' $line.smd
    sed -i 's/ipset=/ipset /' $line.smd
    echo conf-file $line.smd >> /opt/etc/smartdns/smartdns.conf
done < /tmp/sddc

sed -i '/min-cache-ttl/d' /etc/storage/dnsmasq/dnsmasq.conf

if [ -s /tmp/dmsize ] ; then
    oldsize=`cat /tmp/dmsize`
else
    oldsize=0
fi
nowsize=`wc -c /etc/storage/dnsmasq/dnsmasq.conf | awk '{print $1}'`
echo $nowsize > /tmp/dmsize
killall smartdns
/opt/usr/sbin/smartdns -c /opt/etc/smartdns/smartdns.conf
if [ "$oldsize" -ne "$nowsize" ] ; then
/sbin/restart_dhcpd
fi