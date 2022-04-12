#/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
clear
# globals
CWD=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
[ -e "${CWD}/scripts/globals" ] && . ${CWD}/scripts/globals



checkos(){
  ifTermux=$(echo $PWD | grep termux)
  ifMacOS=$(uname -a | grep Darwin)
  if [ -n "$ifTermux" ];then
    os_version=Termux
  elif [ -n "$ifMacOS" ];then
    os_version=MacOS  
  else  
    os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
  fi
  
  if [[ "$os_version" == "2004" ]] || [[ "$os_version" == "10" ]] || [[ "$os_version" == "11" ]];then
    ssll="-k --ciphers DEFAULT@SECLEVEL=1"
  fi
}
checkos 

checkCPU(){
  CPUArch=$(uname -m)
  if [[ "$CPUArch" == "aarch64" ]];then
    arch=linux_arm64
  elif [[ "$CPUArch" == "i686" ]];then
    arch=linux_386
  elif [[ "$CPUArch" == "arm" ]];then
    arch=linux_arm
  elif [[ "$CPUArch" == "x86_64" ]] && [ -n "$ifMacOS" ];then
    arch=darwin_amd64
  elif [[ "$CPUArch" == "x86_64" ]];then
    arch=linux_amd64    
  fi
}
checkCPU
check_dependencies(){

  os_detail=$(cat /etc/os-release 2> /dev/null)
  if_debian=$(echo $os_detail | grep 'ebian')
  if_redhat=$(echo $os_detail | grep 'rhel')
  if [ -n "$if_debian" ];then
    InstallMethod="apt"
  elif [ -n "$if_redhat" ] && [[ "$os_version" -lt 8 ]];then
    InstallMethod="yum"
  elif [[ "$os_version" == "MacOS" ]];then
    InstallMethod="brew"  
  fi
}
check_dependencies
#安装wget、curl、unzip
${InstallMethod} install unzip wget curl -y > /dev/null 2>&1 
get_opsy() {
  [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
  [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
  [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
virt_check() {
  # if hash ifconfig 2>/dev/null; then
  # eth=$(ifconfig)
  # fi

  virtualx=$(dmesg) 2>/dev/null

  if [[ $(which dmidecode) ]]; then
    sys_manu=$(dmidecode -s system-manufacturer) 2>/dev/null
    sys_product=$(dmidecode -s system-product-name) 2>/dev/null
    sys_ver=$(dmidecode -s system-version) 2>/dev/null
  else
    sys_manu=""
    sys_product=""
    sys_ver=""
  fi

  if grep docker /proc/1/cgroup -qa; then
    virtual="Docker"
  elif grep lxc /proc/1/cgroup -qa; then
    virtual="Lxc"
  elif grep -qa container=lxc /proc/1/environ; then
    virtual="Lxc"
  elif [[ -f /proc/user_beancounters ]]; then
    virtual="OpenVZ"
  elif [[ "$virtualx" == *kvm-clock* ]]; then
    virtual="KVM"
  elif [[ "$cname" == *KVM* ]]; then
    virtual="KVM"
  elif [[ "$cname" == *QEMU* ]]; then
    virtual="KVM"
  elif [[ "$virtualx" == *"VMware Virtual Platform"* ]]; then
    virtual="VMware"
  elif [[ "$virtualx" == *"Parallels Software International"* ]]; then
    virtual="Parallels"
  elif [[ "$virtualx" == *VirtualBox* ]]; then
    virtual="VirtualBox"
  elif [[ -e /proc/xen ]]; then
    virtual="Xen"
  elif [[ "$sys_manu" == *"Microsoft Corporation"* ]]; then
    if [[ "$sys_product" == *"Virtual Machine"* ]]; then
      if [[ "$sys_ver" == *"7.0"* || "$sys_ver" == *"Hyper-V" ]]; then
        virtual="Hyper-V"
      else
        virtual="Microsoft Virtual Machine"
      fi
    fi
  else
    virtual="Dedicated母鸡"
  fi
}
get_system_info() {
  cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
  opsy=$(get_opsy)
  arch=$(uname -m)

  kern=$(uname -r)

  virt_check
}
copyright(){
    clear
echo -e "
—————————————————————————————————————————————————————————————
        Nvjdc自助面板一键懒人安装脚本                         
 ${green}  	
—————————————————————————————————————————————————————————————
"
}
quit(){
exit
}

install_nvjdc(){
echo -e "${red}开始进行安装,请根据命令提示操作${plain}"
echo -e "${green}检测到已有nvjdc面板，正在删除旧的nvjdc文件容器镜像，请稍后...${plain}"

	docker=$(docker ps -a|grep nvjdc) && dockerid=$(awk '{print $(1)}' <<<${docker})
	images=$(docker images|grep nvjdc) && imagesid=$(awk '{print $(3)}' <<<${images})
	docker stop -t=5 "${dockerid}" > /dev/null 2>&1
	docker rm "${dockerid}"
	docker rmi "${imagesid}"
	
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
   yum install git -y > /dev/null
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
   apt-get install git -y > /dev/null
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
   apt install git -y > /dev/null
fi
rm -rf /root/nvjdc > /dev/null
git clone https://github.com/Mofan1379/nvjdcdocker.git /root/nvjdc
if [ ! -d "/root/nvjdc/.local-chromium/Linux-884014" ]; then
cd /root/nvjdc
echo -e "${green}正在拉取chromium-browser-snapshots等依赖,体积100多M，请耐心等待下一步命令提示···${plain}"
mkdir -p  .local-chromium/Linux-884014 && cd .local-chromium/Linux-884014
wget https://mirrors.huaweicloud.com/chromium-browser-snapshots/Linux_x64/884014/chrome-linux.zip > /dev/null 2>&1 
unzip chrome-linux.zip > /dev/null 2>&1 
rm -f chrome-linux.zip > /dev/null 2>&1 
fi
mkdir /root/nvjdc/Config && cd /root/nvjdc/Config
wget -O Config.json   https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/nvjdc/main/Config.json
read -p "请输入青龙服务器在web页面中显示的名称: " QLName && printf "\n"
read -p "请输入nvjdc面板标题: " title && printf "\n"
read -p "请输入nvjdc面板希望使用的端口号: " portinfo && printf "\n"
read -p "请输入XDD面板地址，格式如http://192.168.2.2:6666/api/login/smslogin  如不启用直接回车: " XDDurl && printf "\n"
read -p "请输入XDD面板Token（如不启用直接回车）: " XDDToken && printf "\n"
read -p "请输入PUSHPLUS的TOKEN（如不启用直接回车）: " PUSH_PLUS_TOKEN && printf "\n"
read -p "nvjdc是否对接青龙，输入y或者n " jdcqinglong && printf "\n"
 if [[ "$jdcqinglong" == "y" ]];then
read -p "请输入青龙OpenApi Client ID: " ClientID && printf "\n"
read -p "请输入青龙OpenApi Client Secret: " ClientSecret && printf "\n"
read -p "请输入青龙服务器的url地址（类似http://192.168.2.2:5700）: " QLurl && printf "\n"
cat > /root/nvjdc/Config/Config.json << EOF
{
    ///最大支持几个网页
    "MaxTab": "20",
    //网站标题
    "Title": "Nvjdc",
    //回收时间分钟 不填默认3分钟
    "Closetime": "3",
    //网站公告
    "Announcement": "本项目脚本收集于互联网。为了您的财产安全，请关闭京东免密支付。",
    ///开启打印等待日志卡短信验证登陆 可开启 拿到日志群里回复 默认不要填写
    "Debug": "",
    ///自动滑块次数5次 5次后手动滑块 可设置为0默认手动滑块
    "AutoCaptchaCount": "5",
    ///XDD PLUS Url  http://IP地址:端口/api/login/smslogin
    "XDDurl": "",
    ///xddToken
    "XDDToken": "",
    //## 8. Push Plus官方网站：http: //www.pushplus.plus 
    //下方填写您的Token，微信扫码登录后一对一推送或一对多推送下面的token，只填" "PUSH_PLUS_TOKEN",
    "PUSH_PLUS_TOKEN": "${PUSH_PLUS_TOKEN}",
    //下方填写您的一对多推送的 "群组编码" ，（一对多推送下面->您的群组(如无则新建)->群组编码）
    "PUSH_PLUS_USER": "",
    ///多青龙配置
    "Config": [
        {
      //序号必须从1开始
      "QLkey": 1,
      //服务器名称
      "QLName": "${QLName}",
      //青龙url
      "QLurl": "${QLurl}",
      //青龙2,9 OpenApi Client ID
      "QL_CLIENTID": "${ClientID}",
      //青龙2,9 OpenApi Client Secret
      "QL_SECRET": "${ClientSecret}",
      //青龙面包最大ck容量
      "QL_CAPACITY": 200,
      //消息推送二维码
      "QRurl":""
        }
    ]
}
EOF
else
cat > /root/nvjdc/Config/Config.json << EOF
{
  ///浏览器最多几个网页
  "MaxTab": "8",
  //网站标题
  "Title": "${title}",
  //网站公告
  "Announcement": "本项目脚本收集于互联网。为了您的财产安全，请关闭京东免密支付。",
  ///XDD PLUS Url  http://IP地址:端口/api/login/smslogin
  "XDDurl": "${XDDurl}",
  ///xddToken
  "XDDToken": "${XDDToken}",
  "PUSH_PLUS_TOKEN": "${PUSH_PLUS_TOKEN}",
  ///青龙配置 注意 如果不要青龙  Config :[]
  "Config": []
}
EOF
fi
read -p "请输入自动滑块次数 直接回车默认5次后手动滑块 输入0为默认手动滑块: " AutoCaptcha && printf "\n"
	if [ ! -n "$AutoCaptcha" ];then
    sed -i "5a \        \"AutoCaptchaCount\": \"5\"," /root/nvjdc/Config/Config.json
else
    sed -i "5a \        \"AutoCaptchaCount\": \"${AutoCaptcha}\"," /root/nvjdc/Config/Config.json
fi
read -p "请输入要安装的nvjdc版本，如安装最新版直接回车: " version && printf "\n"
	if [ ! -n "${version}" ];then
    version1=latest 
else
    version1=${version}
fi


#判断机器是否安装docker
if test -z "$(which docker)"; then
echo -e "检测到系统未安装docker，开始安装docker"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun > /dev/null 2>&1 
    curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

#拉取nvjdc镜像
echo -e  "${green}开始拉取nvjdc镜像文件，nvjdc镜像比较大，请耐心等待${plain}"
docker pull shidahuilang/nvjdc:latest


#创建并启动nvjdc容器
cd /root/nvjdc
echo -e "${green}开始创建nvjdc容器${plain}"
docker run   --name nvjdc -p ${portinfo}:80 -d  -v  "$(pwd)":/app \
-v /etc/localtime:/etc/localtime:ro \
-it --privileged=true  shidahuilang/nvjdc:latest
docker update --restart=always nvjdc

baseip=$(curl -s ipip.ooo)  > /dev/null

echo -e "${green}安装完毕,面板访问地址：http://${baseip}:${portinfo}${plain}"
}

update_nvjdc(){
mv /root/nvjdc /root/nvjdc1
git clone https://github.com/Mofan1379/nvjdcdocker.git /root/nvjdc
cd /root/nvjdc &&  mkdir -p  Config &&  mv /root/nvjdc1/Config.json /root/nvjdc/Config/Config.json
cd /root/nvjdc &&    mv /root/nvjdc1/.local-chromium /root/nvjdc/.local-chromium
cd /root/nvjdc
portinfo=$(docker port nvjdc | head -1  | sed 's/ //g' | sed 's/80\/tcp->0.0.0.0://g')
condition=$(cat /root/nvjdc/Config/Config.json | grep -o '"XDDurl": .*' | awk -F":" '{print $1}' | sed 's/\"//g')
AutoCaptcha1=$(cat /root/nvjdc/Config/Config.json | grep -o '"AutoCaptchaCount": .*' | awk -F":" '{print $1}' | sed 's/\"//g')
if [ ! -n "$condition" ]; then
read -p "是否要对接XDD，输入y或者n: " XDD && printf "\n"
if [[ "$XDD" == "y" ]];then
read -p "请输入XDD面板地址，格式如http://192.168.2.2:6666/api/login/smslogin : " XDDurl && printf "\n"
read -p "请输入XDD面板Token: " XDDToken && printf "\n"
sed -i "7a \          \"XDDurl\": \"${XDDurl}\"," /root/nvjdc/Config/Config.json
sed -i "7a \        \"XDDToken\": \"${XDDToken}\"," /root/nvjdc/Config/Config.json
fi
fi

if [ ! -n "$AutoCaptcha1" ];then
	read -p "请输入自动滑块次数 直接回车默认5次后手动滑块 输入0为默认手动滑块: " AutoCaptcha && printf "\n"
	if [ ! -n "$AutoCaptcha" ];then
    sed -i "5a \        \"AutoCaptchaCount\": \"5\"," /root/nvjdc/Config/Config.json
else
    sed -i "5a \        \"AutoCaptchaCount\": \"${AutoCaptcha}\"," /root/nvjdc/Config/Config.json
fi
fi
baseip=$(curl -s ipip.ooo)  > /dev/null
docker rm -f nvjdc
docker pull shidahuilang/nvjdc:latest
docker run   --name nvjdc -p ${portinfo}:80 -d  -v  "$(pwd)":/app \
-v /etc/localtime:/etc/localtime:ro \
-it --privileged=true  shidahuilang/nvjdc:2.4
docker update --restart=always nvjdc
echo -e "${green}nvjdc更新完毕，脚本自动退出。${plain}"
exit 0
}

uninstall_nvjdc(){
	docker=$(docker ps -a|grep nvjdc) && dockerid=$(awk '{print $(1)}' <<<${docker})
	images=$(docker images|grep nvjdc) && imagesid=$(awk '{print $(3)}' <<<${images})
	docker stop -t=5 "${dockerid}" > /dev/null 2>&1
	docker rm "${dockerid}"
	docker rmi "${imagesid}"
	rm -rf nvjdc
echo -e "${green}nvjdc面板已卸载，镜像已删除。${plain}"
exit 0
}

menu() {
  echo -e "\
${green}0.${plain} 退出脚本
${green}1.${plain} 安装nvjdc
${green}2.${plain} 升级nvjdc
${green}3.${plain} 卸载nvjdc
"
get_system_info
echo -e "当前系统信息: ${Font_color_suffix}$opsy ${Green_font_prefix}$virtual${Font_color_suffix} $arch ${Green_font_prefix}$kern${Font_color_suffix}
"

  read -p "请输入数字 :" num
  case "$num" in
  0)
    quit
    ;;
  1)
    install_nvjdc
    ;;
  2)
    update_nvjdc
    ;;	
  3)
    uninstall_nvjdc
    ;;    
  *)
  clear
    echo -e "${Error}:请输入正确数字 [0-3]"
    sleep 5s
    menu
    ;;
  esac
}

copyright

menu
