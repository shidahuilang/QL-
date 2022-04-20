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
       Rabbit自助面板一键懒人安装脚本                         
 ${green}  	
—————————————————————————————————————————————————————————————
"
}
quit(){
exit
}

install_rabbit(){
echo -e "${red}开始进行安装,请根据命令提示操作${plain}"

	docker=$(docker ps -a|grep rabbit) && dockerid=$(awk '{print $(1)}' <<<${docker})
	images=$(docker images|grep rabbit) && imagesid=$(awk '{print $(3)}' <<<${images})
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
rm -rf /root/Rabbit > /dev/null
cd /root && mkdir -p  Rabbit && cd Rabbit
cd /root/Rabbit && mkdir -p  Config
cd /root/Rabbit
wget -O Config.json   https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/Config.json
read -p "请输入青龙服务器在web页面中显示的名称: " QLName && printf "\n"
read -p "请输入Rabbit面板标题: " Title && printf "\n"
read -p "请输入青龙QL_CLIENTID: " CLIENTID && printf "\n"
read -p "请输入青龙QL_SECRET: " SECRET && printf "\n"
read -p "请输入青龙服务器的url地址（类似http://192.168.2.2:5700）: " QLurl && printf "\n"
read -p "请输入阿里云或腾讯云proxy代理地址（格式为http://或者socks://xxx.xxx.xxx.xxx:xxxx）: " proxy && printf "\n"
cat > /root/Rabbit/Config/Config.json << EOF
{
  "MaxTab": "4",
  "Title": "Rabbit",
  "Closetime": "5",
  "Announcement": "为提高账户的安全性，请关闭免密支付。",
  "AutoCaptchaCount": "5",
  "proxy": "${proxy}",
  "Config": [
    {
      "QLkey": 1,
      "QLName": "${QLName}",
      "QLurl": "${QLurl}",
      "QL_CLIENTID": "${CLIENTID}",
      "QL_SECRET": "${SECRET}",
      "QL_CAPACITY": 40,
      "QL_WSCK": 40
    },
    {
      "QLkey": 2,
      "QLName": "阿里云",
      "QLurl": "http://xxx.xxx.xxx.xxx:5700",
      "QL_CLIENTID": "xxx",
      "QL_SECRET": "xxx",
      "QL_CAPACITY": 40,
      "QL_WSCK": 40
    }
  ]
}
EOF



#拉取Rabbit镜像
echo -e  "${green}开始拉取rabbit镜像文件，rabbit镜像比较大，请耐心等待${plain}"
docker pull ht944/rabbit:latest



#创建并启动rabbit容器
#cd /root/rabbit
echo -e "${green}开始创建rabbit容器${plain}"
cd /root/Rabbit && docker run --name rabbit -d  -v "$(pwd)"/Config:/usr/src/Project/Config -p 5701:1234 ht944/rabbit:latest

baseip=$(curl -s ipip.ooo)  > /dev/null

echo -e "${green}安装完毕,面板访问地址：http://${baseip}:5701"
}

update_rabbit(){
docker pull ht944/rabbit:latest && cd /root/Rabbit && docker run --name rabbit -d  -v "$(pwd)"/Config:/usr/src/Project/Config -p 5701:1234 ht944/rabbit:latest
baseip=$(curl -s ipip.ooo)  > /dev/null
docker rm -f rabbit
docker pull ht944/rabbit:latest
docker run --name rabbit -d  -v --restart unless-stopped "$(pwd)"/Config:/usr/src/Project/Config -p 5701:1234 ht944/rabbit:latest

docker update --restart=always rabbit
echo -e "${green}rabbit更新完毕，脚本自动退出。${plain}"
exit 0
}

uninstall_rabbit(){
	docker=$(docker ps -a|grep rabbit) && dockerid=$(awk '{print $(1)}' <<<${docker})
	images=$(docker images|grep rabbit) && imagesid=$(awk '{print $(3)}' <<<${images})
	docker stop -t=5 "${dockerid}" > /dev/null 2>&1
	docker rm "${dockerid}"
	docker rmi "${imagesid}"
	rm -rf /root/Rabbit
echo -e "${green}rabbit面板已卸载，镜像已删除。${plain}"
exit 0
}

menu() {
  echo -e "\
${green}0.${plain} 退出脚本
${green}1.${plain} 安装rabbit
${green}2.${plain} 升级rabbit
${green}3.${plain} 卸载rabbit
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
    install_rabbit
    ;;
  2)
    update_rabbit
    ;;	
  3)
    uninstall_rabbit
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
