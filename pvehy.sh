#!/bin/bash

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
echo
echo
TIME g "正在更换源...!"
echo
echo
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo '
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
deb http://mirrors.aliyun.com/debian-security/ buster/updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian-security/ buster/updates main non-free contrib
' > /etc/apt/sources.list
sed -i '1d' /etc/apt/sources.list

cp -fr /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
rm -rf /etc/apt/sources.list.d/pve-enterprise.list
echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve bullseye pve-no-subscription" >/etc/apt/sources.list.d/pve-install-repo.list
echo
echo
TIME g "下载PVE7.0源的密匙!"
echo
echo
cp -fr /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg.bak
rm -fr /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
wget http://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
if [[ $? -ne 0 ]];then
	wget http://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
    	if [[ $? -ne 0 ]];then
      		TIME r "下载秘钥失败，请检查网络再尝试!"
      		sleep 2
      		exit 1
    	fi
fi
echo
echo
TIME g "去掉无效订阅"
echo
echo
cp /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak
sed -i 's#if (res === null || res === undefined || !res || res#if (false) {#g' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
sed -i '/data.status.toLowerCase/d' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
echo
echo
TIME g "更新源、安装常用软件和升级"
echo
echo
apt-get update && apt-get install -y net-tools curl git
apt dist-upgrade -y
sleep 3
sed -i 's#http://download.proxmox.com#https://mirrors.ustc.edu.cn/proxmox#g' /usr/share/perl5/PVE/APLInfo.pm
echo
echo
TIME g "更换DNS为223.5.5.5和114.114.114.114"
echo
echo
cp /etc/resolv.conf /etc/resolv.conf.bak
echo '
search com
nameserver 223.5.5.5
nameserver 114.114.114.114
' > /etc/resolv.conf
sed -i '1d' /etc/resolv.conf
rm -fr /root/pvehy.sh
echo
echo
TIME g "重启PVE，需要几分钟时间，请耐心等候..."
echo
echo
reboot
