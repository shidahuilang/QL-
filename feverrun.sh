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
disable_shell_path=$dir_script/Disable.py
wskey_shell_path=$dir_script/wskey.py
crypto_shell_path=$dir_script/crypto-js.js
Evaluation_shell_path=$dir_script/Evaluation.py
#curtinlv_JD-Script_jd_tool_dl_shell_path=$dir_script/curtinlv_JD-Script_jd_tool_dl.py
OpenCard_shell_path=$dir_script/raw_jd_OpenCard.py
task_before_shell_path=$dir_shell/task_before.sh
sample_shell_path=/ql/sample/config.sample.sh
git clone https://ghproxy.com/https://github.com/shidahuilang/QL- qlwj
if [[ $? -ne 0 ]];then
	mkdir -p /ql/qlwj
	curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/wx_jysz.js > /ql/qlwj/wx_jysz.js
	curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/crypto-js.js > /ql/qlwj/crypto-js.js
	curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/config.sample.sh > /ql/qlwj/config.sample.sh
	curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/extra.sh > /ql/qlwj/extra.sh
	curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/raw_jd_OpenCard.py > /ql/qlwj/raw_jd_OpenCard.py
	curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/Evaluation.py > /ql/qlwj/Evaluation.py
      #  curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/curtinlv_JD-Script_jd_tool_dl.py > /ql/qlwj/curtinlv_JD-Script_jd_tool_dl.py

        if [[ $? -ne 0 ]];then
		TIME y "应用文件下载失败"
		    exit 1
	fi
fi

# 授权
chmod -R +x /ql/qlwj

cp -Rf /ql/qlwj/feverrun/config.sample.sh /ql/config/config.sh
cp -Rf /ql/qlwj/feverrun/config.sample.sh /ql/sample/config.sample.sh
cp -Rf /ql/qlwj/feverrun/extra.sh /ql/config/extra.sh
cp -Rf /ql/qlwj/feverrun/extra.sh /ql/sample/extra.sample.sh
cp -Rf /ql/qlwj/feverrun/raw_jd_OpenCard.py /ql/scripts/raw_jd_OpenCard.py
cp -Rf /ql/qlwj/feverrun/wskey.py /ql/scripts/wskey.py
cp -Rf /ql/qlwj/Evaluation.py /ql/scripts/Evaluation.py
# cp -Rf /ql/qlwj/curtinlv_JD-Script_jd_tool_dl.py /ql/scripts/curtinlv_JD-Script_jd_tool_dl.py
cp -Rf /ql/qlwj/feverrun/crypto-js.js /ql/scripts/crypto-js.js
echo

# 将 extra.sh 添加到定时任务
if [ "$(grep -c extra /ql/config/crontab.list)" = 0 ]; then
    echo
    echo
    TIME g "开始添加 [每8小时更新任务]"
    echo
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"每8小时更新任务","command":"ql extra","schedule":"* */8 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1624782068473'
fi

if [ "$(grep -c wskey.py /ql/config/crontab.list)" = 0 ]; then
    echo
    echo
    TIME g "开始添加 [早9晚11点WSKEY转换]"
    echo
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"早9晚11点更新","command":"task wskey.py","schedule":"0 9,23 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1633428022377'
fi

# 将 bot 添加到定时任务
if [ "$(grep -c bot /ql/config/crontab.list)" = 0 ]; then
    echo
    echo
    TIME g "开始添加 [拉取机器人]"
    echo
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"拉取机器人","command":"ql bot","schedule":"13 14 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1626247933219'
fi

# 将 raw_jd_OpenCard.py 添加到定时任务
if [ "$(grep -c raw_jd_OpenCard.py /ql/config/crontab.list)" = 0 ]; then
    echo
    echo
    TIME g "开始添加 [JD入会开卡领取京豆]"
    echo
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"JD入会开卡领取京豆","command":"task raw_jd_OpenCard.py","schedule":"8 8,15,20 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1634041221437'
fi

# 将 Evaluation.py 添加到定时任务
if [ "$(grep -c Evaluation.py /ql/config/crontab.list)" = 0 ]; then
    echo
    echo
    TIME g "开始添加 [自动评价晒图助手]"
    echo
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"自动评价晒图助手","command":"task Evaluation.py","schedule":"0 6 */3 * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1634097051985'
fi
echo
echo
if [[ "$(grep -c JD_WSCK=\"pin= /ql/config/env.sh)" = 1 ]]; then
    echo
    TIME g "执行WSKEY转换PT_KEY操作"
    task wskey.py |tee azcg.log
    echo
    if [[ `ls -a |grep -c "wskey转换成功" /ql/azcg.log` -ge '1' ]] && [[ `ls -a |grep -c "wskey状态失效" /ql/azcg.log` = '0' ]] || [[ `ls -a |grep -c "账号启用" /ql/azcg.log` -ge '1' ]] && [[ `ls -a |grep -c "wskey更新失败" /ql/azcg.log` = '0' ]]; then
    	echo
    	TIME g "WSKEY转换PT_KEY成功"
	echo
    else
    	echo
    	TIME g "WSKEY转换PT_KEY失败，检查KEY的格式对不对，或者有没有失效，如果是多个WSKEY的话，或者有个别KEY出问题"
	echo
    fi
fi
echo
echo
TIME g "拉取自动助力脚本"
echo
echo
rm -fr /ql/azcg.log
ql extra |tee azcg.log
rm -rf /ql/qlwj
echo
echo
if [[ "$(grep -c JD_WSCK=\"pin= /ql/config/env.sh)" = 0 ]] && [[ "$(grep -c JD_COOKIE=\"pt_key= /ql/config/env.sh)" = 0 ]]; then
    TIME y "没发现WSKEY或者PT_KEY，请注意设置好KEY，要不然脚本不会运行!"
fi
echo
echo
if [[ `ls -a |grep -c "添加成功" /ql/azcg.log` -ge '1' ]] && [[ `ls -a |grep -c "执行结束" /ql/azcg.log` -ge '1' ]] || [[ `ls -a |grep -c "开始更新仓库" /ql/azcg.log` -ge '1' ]]; then
	TIME g "脚本安装完成!"
	rm -fr /ql/azcg.log
else
	TIME r "脚本安装失败，请用一键单独安装任务重新尝试!"
	rm -fr /ql/azcg.log
	exit 1
fi
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
cd /ql/scripts/ && apk add --no-cache build-base g++ cairo-dev pango-dev giflib-dev && pnpm install && pnpm i ts-node typescript @types/node date-fns axios download canvas
cd /ql
TIME l "安装python3"
apk add python3 zlib-dev gcc jpeg-dev python3-dev musl-dev freetype-dev
cd /ql
task curtinlv_JD-Script_jd_tool_dl.py
echo
TIME g "依赖安装完毕..."
echo
echo
echo
exit 0
