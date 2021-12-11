#!/usr/bin/env bash
# 
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
mkdir -p /run/nginx
nginx -c /etc/nginx/nginx.conf
dir_shell=/ql/config
dir_script=/ql/scripts
config_shell_path=$dir_shell/config.sh
extra_shell_path=$dir_shell/extra.sh
code_shell_path=$dir_shell/code.sh
disableDuplicateTasksImplement_shell_path=$dir_script/disableDuplicateTasksImplement.py
wskey_shell_path=$dir_script/wskey.py
crypto_shell_path=$dir_script/crypto-js.js
wx_jysz_shell_path=$dir_script/wx_jysz.js
OpenCard_shell_path=$dir_script/raw_jd_OpenCard.py
task_before_shell_path=$dir_shell/task_before.sh
sample_shell_path=/ql/sample/config.sample.sh
mkdir -p /ql/qlwj

mkdir -p /ql/scripts/utils
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/Aaron-lv/utils/jd_jxmc.js > /ql/scripts/utils/jd_jxmc.js
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/Aaron-lv/utils/jd_jxmcToken.js > /ql/scripts/utils/jd_jxmcToken.js
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/Aaron-lv/jd_cfd_sharecodes.ts > /ql/scripts/jd_cfd_sharecodes.ts
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/Aaron-lv/jd_jxmc_sharecodes.ts > /ql/scripts/jd_jxmc_sharecodes.ts
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/Aaron-lv/TS_USER_AGENTS.ts > /ql/scripts/TS_USER_AGENTS.ts

echo
TIME l "拉取auth.json"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/auth.json > /ql/qlwj/auth.json
TIME l "拉取crypto-js.js"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/crypto-js.js > /ql/qlwj/crypto-js.js
TIME l "拉取config.sample.sh"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/config.sample.sh > /ql/qlwj/config.sample.sh
TIME l "拉取extra.sh"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/extra.sh > /ql/qlwj/extra.sh
TIME l "拉取raw_jd_OpenCard.py"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/raw_jd_OpenCard.py > /ql/qlwj/raw_jd_OpenCard.py
TIME l "拉取wskey.py"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/wskey.py > /ql/qlwj/wskey.py
TIME l "拉取auth.json"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/auth.json > /ql/qlwj/auth.json
TIME l "拉取curtinlv_JD-Script_jd_tool_dl.py"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/curtinlv_JD-Script_jd_tool_dl.py > /ql/qlwj/curtinlv_JD-Script_jd_tool_dl.py
TIME l "拉取disableDuplicateTasksImplement.py"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/disableDuplicateTasksImplement.py > /ql/qlwj/disableDuplicateTasksImplement.py
TIME l "拉取Evaluation.py"
curl -fsSL https://raw.githubusercontent.com/qiu-lzsnmb/jd_lzsnmb/jd/Evaluation.py > /ql/qlwj/Evaluation.py
TIME l "拉取jd_get_share_code.js"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/jd_get_share_code.js > /ql/qlwj/jd_get_share_code.js
TIME l "拉取jdCookie.js"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/jdCookie.js > /ql/qlwj/jdCookie.js
TIME l "拉取jd_cleancartAll.js"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/Aaron-lv/jd_cleancartAll.js > /ql/qlwj/jd_cleancartAll.js
TIME l "拉取1-5.sh"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/jd/1-5.sh > /ql/jd/1-5.sh
TIME l "拉取6-10.sh"
curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/jd/6-10.sh > /ql/jd/6-10.sh
chmod -R +x /ql/qlwj
cp -Rf /ql/qlwj/config.sample.sh /ql/config/config.sh
cp -Rf /ql/qlwj/config.sample.sh /ql/sample/config.sample.sh
cp -Rf /ql/qlwj/extra.sh /ql/config/extra.sh
cp -Rf /ql/qlwj/extra.sh /ql/sample/extra.sample.sh
cp -Rf /ql/qlwj/raw_jd_OpenCard.py /ql/scripts/raw_jd_OpenCard.py
cp -Rf /ql/qlwj/wskey.py /ql/scripts/wskey.py
cp -Rf /ql/qlwj/curtinlv_JD-Script_jd_tool_dl.py /ql/scripts/curtinlv_JD-Script_jd_tool_dl.py
cp -Rf /ql/qlwj/disableDuplicateTasksImplement.py /ql/scripts/disableDuplicateTasksImplement.py
cp -Rf /ql/qlwj/Evaluation.py /ql/scripts/Evaluation.py
cp -Rf /ql/qlwj/jd_get_share_code.js /ql/scripts/jd_get_share_code.js
cp -Rf /ql/qlwj/jdCookie.js /ql/scripts/jdCookie.js
cp -Rf /ql/qlwj/jd_cleancartAll.js /ql/scripts/jd_cleancartAll.js
echo
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/QL-/main/npm.sh)"
echo
# 将 extra.sh 添加到定时任务
if [ "$(grep -c extra /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [每5小时更新任务]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"每5小时更新任务","command":"ql extra","schedule":"* */5 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1624782068473'
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
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"拉取机器人","command":"ql bot","schedule":"13 14 * * 0"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1626247933219'
fi
sleep 2
echo
# 将 disableDuplicateTasksImplement.py 添加到定时任务
if [ "$(grep -c disableDuplicateTasksImplement.py /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [禁用重复任务]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"禁用重复任务","command":"task disableDuplicateTasksImplement.py","schedule":"20 10 */7 * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1637505495830'
fi
sleep 2
echo
# 将 jd_jxmc_sharecodes.ts 添加到定时任务
if [ "$(grep -c jd_jxmc_sharecodes.ts /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [京喜牧场上车]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"京喜牧场上车","command":"task jd_jxmc_sharecodes.ts","schedule":"1 0 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1639071292827'
fi
sleep 2
echo
# 将 jd_cfd_sharecodes.ts 添加到定时任务
if [ "$(grep -c jd_cfd_sharecodes.ts /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [京喜财富岛上车]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"京喜财富岛上车","command":"task jd_cfd_sharecodes.ts","schedule":"2 0 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1639071050874'
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
# 将 jd_get_share_code.js 添加到定时任务
if [ "$(grep -c jd_get_share_code.js /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [获取助力码]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"获取助力码","command":"task jd_get_share_code.js","schedule":"20 13 * * 6"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1637505495835'
fi
sleep 2
echo
# 将 Evaluation.py 添加到定时任务
if [ "$(grep -c Evaluation.py /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [自动评价]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"京东全自动评价","command":"task Evaluation.py","schedule":"0 6 */3 * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1637560543233'
fi
sleep 2
echo
# 将 jd_cleancartAll.js 添加到定时任务
if [ "$(grep -c jd_cleancartAll.js /ql/config/crontab.list)" = 0 ]; then
    echo
    TIME g "添加任务 [清空购物车]"
    echo
    # 获取token
    token=$(cat /ql/config/auth.json | jq --raw-output .token)
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"清空购物车","command":"task jd_cleancartAll.js","schedule":"3 6,12,23 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1639110553549'
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
exit 0
