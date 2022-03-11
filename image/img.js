docker exec -it qinglong bash -c "task /ql/jd/1-5.sh && python3 /ql/jd/1-5.py"
docker exec -it qinglong bash -c "task /ql/jd/6-10.sh && python3 /ql/jd/6-10.py"
运行命令后，显示  Please enter your phone (or bot token):
就输入您的注册TG的电话，如果是大陆的格式就是+8613666666666
然后TG接收到验证码填上，再下来，如果TG有密码就输入密码




 python3 /opt/ql/scripts/jd_sms_login.py
