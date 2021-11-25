
- 第一步

- 执行以下命令


脚本适用于（ubuntu的docker、debian的docker、centos的docker、openwrt的docker）
一键安装青龙，包括（docker、任务、依赖安装，一条龙服务）
自动检测docker，有则跳过，无则执行安装，如果是openwrt则不会自动安装docker
如果您以前安装有青龙的话，则自动删除您的青龙，全部推倒重新安装
如果有条件的话，最好使用翻墙网络来安装
- 为防止系统没安装curl，使用不了一键命令，使用一键安装青龙面板命令之前选执行一次安装curl命令
- 安装curl请注意区分系统，openwrt千万别另外安装curl，openwrt本身自带了，另外安装还会用不了
- ubuntu或者debian系统
``` bash
sudo apt-get update && sudo apt-get install -y curl
```
- centos系统
``` bash
sudo yum install -y curl
```

### 🚩 一键安装青龙面板命令

``` bash
bash -c "$(curl -fsSL git.io/J1ARi)"
```



- 第二步

#### 🚩 如果上面的命令运行成功会有提示，登录页面，设置好KEY


- > 上面的安装完毕后，确保你的设备放行了`5700`端口，用自己的`ip:5700`进入页面

- > 进入页面后，点击安装青龙面板，然后按提示设置好账号、密码，登录管理页面就可以了

- > 信息推送不需要填写，直接跳过就好了，任务运行后在配置文件添加就可以

- > 面板安装成功后，登录面板，然后在‘ 环境变量 ’项添加 WSKEY

- 名称
JD_WSCK

- 值
``` bash
pin=您的账号;wskey=XXXXXX
```



- > 您也可以使用 JD_COOKIE，WSKEY和JD_COOKIE二选一即可

- 名称
JD_COOKIE

- 值
``` bash
pt_key=XXXXXX;pt_pin=您的账号;
```


- 第三步，设置好KEY后，回到命令窗，输入Y或者y回车继续安装脚本，如果拉取脚本途中出现错误，可以使用单独“一键单独安装任务”和“一键安装单独青龙的依赖”继续安装




- 🚩 全部一键脚本



- 一键安装青龙，包括（docker、任务、依赖安装，一条龙服务）
``` bash
wget -O lang.sh https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/lang.sh && bash lang.sh
```

- 一键单独安装任务（青龙安装好后，登录页面后，可以用这个单独安装任务）
- 单脚本
``` bash
docker exec -it qinglong bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/danxiaoben.sh)"
``` 
- 多脚本库
``` bash
docker exec -it qinglong bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/jiaoben.sh)"
```
- 一键单独安装docker
``` bash
wget -O docker.sh https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/docker.sh && bash docker.sh
```

- 一键安装单独青龙的依赖
``` bash
docker exec -it qinglong bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/npm.sh)"
```


- 感谢！

> [`feverrun`]
> [`danshui`]
> [`whyour`]
