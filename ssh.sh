#!/usr/bin/env bash

function system_check() {
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    system_centos
  elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
    system_ubuntu
  elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
    system_debian
  elif [[ "$(. /etc/os-release && echo "$ID")" == "alpine" ]]; then
    system_alpine
  elif [[ -f /etc/openwrt_release ]] && [[ -f /rom/etc/openwrt_release ]]; then
    echo -e "\033[33m openwrt无需开启root账户SSH \033[0m"
    exit 0
  else
    echo -e "\033[41;33m 不支持您的系统  \033[0m"
    exit 1
  fi
}

function system_centos() {
  if [[ ! -f /etc/ssh/sshd_config ]]; then
    echo -e "\033[33m 安装SSH \033[0m"
    yum install -y openssh-server
    systemctl enable sshd.service
    ssh_PermitRootLogin
    service sshd restart
  else
    ssh_PermitRootLogin
    service sshd restart
  fi
  exit 0
}

function system_ubuntu() {
  if [[ ! -f /etc/ssh/sshd_config ]]; then
    echo -e "\033[33m 安装SSH \033[0m"
    apt-get -y update
    apt-get install -y openssh-server
    ssh_PermitRootLogin
    service ssh restart
  else
    ssh_PermitRootLogin
    service ssh restart
  fi
  exit 0
}

function system_debian() {
  if [[ ! -f /etc/ssh/sshd_config ]]; then
    echo -e "\033[33m 安装SSH \033[0m"
    apt -y update
    apt install -y openssh-server
    ssh_PermitRootLogin
    service ssh restart
  else
    ssh_PermitRootLogin
    service ssh restart
  fi
  exit 0
}

function system_alpine() {
  if [[ ! -f /etc/ssh/sshd_config ]]; then
    echo -e "\033[33m 安装SSH \033[0m"
    apk add openssh-server
    apk add openssh-client
    rc-update add sshd
    ssh_PermitRootLogin
    service sshd restart
  else
    ssh_PermitRootLogin
    service sshd restart
  fi
  exit 0
}

function ssh_PermitRootLogin() {
  if [[ `grep -c "ClientAliveInterval 30" /etc/ssh/sshd_config` == '0' ]]; then
    sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
    sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
    sed -i '/PermitRootLogin/d' /etc/ssh/sshd_config
    sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
    sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
    sh -c 'echo PermitRootLogin yes >> /etc/ssh/sshd_config'
  fi
}
system_check "$@"
