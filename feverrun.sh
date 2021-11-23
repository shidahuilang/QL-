#!/usr/bin/env bash
# 
## 本脚本搬运并模仿 liuqitoday
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
if [ "$(grep -c \"token\" /ql/config/auth.json)" = 0 ]; then
	echo
	TIME r "提示：请先登录青龙面板再执行命令安装任务!"
	echo
	exit 1
fi
dir_shell=/ql/config
dir_script=/ql/scripts
config_shell_path=$dir_shell/config.sh
extra_shell_path=$dir_shell/extra.sh
code_shell_path=$dir_shell/code.sh
disable_shell_path=$dir_script/disableDuplicateTasksImplement.py
wskey_shell_path=$dir_script/wskey.py
crypto_shell_path=$dir_script/crypto-js.js
wx_jysz_shell_path=$dir_script/wx_jysz.js
OpenCard_shell_path=$dir_script/raw_jd_OpenCard.py
task_before_shell_path=$dir_shell/task_before.sh
sample_shell_path=/ql/sample/config.sample.sh
mkdir -p /ql/qlwj
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/auth.json > /ql/qlwj/auth.json
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/crypto-js.js > /ql/qlwj/crypto-js.js
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/config.sample.sh > /ql/qlwj/config.sample.sh
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/extra.sh > /ql/qlwj/extra.sh
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/raw_jd_OpenCard.py > /ql/qlwj/raw_jd_OpenCard.py
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/wskey.py > /ql/qlwj/wskey.py
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/curtinlv_JD-Script_jd_tool_dl.py > /ql/qlwj/curtinlv_JD-Script_jd_tool_dl.py
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/jd_Evaluation.py > /ql/qlwj/jd_Evaluation.py
curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/Aaron-lv/jd_get_share_code.js > /ql/qlwj/jd_get_share_code.js
chmod -R +x /ql/qlwj
cp -Rf /ql/qlwj/config.sample.sh /ql/config/config.sh
cp -Rf /ql/qlwj/config.sample.sh /ql/sample/config.sample.sh
cp -Rf /ql/qlwj/extra.sh /ql/config/extra.sh
cp -Rf /ql/qlwj/extra.sh /ql/sample/extra.sample.sh
cp -Rf /ql/qlwj/raw_jd_OpenCard.py /ql/scripts/raw_jd_OpenCard.py
cp -Rf /ql/qlwj/wskey.py /ql/scripts/wskey.py
cp -Rf /ql/qlwj/crypto-js.js /ql/scripts/crypto-js.js
cp -Rf /ql/qlwj/curtinlv_JD-Script_jd_tool_dl.py /ql/scripts/curtinlv_JD-Script_jd_tool_dl.py
cp -Rf /ql/qlwj/jd_Evaluation.py /ql/scripts/jd_Evaluation.py
echo

# 将 extra.sh 添加到定时任务
if [ "$(grep -c extra /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [每8小时更新任务]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"每8小时更新任务","command":"ql extra","schedule":"* */8 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1624782068473'
fi
sleep 2
echo
if [ "$(grep -c wskey.py /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [早9晚11点更新WSKEY]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"早9晚11点更新WSKEY","command":"task wskey.py","schedule":"0 9,23 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1633428022377'
fi
sleep 2
echo
# 将 bot 添加到定时任务
if [ "$(grep -c bot /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [拉取机器人]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"拉取机器人","command":"ql bot","schedule":"13 14 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1626247933219'
fi
sleep 2
echo
# 将 raw_jd_OpenCard.py 添加到定时任务
if [ "$(grep -c raw_jd_OpenCard.py /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [JD入会开卡领取京豆]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"JD入会开卡领取京豆","command":"task raw_jd_OpenCard.py","schedule":"8 8,15,20 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1634041221437'
fi
sleep 2
echo
# 将 jd_Evaluation.py 添加到定时任务
if [ "$(grep -c jd_Evaluation.py /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [自动评价助手]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"京东全自动评价","command":"task jd_Evaluation.py","schedule":"0 6 */3 * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1637560543233'
fi
sleep 2
echo
# 将 jd_get_share_code.js 添加到定时任务
if [ "$(grep -c jd_get_share_code.js /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [获取互助码1-5]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"获取互助码1-5","command":"task jd_get_share_code.js desi JD_COOKIE 1-5","schedule":"20 13 * * 6"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1637505495835'
fi
sleep 2
echo
# 将 jd_get_share_code.js 添加到定时任务
echo
TIME g "添加任务 [获取互助码6-10]"
echo
# 获取token
token=$(cat /ql/config/auth.json | jq --raw-output .token)
curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"获取互助码6-10","command":"task jd_get_share_code.js desi JD_COOKIE 6-10","schedule":"22 13 * * 6"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1637509073623'
sleep 2
echo
if [[ "$(grep -c JD_WSCK=\"pin= /ql/config/env.sh)" = 1 ]]; then
    echo
    TIME g "执行WSKEY转换PT_KEY操作"
    task wskey.py |tee azcg.log
    echo
    if [[ `ls -a |grep -c "wskey添加成功" /ql/azcg.log` -ge '1' ]] && [[ `ls -a |grep -c "wskey添加失败" /ql/azcg.log` = '0' ]] || [[ `ls -a |grep -c "wskey更新成功" /ql/azcg.log` -ge '1' ]] && [[ `ls -a |grep -c "wskey更新失败" /ql/azcg.log` = '0' ]]; then
    	echo
    	TIME g "WSKEY转换PT_KEY成功"
	echo
    else
    	echo
    	TIME r "WSKEY转换PT_KEY失败，检查KEY的格式对不对，或者有没有失效，如果是多个WSKEY的话，或者有个别KEY出问题"
	echo
    fi
fi
echo
echo
echo
TIME y "拉取feverrun大佬的自动助力脚本"
echo
echo
rm -fr /ql/azcg.log
ql extra |tee azcg.log
if [[ "$(grep -c JD_WSCK=\"pin= /ql/config/env.sh)" = 0 ]] && [[ "$(grep -c JD_COOKIE=\"pt_key= /ql/config/env.sh)" = 0 ]]; then
    TIME r "没发现WSKEY或者PT_KEY，请注意设置好KEY，要不然脚本不会运行!"
fi
echo
if [[ `ls -a |grep -c "添加成功" /ql/azcg.log` -ge '1' ]] && [[ `ls -a |grep -c "执行结束" /ql/azcg.log` -ge '1' ]] || [[ `ls -a |grep -c "开始更新仓库" /ql/azcg.log` -ge '1' ]]; then
	cp -Rf /ql/qlwj/auth.json /ql/config/auth.json
	TIME g "脚本安装完成，正在重启青龙面板，请稍后...!"
	rm -fr /ql/azcg.log
	rm -rf /ql/qlwj
else
	cp -Rf /ql/qlwj/auth.json /ql/config/auth.json
	TIME r "脚本安装失败,请再次执行一键安装脚本尝试安装"
	rm -fr /ql/azcg.log
	rm -rf /ql/qlwj
	exit 1
fi
echo
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
