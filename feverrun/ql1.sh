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
	TIME g " 您选择了手动自动提交助力码库"
	echo
	TIME y " 请选择网络类型"
	echo
	echo
	TIME l " 1. bridge [默认类型]"
	echo
	TIME l " 2. host [一般为openwrt旁路由才选择的]"
	echo
	scqlbianma="[输入您选择的编码]"
	while :; do
	read -p " ${scqlbianma}： " SCQL
	case $SCQL in
		1)
			export QL_PORT="5700"
			export QING_PORT="YES"
			export NETWORK="-p ${QL_PORT}:5700"
		break
		;;
		2)
			export NETWORK="--net host"
			export QL_PORT="5700"
		break
    		;;
    		*)
			scqlbianma="[请输入正确的编码]"
		;;
	esac
	done
else
	echo
	TIME y "警告：请使用root用户操作!~~"
fi
echo
echo
[[ "${QING_PORT}" == "YES" ]] && {
	TIME g "请设置端口，默认端口为[5700]，不懂设置的话，直接回车使用默认[5700]端口"
	read -p " 请输入端口：" QL_PORT
	export QL_PORT=${QL_PORT:-"5700"}
	TIME y "您端口为：${QL_PORT}"
	export NETWORK="-p ${QL_PORT}:5700"
}
echo
echo
rm -fr ql.sh
echo
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	TIME g "正在安装宿主机所需要的依赖，请稍后..."
	export QL_PATH="/opt"
	yum -y update
	yum -y install sudo wget git
	yum -y install net-tools.x86_64
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	TIME g "正在安装宿主机所需要的依赖，请稍后..."
	export QL_PATH="/opt"
	apt-get -y update
	apt-get -y install sudo wget git
	apt-get -y install net-tools
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	TIME g "正在安装宿主机所需要的依赖，请稍后..."
	export QL_PATH="/opt"
	apt -y update
	apt -y install sudo wget git
	apt -y install net-tools
elif [[ "$(. /etc/os-release && echo "$ID")" == "openwrt" ]]; then
	if [[ -d /opt/docker ]]; then
		export QL_PATH="/opt"
		export QL_Kongjian="/opt/docker"
	elif [[ -d /mnt/mmcblk2p4/docker ]]; then
		export QL_PATH="/root"
		export QL_Kongjian="/mnt/mmcblk2p4/docker"
	else
		TIME g "没找到/opt/docker或者/mnt/mmcblk2p4/docker"
		exit 1
	fi
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
		TIME r "没检测到docker，openwrt请自行安装docker，如果空间太小请挂载好[opt]路径的硬盘,N1或者其他晶晨系列的挂载到的挂载到[mnt]"
		echo
		sleep 3
		exit 1
	fi
else
	if [[ `docker --version | grep -c "version"` -eq '0' ]]; then
		echo
		TIME y "没发现有docker，正在安装docker，请稍后..."
		bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/docker.sh)"
		
	fi
fi
if [[ "${XTong}" == "openwrt" ]]; then
	 if [[ -x "$(command -v docker)" ]]; then
	 	echo
	 else
		echo
		TIME r "没检测到docker，openwrt请自行安装docker，如果空间太小请挂载好[opt]路径的硬盘,N1或者其他晶晨系列的挂载到的挂载到[mnt]"
		echo
		sleep 3
		exit 1
	fi
else
	if [[ `docker --version | grep -c "version"` -eq '0' ]]; then
		echo
		TIME y "没检测到docker，请先安装docker"
		bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/docker.sh)"
		echo
		sleep 3
		exit 1
	else
		systemctl start docker
		sleep 5
	fi
fi
if [[ `docker ps -a | grep -c "qinglong"` -ge '1' ]]; then
	echo
	TIME y "检测到已有青龙面板，正在删除旧的青龙容器和镜像，请稍后..."
	if [[ -z "$(ls -A "$QL_PATH/qlbeifen1" 2>/dev/null)" ]]; then
		if [[ -n "$(ls -A "$QL_PATH/ql/config" 2>/dev/null)" ]]; then
			echo
			TIME g "检测到 $QL_PATH/ql ,为避免损失，正在把 $QL_PATH/ql 备份到 $QL_PATH/qlbeifen 文件夹"
			echo
			TIME y "如有需要备份文件的请到 $QL_PATH/qlbeifen 文件夹查看"
			echo
			rm -fr $QL_PATH/qlbeifen && mkdir -p $QL_PATH/qlbeifen
			cp -r $QL_PATH/ql $QL_PATH/qlbeifen/ql > /dev/null 2>&1
			cp -r $QL_PATH/qlbeifen $QL_PATH/qlbeifen1 > /dev/null 2>&1
			rm -rf $QL_PATH/ql
			sleep 3
		fi
	fi
	docker=$(docker ps -a|grep qinglong) && dockerid=$(awk '{print $(1)}' <<<${docker})
	 #images=$(docker images|grep qinglong) && imagesid=$(awk '{print $(3)}' <<<${images})
	docker stop -t=5 "${dockerid}" > /dev/null 2>&1
	docker rm "${dockerid}"
	 #docker rmi "${imagesid}"
fi
if [[ "$(. /etc/os-release && echo "$ID")" == "openwrt" ]]; then
	Available="$(df -h | grep "${QL_Kongjian}" | awk '{print $4}' | awk 'NR==1')"
	FINAL=`echo ${Available: -1}`
	if [[ "${FINAL}" =~ (M|K) ]]; then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请挂载好大于2G的硬盘"
		echo
		sleep 1
		exit 1
		echo
	fi
else
	Ubunkj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1')"
	FINAL=`echo ${Ubunkj: -1}`
	if [[ "${FINAL}" =~ (M|K) ]]; then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请加大磁盘空间容量"
		echo
		sleep 1
		exit 1
		echo
	fi
fi
if [[ "$(. /etc/os-release && echo "$ID")" == "openwrt" ]]; then
	Overlay_Available="$(df -h | grep "${QL_Kongjian}" | awk '{print $4}' | awk 'NR==1' | sed 's/.$//g')"
	Kongjian="$(awk -v num1=${Overlay_Available} -v num2=2 'BEGIN{print(num1>num2)?"0":"1"}')"
		echo
		TIME y "您当前系统可用空间为${Overlay_Available}G"
		echo
	if [[ "${Kongjian}" == "1" ]];then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请挂载好[opt]路径的硬盘"
		echo
		sleep 1
		exit 1
	fi
else
	Ubuntu_kj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1' |sed 's/.$//g')"
	Kongjian="$(awk -v num1=${Ubuntu_kj} -v num2=2 'BEGIN{print(num1>num2)?"0":"1"}')"
		echo
		TIME y "您当前系统可用空间为${Ubuntu_kj}G"
		echo
	if [[ "${Kongjian}" == "1" ]];then
		echo
		TIME r "敬告：可用空间小于[ 2G ]，不支持安装青龙，请加大磁盘空间"
		echo		
		sleep 1
		exit 1
	fi
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
export local_ip="$(curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress)"
if [[ `docker ps -a | grep -c "qinglong"` -ge '1' ]]; then
	if [[ -n "$(ls -A "${QL_PATH}/qlbeifen1" 2>/dev/null)" ]]; then
		docker cp ${QL_PATH}/qlbeifen1/ql/config/env.sh qinglong:/ql/config/env.sh
		docker cp ${QL_PATH}/qlbeifen1/ql/db/env.db qinglong:/ql/db/env.db
		docker cp ${QL_PATH}/qlbeifen1/ql/config/auth.json qinglong:/ql/config/auth.json
		docker cp ${QL_PATH}/qlbeifen1/ql/db/auth.db qinglong:/ql/db/auth.db
	fi
	if [[ `docker exec -it qinglong bash -c "cat /ql/config/auth.json" | grep -c "\"token\""` == '0' ]]; then
		curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/authbk.json > ${QL_PATH}/ql/authbk.json
		sleep 2
		docker cp ${QL_PATH}/ql/authbk.json qinglong:/ql/config/auth.json
		curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun/authbk.json > /opt/ql/config/auth.json
	fi
	docker restart qinglong
	sleep 5
	clear
	echo
	TIME y "青龙面板安装完成，下一步进入安装任务程序，请耐心等候..."
	docker exec -it qinglong bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/QL-/main/feverrun.sh)"
	echo
	if [[ ! -d /opt/ql/scripts/feverrun_my_scripts ]]; then
		sleep 2
		exit 1
	fi	
	docker restart qinglong > /dev/null 2>&1
	sleep 2
	clear
	echo
	echo
	TIME y "${IP}:${QL_PORT} ,如果是VPS请用 ${local_ip}:${QL_PORT} (IP检测因数太多，不一定准确，仅供参考)"
	echo
	TIME y "请确保您系统已放行${QL_PORT}端口，然后使用您的 IP:${QL_PORT} 在浏览器打开页面,登录青龙面板"
	echo
	TIME y "点击[开始安装]，[通知方式]跳过，设置好[用户名]跟[密码],然后点击[提交]，然后点击[去登录]，输入帐号密码完成登录!"
	echo
	TIME y "完成登录后,请设置好 wskey 或者 pt_key "	
	rm -fr ${QL_PATH}/qlbeifen1 > /dev/null 2>&1
	rm -fr ${QL_PATH}/ql/authbk.json > /dev/null 2>&1
	echo
	exit 0
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
