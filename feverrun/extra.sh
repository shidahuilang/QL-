#!/usr/bin/env bash

## 添加你需要重启自动执行的任意命令，比如 ql repo
## 安装node依赖使用 pnpm install -g xxx xxx
## 安装python依赖使用 pip3 install xxx
ql raw https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/disableDuplicateTasksImplement.py
ql repo https://ghproxy.com/https://github.com/mmnvnmm/omo.git "card|tools"
ql repo https://ghproxy.com/https://github.com/feverrun/my_scripts.git "jd_|jx_|jddj|getCookie|getJDCookie" "backUp" "^(jd|JD|JS)[^_]|USER|sendNotify|utils"
task raw_feverrun_disableDuplicateTasksImplement.py	
