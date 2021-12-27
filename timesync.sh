#/usr/bin/env bash
#将脚本上传到linux中的/root目录，在root账户下执行bash timesync.sh 
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'

echo -e "${BLUE}开始获取京东服务器时间${PLAIN}"
Time=$(curl -s "https://api.m.jd.com/client.action?functionId=queryMaterialProducts&client=wh5" | grep '{"currentTime":'| sed 's/^.*"currentTime"://g' | sed 's/,"currentTime2":.*//g' | sed 's/\"//g' )
date -s "$(curl -s "https://api.m.jd.com/client.action?functionId=queryMaterialProducts&client=wh5" | grep '{"currentTime":'| sed 's/^.*"currentTime"://g' | sed 's/,"currentTime2":.*//g' | sed 's/\"//g' )"
echo -e "${BLUE}当前京东服务器时间为${PLAIN}${RED}${Time}${PLAIN}"
echo -e "${BLUE}开始进行时间同步${PLAIN}"
echo -e "${BLUE}与京东服务器时间同步完成，脚本将自动退出。${PLAIN}"
exit
