#!/bin/bash
# =============================================================
# SPMS 本地构建/运行辅助脚本（免安装 Maven，直接调用 classworlds）
# 用法:
#   ./mvn-local.sh clean package -DskipTests     # 构建
#   ./mvn-local.sh spring-boot:run               # 直接运行
# =============================================================
set -e
export MSYS2_ARG_CONV_EXCL='*'

BASE="/c/Users/Administrator/WorkBuddy/2026-09-10-20-27-04/spms"
JDK="$BASE/runtime/jdk17"
MVN='C:\Users\Administrator\WorkBuddy\2026-09-10-20-27-04\spms\runtime\maven'
PROJ='C:\Users\Administrator\WorkBuddy\2026-09-10-20-27-04\spms\SPMS-Server'

export JAVA_HOME='C:\Users\Administrator\WorkBuddy\2026-09-10-20-27-04\spms\runtime\jdk17'
export PATH="$JDK/bin:$PATH"

exec "$JDK/bin/java.exe" \
  -classpath "$MVN\\boot\\plexus-classworlds-2.8.0.jar" \
  "-Dclassworlds.conf=$MVN\\bin\\m2.conf" \
  "-Dmaven.home=$MVN" \
  "-Dmaven.multiModuleProjectDirectory=$PROJ" \
  org.codehaus.plexus.classworlds.launcher.Launcher "$@"
