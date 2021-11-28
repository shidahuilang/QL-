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
  #cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
  #freq=$(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
  #corescache=$(awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
  #tram=$(free -m | awk '/Mem/ {print $2}')
  #uram=$(free -m | awk '/Mem/ {print $3}')
  #bram=$(free -m | awk '/Mem/ {print $6}')
  #swap=$(free -m | awk '/Swap/ {print $2}')
  #uswap=$(free -m | awk '/Swap/ {print $3}')
  #up=$(awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days %d hour %d min\n",a,b,c)}' /proc/uptime)
  #load=$(w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
  opsy=$(get_opsy)
  arch=$(uname -m)
  #lbit=$(getconf LONG_BIT)
  kern=$(uname -r)
  # disk_size1=$( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|overlay|shm|udev|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' )
  # disk_size2=$( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|overlay|shm|udev|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' )
  # disk_total_size=$( calc_disk ${disk_size1[@]} )
  # disk_used_size=$( calc_disk ${disk_size2[@]} )
  #tcpctrl=$(sysctl net.ipv4.tcp_congestion_control | awk -F ' ' '{print $3}')
  virt_check
}
copyright(){
    clear
echo -e "
—————————————————————————————————————————————————————————————
        Nvjdc自助面板一键安装脚本                         
 ${green}   
        Powered  by 翔翎   不浅维护
1.5版本nolan开库了，使用nolan仓库		
—————————————————————————————————————————————————————————————
"
}
quit(){
exit
}

install_nvjdc(){
echo -e "${red}开始进行安装,请根据命令提示操作${plain}"
yum install git -y > /dev/null 
git clone https://ghproxy.com/https://github.com/NolanHzy/nvjdcdocker.git /root/nvjdc
if [ ! -d "/root/nvjdc/.local-chromium/Linux-884014" ]; then
cd /root/nvjdc
echo -e "${green}正在拉取chromium-browser-snapshots等依赖,体积100多M，请耐心等待下一步命令提示···${plain}"
mkdir -p  .local-chromium/Linux-884014 && cd .local-chromium/Linux-884014
wget http://npm.taobao.org/mirrors/chromium-browser-snapshots/Linux_x64/884014/chrome-linux.zip > /dev/null 2>&1 
unzip chrome-linux.zip > /dev/null 2>&1 
rm  -f chrome-linux.zip > /dev/null 2>&1 
fi
mkdir /root/nvjdc/Config && cd /root/nvjdc/Config
wget -O Config.json   https://ghproxy.com/https://raw.githubusercontent.com/NolanHzy/nvjdc/main/Config.json
read -p "请输入青龙服务器在web页面中显示的名称: " QLName && printf "\n"
read -p "请输入nvjdc面板标题: " title && printf "\n"
read -p "请输入nvjdc面板希望使用的端口号: " portinfo && printf "\n"
read -p "请输入XDD面板地址，格式如http://192.168.2.2:6666/api/login/smslogin  如不启用直接回车: " XDDurl && printf "\n"
read -p "请输入XDD面板Token（如不启用直接回车）: " XDDToken && printf "\n"
read -p "nvjdc是否对接青龙，输入y或者n " jdcqinglong && printf "\n"
 if [[ "$jdcqinglong" == "y" ]];then
read -p "请输入青龙OpenApi Client ID: " ClientID && printf "\n"
read -p "请输入青龙OpenApi Client Secret: " ClientSecret && printf "\n"
read -p "请输入青龙服务器的url地址（类似http://192.168.2.2:5700）: " QLurl && printf "\n"
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
  ///青龙配置 注意 如果不要青龙  Config :[]
  "Config": [
    {
      //序号必填从1 开始
      "QLkey": 1,
      //服务器名称
      "QLName": "${QLName}",
      //青龙地址
      "QLurl": "${QLurl}",
      //青龙2,9 OpenApi Client ID
      "QL_CLIENTID": "${ClientID}",
      //青龙2,9 OpenApi Client Secret
      "QL_SECRET": "${ClientSecret}",
      //CK最大数量
      "QL_CAPACITY": 40,
      "QRurl": ""
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
docker pull nolanhzy/nvjdc:${version1}


#创建并启动nvjdc容器
cd /root/nvjdc
echo -e "${green}开始创建nvjdc容器${plain}"
docker run   --name nvjdc -p ${portinfo}:80 -d  -v  "$(pwd)":/app \
-v /etc/localtime:/etc/localtime:ro \
-it --privileged=true  nolanhzy/nvjdc:${version1}
docker update --restart=always nvjdc

baseip=$(curl -s ipip.ooo)  > /dev/null

echo -e "${green}安装完毕,面板访问地址：http://${baseip}:${portinfo}${plain}"
}

update_nvjdc(){
mv /root/nvjdc /root/nvjdcdb
git clone https://ghproxy.com/https://github.com/NolanHzy/nvjdcdocker.git /root/nvjdc
cd /root/nvjdc &&  mkdir -p  Config &&  mv /root/nvjdcdb/Config.json /root/nvjdc/Config/Config.json
cd /root/nvjdc &&    mv /root/nvjdcdb/.local-chromium /root/nvjdc/.local-chromium
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
docker pull nolanhzy/nvjdc:latest
docker run   --name nvjdc -p ${portinfo}:80 -d  -v  "$(pwd)":/app \
-v /etc/localtime:/etc/localtime:ro \
-it --privileged=true  nolanhzy/nvjdc:latest
docker update --restart=always nvjdc
echo -e "${green}nvjdc更新完毕，脚本自动退出。${plain}"
exit 0
}

uninstall_nvjdc(){
docker rm -f nvjdc
rm -rf /root/nvjdc
echo -e "${green}nvjdc面板已卸载，脚本自动退出，请手动删除nvjdc的镜像。${plain}"
exit 0
}

menu() {
  echo -e "\
${green}0.${plain} 退出脚本
${green}1.${plain} 安装nvjdc
${green}2.${plain} 1.2升级1.4
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