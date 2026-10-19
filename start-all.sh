#!/bin/bash
# =====================================================================
# SPMS 一键启动脚本（本机免 Docker / 免安装服务 的便携运行时方案）
# 依次启动：Redis(6379) -> MySQL(3306) -> 后端(8080) -> 前端(3000)
# 用法： bash start-all.sh
# =====================================================================
BASE="C:/Users/Administrator/WorkBuddy/2026-09-10-20-27-04/spms"
RT="$BASE/runtime"
LOGS="$BASE/logs"
mkdir -p "$LOGS" "$BASE/run"

is_listening() {
  netstat -ano 2>/dev/null | grep -q ":$1 .*LISTENING"
}

wait_port() {
  for _ in $(seq 1 "$2"); do
    is_listening "$1" && return 0
    sleep 2
  done
  return 1
}

echo "==================== SPMS 启动 ===================="

# ---------- 1. Redis ----------
if is_listening 6379; then
  echo "[1/4] Redis 已在运行 (6379)"
else
  echo "[1/4] 启动 Redis ..."
  ( cd "$RT/redis" && nohup ./redis-server.exe redis.windows.conf > "$LOGS/redis.log" 2>&1 & )
  wait_port 6379 15 && echo "      Redis OK" || echo "      Redis 启动超时，见 $LOGS/redis.log"
fi

# ---------- 2. MySQL ----------
if is_listening 3306; then
  echo "[2/4] MySQL 已在运行 (3306)"
else
  echo "[2/4] 启动 MySQL ..."
  nohup "$RT/mysql/bin/mysqld.exe" --defaults-file="$RT/my.ini" --console > "$LOGS/mysql.log" 2>&1 &
  wait_port 3306 45 && echo "      MySQL OK" || echo "      MySQL 启动超时，见 $LOGS/mysql.log"
fi

# ---------- 3. 后端 ----------
if is_listening 8080; then
  echo "[3/4] 后端已在运行 (8080)"
else
  echo "[3/4] 启动后端 Spring Boot ..."
  ( cd "$BASE/run" && nohup "$RT/jdk17/bin/java.exe" -Dfile.encoding=UTF-8 \
      -jar "$BASE/SPMS-Server/target/server-4.0.0.jar" \
      --spring.profiles.active=local > "$LOGS/backend.log" 2>&1 & )
  wait_port 8080 90 && echo "      后端 OK" || echo "      后端启动超时，见 $LOGS/backend.log"
fi

# ---------- 4. 前端 ----------
if is_listening 3000; then
  echo "[4/4] 前端已在运行 (3000)"
else
  echo "[4/4] 启动前端 Vite ..."
  ( cd "$BASE/SPMS-Web" && nohup npm run s > "$LOGS/frontend.log" 2>&1 & )
  wait_port 3000 60 && echo "      前端 OK" || echo "      前端启动超时，见 $LOGS/frontend.log"
fi

echo
echo "==================== 启动完成 ===================="
echo "  访问地址 : http://127.0.0.1:3000/login"
echo "  账号     : admin@hamm.cn  /  Aa123456"
echo "  备用账号 : admin@hamm.com /  Aa123456"
echo "  后端接口 : http://127.0.0.1:8080/"
echo "=================================================="
