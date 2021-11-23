#调度配置 0,1 0 * * 1 python3 /ql/config/doocode.py
from telethon import TelegramClient
import os


current_path = os.path.dirname(os.path.abspath(__file__))
os.chdir(current_path)
client = TelegramClient("bot", "你的APIID", "你的IP秘钥", connection_retries=None).start()

async def main():
    await client.send_message("@JDShareCodebot", "要发送的互助码命令")
    await client.send_message("@JDShareCodebot", "要发送的互助码命令")
    await client.send_message("@JDShareCodebot", "要发送的互助码命令")
    await client.send_message("@JDShareCodebot", "要发送的互助码命令")
    await client.send_message("@JDShareCodebot", "要发送的互助码命令")
    await client.send_message("@JDShareCodebot", "要发送的互助码命令")
    await client.send_message("@JDShareCodebot", "要发送的互助码命令")
    await client.send_read_acknowledge("@JDShareCodebot")


with client:
    client.loop.run_until_complete(main())
