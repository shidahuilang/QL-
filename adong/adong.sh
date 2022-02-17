#!/usr/bin/env bash
stty erase ^H
PORT=0
#判断当前端口是否被占用，没被占用返回0，反之1
function Listening() {
  TCPListeningnum=$(netstat -an | grep ":$1 " | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l)
  UDPListeningnum=$(netstat -an | grep ":$1 " | awk '$1 == "udp" && $NF == "0.0.0.0:*" {print $0}' | wc -l)
  ((Listeningnum = TCPListeningnum + UDPListeningnum))
  if [ $Listeningnum == 0 ]; then
    echo "0"
  else
    echo "1"
  fi
}

case $(uname -m) in
x86_64) is_x86=1 ;;
aarch64) is_x86=0 ;;
esac

synology=0
if [[ $(uname -a) == *synology* ]]; then
  synology=1
fi

#指定区间随机数
function random_range() {
  shuf -i $1-$2 -n1
}

#得到随机端口
function get_random_port() {
  templ=0
  while [ $PORT == 0 ]; do
    temp1=$(random_range $1 $2)
    if [ $(Listening $temp1) == 0 ]; then
      PORT=$temp1
    fi
  done
  echo "port=$PORT"
}

TIME() {
  [[ -z "$1" ]] && {
    echo -ne " "
  } || {
    case $1 in
    r) export Color="\e[31;1m" ;;
    g) export Color="\e[32;1m" ;;
    b) export Color="\e[34;1m" ;;
    y) export Color="\e[33;1m" ;;
    z) export Color="\e[35;1m" ;;
    l) export Color="\e[36;1m" ;;
    esac
    [[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
      echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
    }
  }
}

[[ ! "$USER" == "root" ]] && {
  echo
  TIME y "警告：请使用root用户操作!~~"
  echo
  exit 1
}

if [[ $synology == 1 ]]; then
  echo
  TIME y "你是群晖nas"
  echo
elif [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
  export Aptget="yum"
  yum -y update
  yum install -y sudo wget curl psmisc net-tools
  export XITONG="cent_os"
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
  export Aptget="apt-get"
  apt-get -y update
  apt-get install -y sudo wget curl psmisc net-tools
  export XITONG="ubuntu_os"
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" || "$(. /etc/os-release && echo "$ID")" == "Deepin" ]]; then
  export Aptget="apt"
  apt-get -y update
  apt-get install -y sudo wget curl psmisc net-tools
  export XITONG="debian_os"
elif [[ -f /etc/openwrt_release ]] && [[ -f /rom/etc/openwrt_release ]]; then
  export Aptget="opkg"
  opkg update
  opkg install git-http > /dev/null 2>&1
  opkg install ca-bundle > /dev/null 2>&1
  opkg install coreutils-timeout > /dev/null 2>&1
  opkg install findutils-xargs > /dev/null 2>&1
  opkg install unzip
else
  echo
  TIME y "本一键安装docker脚本只支持（centos、ubuntu和debian,NAS,OpenWrt）!"
  echo
  exit 1
fi

ignore_install_docker=0
if [[ $(docker --version | grep -c "version") -ge '1' ]]; then
  echo
  if [[ $synology == 1 ]]; then
    TIME y "已安装docker，进行下一步"
    ignore_install_docker=1
  else
    TIME y "检测到docker存在，是否重新安装?"
    echo
    TIME g "重新安装会把您现有的所有容器及镜像全部删除，请慎重!"
    echo
    while :; do
      read -p " [输入[ N/n ]回车跳过安装docker，输入[ Y/y ]回车重新安装docker]： " ANDK
      case $ANDK in
      [Yy])
        TIME g "正在御载老版本docker"
        export CHONGXIN="YES"
        docker stop $(docker ps -a -q)
        docker rm $(docker ps -a -q)
        docker rmi $(docker images -q)
        sudo "${Aptget}" remove -y docker docker-engine docker.io containerd runc
        sudo "${Aptget}" remove -y docker
        sudo "${Aptget}" remove -y docker-ce
        sudo "${Aptget}" remove -y docker-ce-cli
        sudo "${Aptget}" remove -y docker-ce-rootless-extras
        sudo "${Aptget}" remove -y docker-scan-plugin
        sudo "${Aptget}" remove -y --auto-remove docker
        sudo rm -rf /var/lib/docker
        sudo rm -rf /etc/docker
        sudo rm -rf /lib/systemd/system/{docker.service,docker.socket}
        rm /var/lib/dpkg/info/$nomdupaquet* -f
        break
        ;;
      [Nn])
        echo
        TIME r "跳过安装docker!"
        echo
        sleep 1
        ignore_install_docker=1
        break
        ;;
      *)
        echo
        TIME b "提示：请输入正确的选择!"
        echo
        ;;
      esac
    done
  fi
fi

if [ $ignore_install_docker == 0 ]; then
  echo
  TIME y "正在安装docker，请耐心等候..."
  echo
  if [[ ${XITONG} == "cent_os" ]]; then
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    sudo yum -y update
    sudo yum install -y docker-ce
    sudo yum install -y docker-ce-cli
    sudo yum install -y containerd.io
  fi
  if [[ ${XITONG} == "ubuntu_os" ]]; then
    if [ $is_x86 == 1 ]; then
      sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
      curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
      if [[ $? -ne 0 ]]; then
        curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
      fi
      sudo apt-key fingerprint 0EBFCD88
      if [[ $(sudo apt-key fingerprint 0EBFCD88 | grep -c "0EBF CD88") == '0' ]]; then
        TIME r "密匙验证出错，或者没下载到密匙了，请检查网络，或者源有问题"
        sleep 5
        exit 1
        sleep 5
      fi
      sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
      sudo apt-get update
      sudo apt-get install -y docker-ce
      sudo apt-get install -y docker-ce-cli
      sudo apt-get install -y containerd.io
    else
      sudo apt-get update
      sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg -f --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    fi
  fi
  if [[ ${XITONG} == "debian_os" ]]; then
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | sudo apt-key add -
    if [[ $? -ne 0 ]]; then
      curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | sudo apt-key add -
    fi
    sudo apt-key fingerprint 0EBFCD88
    if [[ $(sudo apt-key fingerprint 0EBFCD88 | grep -c "0EBF CD88") == '0' ]]; then
      TIME r "密匙验证出错，或者没下载到密匙了，请检查网络，或者上游有问题"
      sleep 5
      exit 1
      sleep 5
    fi
    sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo apt-get install -y docker-ce-cli
    sudo apt-get install -y containerd.io
  fi
  sudo rm -fr /etc/systemd/system/docker.service.d
  sed -i 's#ExecStart=/usr/bin/dockerd -H fd://#ExecStart=/usr/bin/dockerd#g' /lib/systemd/system/docker.service
  sudo systemctl daemon-reload
  sudo rm -fr docker.sh
  if [[ $(docker --version | grep -c "version") == '0' ]]; then
    TIME y "docker安装失败"
    sleep 2
    exit 1
  else
    # 1.创建一个目录
    sudo mkdir -p /etc/docker

    # 2.编写配置文件
    sudo tee /etc/docker/daemon.json <<-'EOF'
      {
        "registry-mirrors": ["http://hub-mirror.c.163.com",
          "https://docker.mirrors.ustc.edu.cn",
          "https://mirror.ccs.tencentyun.com"
        ]
      }
EOF

    TIME y ""
    TIME g "docker安装成功，正在启动docker，请稍后..."
    sudo systemctl restart docker
    sudo systemctl start docker
    sudo systemctl enable docker.service
    sleep 12
    TIME y ""
    TIME g "测试docker拉取镜像是否成功"
    TIME y ""
    sudo docker run hello-world | tee build.log
    if [[ $(docker ps -a | grep -c "hello-world") -ge '1' ]] && [[ $(grep -c "docs.docker" build.log) -ge '1' ]]; then
      echo
      TIME g "测试镜像拉取成功，正在删除测试镜像..."
      echo
      docker stop $(docker ps -a -q)
      docker rm $(docker ps -a -q)
      docker rmi $(docker images -q)
      echo
      TIME y "测试镜像删除完毕，docker安装成功!"
      echo
    else
      echo
      TIME y "docker虽然安装成功但是拉取镜像失败，这个原因很多是因为以前的docker没御载完全造成的，或者容器网络问题"
      echo
      TIME y "重启服务器后，用 sudo docker run hello-world 命令测试吧，能拉取成功就成了"
      echo
      sleep 2
      exit 1
    fi
  fi
  rm -fr build.log
fi

dir='jd-qinglong'
TIME y "请指定保存数据的目录，已存在的请指定名字，回车默认jd-qinglong"
read input
if [ -z "${input}" ]; then
  input=$dir
fi
dir=$input

if [ ! -d $dir ]; then
  mkdir $dir
fi

cd $dir || exit

rm -f adbot/adbot

file=env.properties
if [ ! -f "$file" ]; then
  wget -O env.properties https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/adong/env.properties
else
  echo "env.properties已存在"
fi

sudo docker rm -f webapp
if [ $is_x86 == 1 ]; then
  sudo docker pull rubyangxg/jd-qinglong
else
  sudo docker pull rubyangxg/jd-qinglong:arm
fi

ad_port1=5701
TIME y "请设置阿东网页登录端口：(数字80~65535)，回车默认5701"
while [ 1 ]; do
  read input
  if [ -z "${input}" ]; then
    input=5701
  fi
  if [ $input -gt 79 -a $input -lt 65536 ]; then
    grep_port=$(netstat -tlpn | grep "\b$input\b")
    if [ -n "$grep_port" ]; then
      get_random_port 5701 5800
      ad_port1=$PORT
      echo -e "端口 $input 已被占用，生成随机端口$ad_port1，配置成功\n"
    else
      echo -e "端口 $input 未被使用，配置成功\n"
      ad_port1=$input
    fi
    break
  else
    TIME r "别瞎搞，请输入端口：(数字80~65535)"
  fi
done

ad_port2=9527
grep_port=$(netstat -tlpn | grep "\b$ad_port2\b")
if [ -n "$grep_port" ]; then
  get_random_port 9527 9600
  ad_port2=$PORT
  TIME -e "端口 9527 已被占用，生成随机端口$ad_port2，配置成功\n"
fi


adbotDir="$(pwd)"/adbot
if [ $synology == 1 ]; then
  if [ ! -d $adbotDir ]; then
    mkdir $adbotDir
  fi
fi

if [ $is_x86 == 1 ]; then
  docker run -d -p $ad_port1:8080 -p $ad_port2:8090 --name=webapp -e TZ=Asia/Shanghai --privileged=true -v "$(pwd)"/env.properties:/env.properties:rw -v "$(pwd)"/adbot:/adbot --restart always rubyangxg/jd-qinglong
else
  docker run -d -p $ad_port1:8080 -p $ad_port2:8090 --name=webapp -e TZ=Asia/Shanghai -e "SPRING_PROFILES_ACTIVE=arm" --privileged=true -v "$(pwd)"/env.properties:/env.properties:rw -v "$(pwd)"/adbot:/adbot --restart always rubyangxg/jd-qinglong:arm
fi

while [ 1 ]; do
  if [ -f "./adbot/adbot" ]; then
    sleep 1s
    echo "阿东启动成功"
    break
  else
    echo "等待阿东启动完成，生成必要文件"
    sleep 1s
  fi
done

json='{"server_groups":[{"name":"webapp","disabled":false,"json":false,"urls":["ws://localhost:'$ad_port1'/ws/cq/"],"event_filter":[],"regex_filter":"","regex_replace":"","extra_header":{"User-Agent":["GMC"]}},{"name":"webapp_admin","disabled":false,"json":false,"urls":["ws://localhost:'$ad_port2'/ws/cq/"],"event_filter":[],"regex_filter":"","regex_replace":"","extra_header":{"User-Agent":["GMC"]}}]}'
echo $json >./adbot/gmc_config.json

cd adbot || exit
chmod +x adbot

echo "请创建一个机器人管理页面用户名：(字母数字下划线)，回车默认admin"
while [ 1 ]; do
  read input
  if [ -z "${input}" ]; then
    input="admin"
  fi
  if [[ $input =~ ^[A-Za-z0-9_]+$ ]]; then
    username=$input
    break
  else
    echo "别瞎搞，请输入用户名：(字母数字下划线)，回车默认随机字符"
  fi
done

echo "请设置机器人管理页面密码：(字母数字下划线)，回车默认adbotadmin"
while [ 1 ]; do
  read input
  if [ -z "${input}" ]; then
    input="adbotadmin"
  fi
  if [[ $input =~ ^[A-Za-z0-9_]+$ ]]; then
    password=$input
    break
  else
    echo "别瞎搞，请输入密码：(字母数字下划线)，回车默认随机字符"
  fi
done

killall adbot

port=8100
echo "请设置机器人管理页面登录端口：(数字80~65535)，回车默认8100"
while [ 1 ]; do
  read input
  if [ -z "${input}" ]; then
    input=8100
  fi
  if [ $input -gt 79 -a $input -lt 65536 ]; then
    grep_port=$(netstat -tlpn | grep "\b$input\b")
    if [ -n "$grep_port" ]; then
      get_random_port 8100 8200
      port=$PORT
      echo -e "端口 $input 已被占用，生成随机端口$port，配置成功\n"
    else
      echo -e "端口 $input 未被使用，配置成功\n"
      port=$input
    fi
    break
  else
    echo "别瞎搞，请输入端口：(数字80~65535)"
  fi
done

echo "机器人管理页面用户名是$username"
echo "机器人管理页面密码是$password"
echo "机器人管理页面端口是$port"
echo "阿东网页登录端口$ad_port1"

sed -i "s#^username=.*#username=$username#g" ./start-adbot.sh
sed -i "s#^password=.*#password=$password#g" ./start-adbot.sh
sed -i "s#^port=.*#port=$port#g" ./start-adbot.sh

chmod +x ./start-adbot.sh
bash ./start-adbot.sh restart

hasError1=1
for i in {1..10}; do
  urlstatus=$(curl -s -m 5 -IL http://localhost:$ad_port1/ping | grep 200)
  if [ "$urlstatus" == "" ]; then
    echo "检查是否可访问阿东页面...第 $i 次(共10次)，如果机器太慢可能会检查超时，请自行确认服务正常。"
    sleep 5s
  else
    hasError1=0
    break
  fi
done

hasError2=1
for i in {1..10}; do
  urlstatus=$(curl -u $username:$password -s -m 5 -IL http://localhost:$port | grep 200)
  if [ "$urlstatus" == "" ]; then
    echo "检查是否可访问机器人管理页面...第 $i 次(共10次)"
    sleep 6s
  else
    hasError2=0
    break
  fi
done

if [ $hasError1 == 1 -o $hasError2 == 1 ]; then
  echo "出错了，请联系作者，查看日志docker logs -f webapp"
else
  sed -i '/^ADONG.URL.*/d' ../env.properties
  sed -i '$aADONG.URL=http://localhost:'$ad_port1'' ../env.properties
  echo "恭喜你安装完成，阿东网页：http://localhost:$ad_port1，阿东机器人登录入口：http://localhost:$port，外部访问请打开防火墙并且开放 $ad_port1 和 $port 端口！"
fi

