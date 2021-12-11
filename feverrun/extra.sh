#!/usr/bin/env bash

## 添加你需要重启自动执行的任意命令，比如 ql repo
## 安装node依赖使用 pnpm install -g xxx xxx
## 安装python依赖使用 pip3 install xxx
#京东到家果园任务
ql raw https://raw.githubusercontent.com/passerby-b/JDDJ/main/jddj_fruit.js
#超级直播间红包雨
#ql raw https://raw.githubusercontent.com/KingRan/JDJB/main/jd_live_redrain.js
#宠汪汪有就换
ql repo https://github.com/ccwav/QLScript2.git "jd_joy_reward_Mod" "NoUsed" "ql|jdCookie|JS_USER_AGENTS|sendNotify|USER_AGENTS|utils"
ql repo https://ghproxy.com/https://github.com/shufflewzc/faker2.git "jd_|jx_|gua_|jddj_|getJDCookie" "activity|backUp|jd_disable.py|jd_get_share_code.js|jd_clean_car.js" "^jd[^_]|USER|function|utils|sendNotify|ZooFaker_Necklace.js|JDJRValidator_|sign_graphics_validate|ql"
ql repo https://github.com/feverrun/my_scripts.git "jd_fruit|jd_plantBean|jd_factory|jd_dreamFactory|jd_pet|jd_health|jd_sgmh|jd_jxmc|jd_cfd" "backUp|collectWate|tuan|fresh_exchange|loop|mooncake" "^(jd|JD|JS)[^_]|USER|sendNotify|utils"
ql repo https://ghproxy.com/https://github.com/smiek2121/scripts.git "jd_|gua_" "gua_cleancart.js" "ZooFaker_Necklace.js|JDJRValidator_Pure.js|sign_graphics_validate.js|cleancart_activity.js|jdCookie.js|sendNotify.js"
ql repo https://github.com/JDHelloWorld/jd_scripts.git "jd_fruit|jd_plantBean|jd_jdfactory|jd_dreamFactory|jd_pet|jd_health|jd_sgmh|jd_jxmc|jd_cfd|jd_88hb|jd_api_test" "activity|backUp|Coupon|enen|update|collect|game|shell|stock|getCoin|moreTask|jd_jxmc.js" "^jd[^_]|^USER|^TS|^JS|jdCookie|sendNotify|tools|utils|package|jd_validate_Worker"
task disableDuplicateTasksImplement.py
