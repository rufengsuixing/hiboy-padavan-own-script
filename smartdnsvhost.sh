#!/bin/sh
#smartdns host广告过滤配置文件更新，需要conf-file /opt/etc/smartdns/adblock.conf
#屏蔽的域名会返回soa而不是127.0.0.1，不会让浏览器试图连接
wgetcurl.sh /tmp/adblock1.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts
grep -E "^(127|0)" /tmp/adblock1.conf | awk '{print "address /"$2"/#"}' > /tmp/adblock.conf
rm /opt/etc/smartdns/adblock.conf
mv /tmp/adblock.conf /opt/etc/smartdns/adblock.conf
/etc/storage/script/Sh19_china-dns.sh start
rm /tmp/adblock1.conf