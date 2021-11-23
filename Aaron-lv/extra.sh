#!/usr/bin/env bash

## 添加你需要重启自动执行的任意命令，比如 ql repo
## 安装node依赖使用 pnpm install -g xxx xxx
## 安装python依赖使用 pip3 install xxx

ql repo https://ghproxy.com/https://github.com/shufflewzc/faker2.git "jd_|jx_|gua_|jddj_|getJDCookie" "activity|backUp" "^jd[^_]|USER|function|utils|sendNotify|ZooFaker_Necklace.js|JDJRValidator_|sign_graphics_validate|ql"
ql repo https://ghproxy.com/https://github.com/smiek2121/scripts.git "jd_|gua_" "" "ZooFaker_Necklace.js|JDJRValidator_Pure.js|sign_graphics_validate.js|cleancart_activity.js|jdCookie.js|sendNotify.js"
ql repo https://ghproxy.com/https://github.com/Aaron-lv/sync.git "jd_|jx_|getJDCookie" "activity|backUp|Coupon" "^jd[^_]|USER|utils|Notify" "jd_scripts"
task disableDuplicateTasksImplement.py
