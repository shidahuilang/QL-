#!/usr/bin/env bash

# 需要修改的变量,把1-5改成6-10就是提取6-10帐号的助力码，类推，11-15、16-20，一个文件5个助力码，一个TG号

export TG="6-10"
export api_id="填写您Telegram的API的ID"
export api_hash="填写您Telegram的API的密匙"

export RWWJ="${TG}rw.sh"
export CRON="$(date +163764742%M%S)"
export CRON1="$(date +163764761%M%S)"
export CRON2="$(date +%M)"
export token=$(cat /ql/config/auth.json | jq --raw-output .token)
[[ -d '/ql/log/jd_get_share_code' ]] && rm -rf /ql/log/jd_get_share_code/*
task jd_get_share_code.js desi JD_COOKIE "${TG}"
lOGName="$(ls -a /ql/log/jd_get_share_code |egrep -o [0-9]+-[0-9]+-[0-9]+-[0-9]+-[0-9]+-[0-9]+.log |awk 'END {print}')"
FARM="$(grep '/farm' /ql/log/jd_get_share_code/${lOGName})"
PET="$(grep '/pet' /ql/log/jd_get_share_code/${lOGName})"
BEAN="$(grep '/bean' /ql/log/jd_get_share_code/${lOGName})"
JXFACTORY="$(grep '/jxfactory' /ql/log/jd_get_share_code/${lOGName})"
SGMH="$(grep '/sgmh' /ql/log/jd_get_share_code/${lOGName})"
HEALTH="$(grep '/health' /ql/log/jd_get_share_code/${lOGName})"

cat >/ql/jd/${TG}.py <<-EOF
#调度配置 0,1 0 * * 1 python3 /ql/jd/${TG}.py
from telethon import TelegramClient
import os
current_path = os.path.dirname(os.path.abspath(__file__))
os.chdir(current_path)
client = TelegramClient("bot${TG}", "${api_id}", "${api_hash}", connection_retries=None).start()
async def main():
    await client.send_message("@JDShareCodebot", "${FARM}")
    await client.send_message("@JDShareCodebot", "${PET}")
    await client.send_message("@JDShareCodebot", "${BEAN}")
    await client.send_message("@JDShareCodebot", "${JXFACTORY}")
    await client.send_message("@JDShareCodebot", "${SGMH}")
    await client.send_message("@JDShareCodebot", "${HEALTH}")
    await client.send_read_acknowledge("@JDShareCodebot")
with client:
    client.loop.run_until_complete(main())
EOF

cat >/ql/jd/"${RWWJ}" <<-EOF
#!/usr/bin/env bash
if [ "$(grep -c ${TG}.py /ql/config/crontab.list)" = 0 ]; then
    echo
    echo "添加任务 [自动提交助力码${TG}]"
    echo
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${token}" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"自动提交助力码${TG}","command":"python3 /ql/jd/${TG}.py","schedule":"0,1 0 * * 1"}' --compressed 'http://127.0.0.1:5700/api/crons?t=${CRON}'
fi
sleep 2
echo
if [ "$(grep -c ${TG}.sh /ql/config/crontab.list)" = 0 ]; then
    echo
    echo "添加任务 [获取互助码${TG}]"
    echo
    curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${token}" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"获取互助码${TG}","command":"task /ql/jd/${TG}.sh","schedule":"${CRON2} 13 * * 6"}' --compressed 'http://127.0.0.1:5700/api/crons?t=${CRON1}'
fi
EOF

task /ql/jd/"${RWWJ}"
rm -rf /ql/jd/"${RWWJ}"
