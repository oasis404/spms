#!/bin/bash
# =====================================================================
# SPMS 停止脚本：按端口结束 MySQL / Redis / 后端 / 前端 四个进程
# 用法： bash stop-all.sh
# =====================================================================
export MSYS_NO_PATHCONV=1

kill_port() {
  local port=$1 name=$2
  local pids
  pids=$(netstat -ano 2>/dev/null | grep ":$port " | grep LISTENING | awk '{print $NF}' | sort -u)
  if [ -z "$pids" ]; then
    echo "  $name (端口 $port) 未在运行"
    return
  fi
  for pid in $pids; do
    taskkill /PID "$pid" /F > /dev/null 2>&1 && echo "  $name (端口 $port, PID $pid) 已停止"
  done
}

echo "==================== SPMS 停止 ===================="
kill_port 3000 "前端 Vite"
kill_port 8080 "后端 Spring Boot"
kill_port 3306 "MySQL"
kill_port 6379 "Redis"
echo "=================================================="
