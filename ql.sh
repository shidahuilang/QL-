#!/usr/bin/env bash
# 
TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}

[[ ! "$USER" == "root" ]] && {
	clear
	echo
	TIME y "警告：请使用root用户操作!~~"
	echo
	sleep 2
	exit 1
}

if [[ "$USER" == "root" ]]; then
	clear
	echo
	echo
	echo
	TIME z "脚本适用于（ubuntu、debian、centos、openwrt）"
	TIME z "一键安装青龙，包括（docker、任务、依赖安装，一条龙服务），安装路径[opt]"
	TIME z "自动检测docker，有则跳过，无则安装，openwrt则请自行安装docker，如果空间太小请挂载好硬盘"
	TIME z "如果您以前安装有青龙的话，则自动删除您的青龙容器和镜像，全部推倒重新安装"
	TIME z "如果您以前青龙文件在root/ql或者/opt/ql，如果您的[帐号密码文件]和[环境变量文件]符合要求，就会继续使用"
	TIME g "如要不能接受的话，请选择 3 回车退出程序!"
	echo
	echo
	echo
	TIME y " 如要继续的话，请选择容器的网络类型!（输入 1、2或3 编码）"
	echo
	TIME l " 1. bridge [默认类型]"
	echo
	TIME l " 2. host [一般为openwrt旁路由才选择的]"
	echo
	TIME l " 3. 退出安装程序!"
	echo
	while :; do
	read -p " [输入您选择的编码]： " SCQL
	case $SCQL in
		1)
			QL_PORT="5700"
			QING_PORT="YES"
			NETWORK="-p ${QL_PORT}:5700"
		break
		;;
		2)
			NETWORK="--net host"
			QL_PORT="5700"
		break
		;;
		3)
			echo
			TIME r "您选择了退出程序!"
			rm -fr ql.sh
			echo
			sleep 3
			exit 1
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
echo
echo
[[ "${QING_PORT}" == "YES" ]] && {
	TIME g "请设置端口，默认端口为[5700]，不懂设置的话，直接回车跳过"
	read -p " 请输入端口：" QL_PORT
	QL_PORT=${QL_PORT:-"5700"}
	TIME y "您端口为：${QL_PORT}"
	NETWORK="-p ${QL_PORT}:5700"
}
echo
echo
rm -fr ql.sh
echo
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	TIME g "正在安装宿主机所需要的依赖，请稍后..."
	QL_PATH="/opt"
	yum -y update
	yum -y install sudo wget curl git
	yum -y install net-tools.x86_64
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	TIME g "正在安装宿主机所需要的依赖，请稍后..."
	QL_PATH="/opt"
	apt-get -y update
	apt-get -y install sudo wget curl git
	apt-get -y install net-tools
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	TIME g "正在安装宿主机所需要的依赖，请稍后..."
	QL_PATH="/opt"
	apt -y update
	apt -y install sudo wget curl git
	apt -y install net-tools
elif [[ "$(. /etc/os-release && echo "$ID")" == "openwrt" ]]; then
	QL_PATH="/opt"
	XTong="openwrt"
	opkg list | awk '{print $1}' > Installed_PKG_List
	if [[ ! "$(cat Installed_PKG_List)" =~ git-http ]]; then
		TIME g "正在安装宿主机所需要的依赖，请稍后..."
		opkg update
		opkg install git-http > /dev/null 2>&1
		rm -fr Installed_PKG_List
	fi

fi
IP="$(ifconfig -a|grep inet|grep -v 127|grep -v 172|grep -v inet6|awk '{print $2}'|tr -d "addr:")"
if [[ -z "${IP}" ]]; then
	IP="IP"
fi
if [[ "${XTong}" == "openwrt" ]]; then
	 if [[ -x "$(command -v docker)" ]]; then
	 	echo
	 else
		echo
		TIME r "没检测到docker，openwrt请自行安装docker，如果空间太小请挂载好[opt]路径的硬盘"
		echo
		sleep 3
		exit 1
	fi
else
	if [[ `docker --version | grep -c "version"` -eq '0' ]]; then
		echo
		TIME y "没发现有docker，正在安装docker，请稍后..."
		echo
		wget -O docker.sh https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/docker.sh && bash docker.sh
		if [[ $? -ne 0 ]];then
			wget -qO docker.sh https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/docker.sh > docker.sh && bash docker.sh
			if [[ $? -ne 0 ]];then
				echo
				TIME r "下载安装docker文件失败，请检查网络..."
				exit 1
				echo
			fi
		fi
		
	fi
fi
if [[ "${XTong}" == "openwrt" ]]; then
	 if [[ -x "$(command -v docker)" ]]; then
	 	echo
	 else
		echo
		TIME r "没检测到docker，openwrt请自行安装docker，如果空间太小请挂载好[opt]路径的硬盘"
		echo
		sleep 3
		exit 1
	fi
else
	if [[ `docker --version | grep -c "version"` -eq '0' ]]; then
		echo
		TIME y "没检测到docker，请先安装docker"
		echo
		sleep 3
		exit 1
	else
		systemctl start docker
		sleep 8
	fi
fi
if [[ `docker ps -a | grep -c "qinglong"` -ge '1' ]]; then
	echo
	TIME y "检测到已有青龙面板，正在删除旧的青龙容器和镜像，请稍后..."
	echo
	if [[ -n "$(ls -A "/opt/ql/config" 2>/dev/null)" ]] || [[ -n "$(ls -A "/root/ql/config" 2>/dev/null)" ]]; then
		echo
		TIME g "为避免损失，正在把opt或者root的 /ql/config和/ql/db 备份到 /opt/qlbak 文件夹"
		echo
		TIME y "如有需要备份文件的请到 /opt/ql 文件夹查看"
		echo

	        rm -fr /opt/qlbak && mkdir -p /opt/qlbak
		cp -r /opt/ql/config /opt/qlbak/config > /dev/null 2>&1
		cp -r /opt/ql/db /opt/qlbak/db > /dev/null 2>&1
		cp -r /root/ql/config /opt/qlbak/config > /dev/null 2>&1
		cp -r /root/ql/db /opt/qlbak/db > /dev/null 2>&1
		rm -rf /opt/ql
	fi
	docker=$(docker ps -a|grep qinglong) && dockerid=$(awk '{print $(1)}' <<<${docker})
	images=$(docker images|grep qinglong) && imagesid=$(awk '{print $(3)}' <<<${images})
	docker stop -t=5 "${dockerid}"
	docker rm "${dockerid}"
	docker rmi "${imagesid}"
fi
if [[ "$(. /etc/os-release && echo "$ID")" == "openwrt" ]]; then
	Available="$(df -h | grep "/opt/docker" | awk '{print $4}' | awk 'NR==1')"
	FINAL=`echo ${Available: -1}`
	if [[ "${FINAL}" =~ (M|K) ]]; then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请挂载好大于2G的[opt]路径的硬盘"
		echo
		sleep 2
		exit 1
		echo
	fi
else
	Ubunkj="$(df -h | grep "/dev/*/" | awk '{print $4}' | awk 'NR==1')"
	FINAL=`echo ${Ubunkj: -1}`
	if [[ "${FINAL}" =~ (M|K) ]]; then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请加大磁盘空间容量"
		echo
		sleep 2
		exit 1
		echo
	fi
fi
if [[ "$(. /etc/os-release && echo "$ID")" == "openwrt" ]]; then
	Overlay_Available="$(df -h | grep "/opt/docker" | awk '{print $4}' | awk 'NR==1' | sed 's/.$//g')"
	Kongjian="$(awk -v num1=${Overlay_Available} -v num2=2 'BEGIN{print(num1>num2)?"0":"1"}')"
		echo
		TIME y "您当前系统可用空间为${Overlay_Available}G"
		echo
	if [[ "${Kongjian}" == "1" ]];then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请挂载好[opt]路径的硬盘"
		echo
		sleep 2
		exit 1
	fi
else
	Ubuntu_kj="$(df -h | grep "/dev/*/" | awk '{print $4}' | awk 'NR==1' | sed 's/.$//g')"
	Kongjian="$(awk -v num1=${Ubuntu_kj} -v num2=2 'BEGIN{print(num1>num2)?"0":"1"}')"
		echo
		TIME y "您当前系统可用空间为${Ubuntu_kj}G"
		echo
	if [[ "${Kongjian}" == "1" ]];then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请加大磁盘空间"
		echo		
		sleep 2
		exit 1
	fi
fi
if [ -z "$(ls -A "/opt" 2>/dev/null)" ]; then
	mkdir -p /opt
fi
echo
echo
TIME g "正在安装青龙面板，请稍后..."
echo
docker run -dit \
  -v $QL_PATH/ql/config:/ql/config \
  -v $QL_PATH/ql/log:/ql/log \
  -v $QL_PATH/ql/db:/ql/db \
  -v $QL_PATH/ql/scripts:/ql/scripts \
  -v $QL_PATH/ql/jbot:/ql/jbot \
  -v $QL_PATH/ql/raw:/ql/raw \
  -v $QL_PATH/ql/repo:/ql/repo \
  ${NETWORK} \
  --name qinglong \
  --hostname qinglong \
  --restart always \
  whyour/qinglong:latest

if [[ `docker ps -a | grep -c "qinglong"` -ge '1' ]]; then
	if [[ -n "$(ls -A "/opt/qlbeifen" 2>/dev/null)" ]]; then
		docker cp /opt/qlbak/config/env.sh qinglong:/ql/config/env.sh
		docker cp /opt/qlbak/db/env.db qinglong:/ql/db/env.db
		docker cp /opt/qlbak/config/auth.json qinglong:/ql/config/auth.json
		docker cp /opt/qlbak/db/auth.db qinglong:/ql/db/auth.db
	fi
	docker=$(docker ps -a|grep qinglong) && dockerid=$(awk '{print $(1)}' <<<${docker})
	curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/nginx.conf > /root/nginx.conf
	if [[ $? -ne 0 ]];then
		curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/nginx.conf > /root/nginx.conf
	fi
	docker cp /root/nginx.conf "${dockerid}":/ql/docker/
	docker restart qinglong
	sleep 13
	clear
	echo
	echo
	echo
	if [[ `docker exec -it qinglong bash -c "cat /ql/config/auth.json" | grep -c "\"token\""` -ge '1' ]]; then
		echo
		TIME z "青龙面板安装完成，下一步进入安装脚本程序"
		echo
		TIME y " "${IP}":"${QL_PORT}"  (IP检测因数太多，不一定准确，仅供参考)"
		echo
		TIME g "检测到你已有配置，正在使用您的旧帐号密码和还原[环境变量]env.sh配置继续使用"
		echo
		docker exec -it qinglong bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun.sh)"
		if [[ $? -ne 0 ]];then
			docker exec -it qinglong bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun.sh)"
			if [[ $? -ne 0 ]];then
				echo
				TIME r "下载脚本文件失败，请检查网络..."
				exit 1
				echo
			fi
		fi
		echo
		TIME y "使用 "${IP}":"${QL_PORT}" 在浏览器打开页面，刷新页面，然后用你的旧帐号密码登录您的青龙面板"
		echo
		TIME g "如果不记得帐号密码请在 /opt/ql/config/auth.json 文件查看"
		echo
		exit 0
	
	else
		TIME z "青龙面板安装完成，下一步进入安装脚本程序"
		echo
		TIME y " "${IP}":"${QL_PORT}"  (IP检测因数太多，不一定准确，仅供参考)"
		echo
		TIME g "请使用 IP:端口 在浏览器打开控制面板"
		echo
		TIME y "点击[开始安装]，[通知方式]跳过，设置好[用户名]跟[密码],然后点击[提交]，然后点击[去登录]，输入帐号密码完成登录!"
		echo
		TIME g "登录进入后在左侧[环境变量]添加WSKEY或者PT_KEY，不添加也没所谓，以后添加一样，但是一定要登录进入后才继续下一步操作"
		echo
		while :; do
		read -p " [ N/n ]退出程序，[ Y/y ]回车继续安装脚本： " MENU
		if [[ `docker exec -it qinglong bash -c "cat /ql/config/auth.json" | grep -c "\"token\""` -ge '1' ]]; then
			S="Yy"
		else
			echo
			TIME r "提示：一定要登录管理面板之后再执行下一步操作,或者您输入[N/n]按回车退出!"
			echo
		fi
		case $MENU in
			[${S}])
				echo
				TIME y "开始安装脚本，请耐心等待..."
				echo
				docker exec -it qinglong bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun.sh)"
				if [[ $? -ne 0 ]];then
					docker exec -it qinglong bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun.sh)"
					if [[ $? -ne 0 ]];then
						echo
						TIME r "下载脚本文件失败，请检查网络..."
						exit 1
						echo
					fi
				fi
				exit 0
			break
			;;
			[Nn])
				echo
				TIME r "退出安装程序!"
				echo
				sleep 2
				exit 1
			break
    			;;
    			*)
				TIME r ""
			;;
		esac
		done
	fi
else
	echo
	echo
	TIME y "青龙面板安装失败！"
	echo
	sleep 2
	exit 1
fi
echo
exit 0
