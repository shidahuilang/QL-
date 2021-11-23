
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
	clear
	echo
	echo
	TIME z "脚本适用于（ubuntu、debian、centos、openwrt）"
	TIME z "一键安装青龙，包括（docker、任务、依赖安装，一条龙服务），安装路径[opt]"
	TIME z "自动检测docker，有则跳过，无则安装，openwrt则请自行安装docker，如果空间太小请挂载好硬盘"
	TIME z "如果您以前安装有青龙的话，则自动删除您的青龙容器和镜像，全部推倒重新安装"
	TIME z "如果安装当前文件夹已经存在 ql 文件的话，如果您的[环境变量文件]符合要求，就会继续使用，免除重新输入KEY的烦恼"
	echo
	echo
	TIME y " 请选择要安装的脚本库"
	echo
	TIME l " 1. 手动提交助力码脚本，Telegram添加机器人自己每个星期提交一次助力码"
	echo
	TIME l " 2. 自动提交助力码脚本，要去脚本作者群提交资料过白名单(挂机帐号太少一般不收)"
	echo
	TIME l " 3. 退出安装程序!"
	echo
	scqlbianmaa="[输入您选择的编码]"
	while :; do
	read -p " ${scqlbianmaa}： " QLJB
	case $QLJB in
		1)
			bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/Aaron-lv/lang.sh)"
		break
		;;
		2)
			bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/shidahuilang/QL-@main/feverrun/dalang.sh)"
		break
		;;
		3)
			echo
			TIME r "您选择了退出程序!"
			rm -fr ql.sh
			echo
			sleep 1
			exit 1
		break
    		;;
    		*)
			scqlbianmaa="[请输入正确的编码]"
		;;
	esac
	done
exit 0
