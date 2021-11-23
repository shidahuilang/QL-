#!/usr/bin/env bash
#

TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
echo
TIME l "安装依赖..."
echo
TIME y "安装依赖需要时间，请耐心等待!"
echo
sleep 2
npm config set registry https://mirrors.huaweicloud.com/repository/npm/
npm config get registry
TIME l "安装依赖png-js"
npm install -g png-js
TIME l "安装依赖date-fns"
npm install -g date-fns
TIME l "安装依赖axios"
npm install -g axios
TIME l "安装依赖crypto-js"
npm install -g crypto-js
TIME l "安装依赖md5"
npm install -g md5
TIME l "安装依赖ts-md5"
npm install -g ts-md5
TIME l "安装依赖tslib"
npm install -g tslib
TIME l "安装依赖@types/node"
npm install -g @types/node
TIME l "安装依赖requests"
npm install -g requests
TIME l "安装依赖tough-cookie"
npm install -g tough-cookie
TIME l "安装依赖jsdom"
npm install -g jsdom
TIME l "安装依赖download"
npm install -g download
TIME l "安装依赖tunnel"
npm install -g tunnel
TIME l "安装依赖fs"
npm install -g fs
TIME l "安装依赖ws"
npm install -g ws
TIME l "安装依赖js-base64"
npm install -g js-base64
TIME l "安装依赖jieba"
npm install -g jieba
TIME l "安装pnpm"
cd /ql/scripts/ && apk add --no-cache build-base g++ cairo-dev pango-dev giflib-dev && pnpm install && pnpm i ts-node typescript @types/node date-fns axios download
cd /ql
pip3 install canvas
cd /ql
TIME l "安装python3"
apk add python3 zlib-dev gcc jpeg-dev python3-dev musl-dev freetype-dev
cd /ql
task curtinlv_JD-Script_jd_tool_dl.py
echo
TIME g "依赖安装完毕..."
echo
exit 0
