#!/bin/bash

# 创建映射文件夹
read -p "请输入映射文件夹路径（默认为 /root/pro）: " pro_path
pro_path=${pro_path:-"/root/pro"}
mkdir -p $pro_path
cd $pro_path

# 获取 Prolic
read -p "请输入 Prolic: " prolic

# 获取管理账号和密码
read -p "请输入自定义管理帐号: " admin_user
read -p "请输入自定义管理密码(八位以上包含大小写字母、数字或特殊字符): " admin_pwd

# 启动容器
docker run -id \
--name pro -p 5016:5016 \
-v "$(pwd)":/app/Data \
-e Prolic=$prolic \
-e User=$admin_user \
-e Pwd=$admin_pwd \
--privileged=true \
nolanhzy/pro:latest

# 检查容器是否启动成功
if [ $(docker ps -f "name=pro" --format "{{.Names}}" | grep -c "pro") -eq 1 ]
then
    echo "容器已成功启动！"
else
    echo "容器启动失败，请检查！"
    exit 1
fi

# 检查面板是否正常
read -p "请在浏览器中输入 IP:5016 并回车，查看面板是否正常（y/n）: " check_panel
if [ $check_panel == "y" ]
then
    echo "面板正常！"
else
    echo "面板异常，请检查！"
    exit 1
fi

# 进入管理界面
read -p "请在浏览器中输入 IP:5016/#/admin 并回车，进入管理界面（y/n）: " enter_admin
if [ $enter_admin == "y" ]
then
    echo "已成功进入管理界面！"
else
    echo "进入管理界面失败，请检查！"
    exit 1
fi
