#!/bin/bash

# 使用pgrep检查lucky进程是否存在
if ! pgrep -x "lucky" > /dev/null; then
  echo "lucky进程不存在，正在启动lucky..."
  # 运行lucky命令，按照你的需求将输出重定向到/dev/null
  /etc/lucky/lucky -c /boot/config/lucky/lucky.conf >/dev/null 2>&1 &
else
  echo "lucky进程已经存在，无需再次启动。"
fi
