#!/bin/sh
#功能：如果下载失败使用本地缓存/media/AiCard_02/temp
#使用方法：通过mount --bind 替换 wgetcurl.sh
output=$1
url1=$2
if [ $url1 = "http://passport.baidu.com/passApi/img/small_blank.gif" ] ; then
	curltest=`which curl`
	if [ -z "$curltest" ] ; then
		wget --continue --no-check-certificate  -O $output $url1
	else
		curl -k -s -o $output $url1
	fi
	exit 0
fi
url2=$3
[ -z "$url2" ] && url2=$url1
url1c=`echo $url1 | sed 's@/@\\\/@g'`
url2c=`echo $url2 | sed 's@/@\\\/@g'`
rm -f $output
templine=$(sed -n "/$url1c/=" /media/AiCard_02/temp/templist.txt)
if [ -z "$templine" ] ; then
	templine=$(sed -n "/$url2c/=" /media/AiCard_02/temp/templist.txt)
	if [ ! -z "$templine" ] ; then
		cp -f /media/AiCard_02/temp/$templine $output
		logger -t "【下载】" "命中缓存:【$output】 URL:【$url2】"
		exit 0
	fi
else
	cp -f /media/AiCard_02/temp/$templine $output
	logger -t "【下载】" "命中缓存:【$output】 URL:【$url1】"
	exit 0
fi
curltest=`which curl`
if [ -z "$curltest" ] ; then
	wget --continue --no-check-certificate  -O $output $url1
else
	curl -k -s -o $output $url1
fi

if [ ! -s "$output" ] ; then
	logger -t "【下载】" "重新下载失败:【$output】 URL:【$url1】"
	logger -t "【下载】" "重新下载:【$output】 URL:【$url2】"
	rm -f $output
	sleep 2
	curltest=`which curl`
	if [ -z "$curltest" ] ; then
		wget --continue --no-check-certificate  -O $output $url2
	else
		curl -k -s -o $output $url2
	fi
		if [ -s "$output" ] ; then
			echo "$url2" >> /media/AiCard_02/temp/templist.txt
			templine=`sed -n '$=' /media/AiCard_02/temp/templist.txt`
			cp -f $output /media/AiCard_02/temp/$templine
		fi
else
echo "$url1" >> /media/AiCard_02/temp/templist.txt
templine=`sed -n '$=' /media/AiCard_02/temp/templist.txt`
cp -f $output /media/AiCard_02/temp/$templine
fi
if [ ! -s "$output" ] ; then
	logger -t "【下载】" "下载失败:【$output】 URL:【$url2】"
else
	chmod 777 $output
fi