"""
new Env('青龙全自动更新cookie');
"""

import requests
import time
import json
import re
import sys


requests.packages.urllib3.disable_warnings()

token = ""
username = ""
password = ""

# 自定义青龙端口：
port = ""

if username == "" or password == "":
    f = open("/ql/config/auth.json")
    auth = f.read()
    auth = json.loads(auth)
    username = auth["username"]
    password = auth["password"]
    token = auth["token"]
    f.close()
    
    
def printf(text):
    print(text)
    sys.stdout.flush()

    
def gettimestamp():
    return str(int(time.time() * 1000))


def login(username, password):
    url = qlurl + "/api/login?t=%s" % gettimestamp()
    data = {"username": username, "password": password}
    r = s.post(url, data)
    s.headers.update({"authorization": "Bearer " + json.loads(r.text)["data"]["token"]})


def getitem(key):
    url = qlurl + "/api/envs?searchValue=%s&t=%s" % (key, gettimestamp())
    r = s.get(url)
    item = json.loads(r.text)["data"]
    return item


def getckitem(key):
    url = qlurl + "/api/envs?searchValue=JD_COOKIE&t=%s" % gettimestamp()
    r = s.get(url)
    for i in json.loads(r.text)["data"]:
        if key in i["value"]:
            return i
    return []


def wstopt(wskey):
    try:
        url = "https://signer.nz.lu/getck"
        headers = {
            "user-agent": "Mozilla/5.0 (Windows NT 6.3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36"
        }
        data = {"wskey": wskey, "key": "xb3z4z2m3n847"}
        r = requests.post(url, headers=headers, data=json.dumps(data), verify=False)
        return r
    except:
        return "error"


def update(text, qlid):
    url = qlurl + "/api/envs?t=%s" % gettimestamp()
    s.headers.update({"Content-Type": "application/json;charset=UTF-8"})
    data = {
        "name": "JD_COOKIE",
        "value": text,
        "_id": qlid
    }
    r = s.put(url, data=json.dumps(data))
    if json.loads(r.text)["code"] == 200:
        return True
    else:
        return False


def insert(text):
    url = qlurl + "/api/envs?t=%s" % gettimestamp()
    s.headers.update({"Content-Type": "application/json;charset=UTF-8"})
    data = []
    data_json = {
        "value": text,
        "name": "JD_COOKIE"
    }
    data.append(data_json)
    r = s.post(url, json.dumps(data))
    if json.loads(r.text)["code"] == 200:
        return True
    else:
        return False


if __name__ == '__main__':
    s = requests.session()
    if token == "":
        login(username, password)
    else:
        s.headers.update({"authorization": "Bearer " + token})
    if port == "":
        try:
            r = requests.get("http://127.0.0.1:5700/login")
            qlurl = "http://127.0.0.1:5700"
        except:
            qlurl = "http://127.0.0.1:5600"
    else:
        qlurl = "http://127.0.0.1:" + port
    wskeys = getitem("JD_WSCK")
    count = 1
    for i in wskeys:
        if i["status"] == 0:
            r = wstopt(i["value"])
            if r == "error":
                printf("api请求错误")
            else:
                ptck = r.text
                if r.status_code == 429:
                    printf("您的ip请求api过于频繁，已被流控")
                    exit()
                else:
                    try:
                        wspin = re.findall(r"pin=(.*?);", i["value"])[0]
                        if ptck == "wskey错误":
                            printf("第%s个wskey可能过期了,pin为%s" % (count, wspin))
                        elif ptck == "未知错误" or ptck == "error":
                            printf("第%s个wskey发生了未知错误,pin为%s" % (count, wspin))
                        elif "</html>" in ptck:
                            printf("你的ip被cloudflare拦截")
                        else:
                            ptpin = re.findall(r"pt_pin=(.*?);", ptck)[0]
                            item = getckitem("pt_pin=" + ptpin)
                            if item != []:
                                qlid = item["_id"]
                                if update(ptck, qlid):
                                    printf("第%s个wskey更新成功,pin为%s" % (count, wspin))
                                else:
                                    printf("第%s个wskey更新失败,pin为%s" % (count, wspin))
                            else:
                                if insert(ptck):
                                    printf("第%s个wskey添加成功" % count)
                                else:
                                    printf("第%s个wskey添加失败" % count)
                    except:
                        printf("第%s个wskey出现异常错误" % count)
                    count += 1
        else:
            printf("有一个wskey被禁用了")
