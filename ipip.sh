#!/bin/bash
# IP检测，微信TG通知

#----------------------------
# 计划任务，每隔5分钟运行脚本
# */5 * * * * /bash/ip.sh #IP检测，微信TG通知
# 手动运行脚本
# /bash/ip.sh
# 添加运行权限
# chmod +x /bash/ip.sh
#----------------------------

wx_api="43.XX.XXX.XXX:20086"
wx_sckey="dahuilang"
tg_api="api.workers.dev"
tg_id="120908"
tg_sckey="1622585953:AAGeydQkqix45tZbWyY_LGY"
drivers="Docker_Server"
dirfile='/volume1/docker/ip/IP'
log='/volume1/docker/ip/log/IP.log'
# 获取时间
TIME=『$(date +"%m月%d日 %H:%M:%S")』

# 判断文件是否存在，不存在就新建
if [ ! -f "$dirfile" ];then
touch $dirfile
fi

# 获得外网地址
    arIpAddress() {
    curltest=`which curl`
    if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
        #wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "https://www.ipip.net" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "ip.6655.com/ip.aspx" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "ip.3322.net" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "ip.cip.cc" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "icanhazip.com"
    else
        #curl -L -k -s "https://www.ipip.net" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #curl -L -k -s "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #curl -L -k -s ip.6655.com/ip.aspx | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        curl -L -k -s ip.3322.net | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #curl -L -k -s ip.cip.cc | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #curl icanhazip.com
    fi
    }
# 读取最近外网地址
    IPAddress() {
        cat $dirfile
    }

curltest=`which curl`
ping_text=`ping -4 114.114.114.114 -c 1 -w 2 -q`
ping_TIME=`echo $ping_text | awk -F '/' '{print $4}'| awk -F '.' '{print $1}'`
ping_loss=`echo $ping_text | awk -F ', ' '{print $3}' | awk '{print $1}'`
if [ ! -z "$ping_TIME" ] ; then
    echo "$TIME ping：$ping_TIME ms 丢包率：$ping_loss" >> $log
 else
    echo "$TIME ping：失效" >> $log

fi
if [ ! -z "$ping_TIME" ] ; then
echo "$TIME Internet online 互联网在线" >> $log

if [ "1" = "1" ] ; then
    hostIP=$(arIpAddress)
    hostIP=`echo $hostIP | head -n1 | cut -d' ' -f1`
    if [ "$hostIP"x = "x"  ] ; then
        curltest=`which curl`
        if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
            [ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "ip.6655.com/ip.aspx" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "ip.3322.net" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "https://www.ipip.net/" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "ip.cip.cc" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            #[ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --no-check-certificate --quiet --output-document=- "icanhazip.com"`
        else
            [ "$hostIP"x = "x"  ] && hostIP=`curl -L -k -s ip.6655.com/ip.aspx | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`curl -L -k -s "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`curl -L -k -s ip.3322.net | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`curl -L -k -s "https://www.ipip.net" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`curl -L -k -s ip.cip.cc | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            #[ "$hostIP"x = "x"  ] && hostIP=`curl icanhazip.com`
        fi
    fi
    lastIP=$(IPAddress)
    if [ "$lastIP" != "$hostIP" ] && [ ! -z "$hostIP" ] ; then
    sleep 1
        hostIP=$(arIpAddress)
        hostIP=`echo $hostIP | head -n1 | cut -d' ' -f1`
        lastIP=$(IPAddress)
    fi
    if [ "$lastIP" != "$hostIP" ] && [ ! -z "$hostIP" ] ; then
        echo "$TIME 【互联网 IP 变动】" "目前 IP: ${hostIP}" >> $log
        echo "$TIME 【互联网 IP 变动】" "上次 IP: ${lastIP}" >> $log
        echo "$TIME 【通知推送】" "互联网IP变动:${hostIP}" >> $log
        curl -L -s "http://$wx_api/push?token=$wx_sckey&message=【${drivers}】你的设备IP发生变动,新的IP：${hostIP}" >> $log
        curl -L -s "https://$tg_api/bot$tg_sckey/sendMessage" -d "chat_id=$tg_id&text=【${drivers}】你的设备IP发生变动""`echo -e " \n "`""新的IP：${hostIP}" >> $log
        echo -n $hostIP > $dirfile
        echo
		docker restart nark
    else
        echo "$TIME 【互联网 IP 正常】" "目前 IP: ${hostIP}" >> $log
    fi
fi

else
echo "$TIME Internet down 互联网断开" >> $log

fi
