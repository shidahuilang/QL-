#!/usr/bin/env bash

## 添加你需要重启自动执行的任意命令，比如 ql repo
## 安装node依赖使用 pnpm install -g xxx xxx
## 安装python依赖使用 pip3 install xxx


ql repo https://github.com/feverrun/my_scripts.git "jd_|jx_|gua|jddj|getCookie|getJDCookie" "backUp" "^(jd|JD|JS)[^_]|USER|sendNotify|utils"
ql repo https://ghproxy.com/https://github.com/shufflewzc/faker2.git "jd_|jx_|gua_|jddj_|getJDCookie" "activity|backUp" "^jd[^_]|USER|function|utils|ZooFaker_Necklace.js|JDJRValidator_Pure|sign_graphics_validate|ql"
task shufflewzc_faker2_jd_disable.py

