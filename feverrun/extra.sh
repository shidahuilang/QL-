#!/usr/bin/env bash

## 添加你需要重启自动执行的任意命令，比如 ql repo
## 安装node依赖使用 pnpm install -g xxx xxx
## 安装python依赖使用 pip3 install xxx
#京东到家果园任务
ql raw https://raw.githubusercontent.com/passerby-b/JDDJ/main/jddj_fruit.js
ql rmlog 7
#超级直播间红包雨
#ql raw https://raw.githubusercontent.com/KingRan/JDJB/main/jd_live_redrain.js
#宠汪汪有就换
ql repo https://github.com/ccwav/QLScript2.git "jd_joy_reward_Mod" "NoUsed" "ql|jdCookie|JS_USER_AGENTS|sendNotify|USER_AGENTS|utils"
#feverrun库
ql repo https://ghproxy.com/https://github.com/feverrun/my_scripts.git "jd_|jx_|jddj|getCookie|getJDCookie" "backUp" "^(jd|JD|JS)[^_]|USER|sendNotify|utils"
task disableDuplicateTasksImplement.py
