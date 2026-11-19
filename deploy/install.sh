#!/usr/bin/env bash
# 干净机器安装：解压包后在包根目录执行 ./install.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "[myBI] install root = $ROOT"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "缺少命令: $1"; exit 1; }
}

need java
JAVA_VER=$(java -version 2>&1 | head -n1)
echo "[myBI] java = $JAVA_VER"
echo "$JAVA_VER" | grep -Eq 'version "1[7-9]|version "[2-9][0-9]' || {
  echo "需要 JDK/JRE 17+"; exit 1;
}

mkdir -p data conf logs backup web
if [[ ! -f conf/application-local.yml ]]; then
  cat > conf/application-local.yml <<'EOF'
# 本地覆盖（升级永不覆盖此文件）
mybi:
  data-dir: ./data
spring:
  profiles:
    active: sqlite
EOF
  echo "[myBI] wrote conf/application-local.yml"
fi

if [[ ! -f backend.jar ]]; then
  echo "缺少 backend.jar，请先放入安装包根目录"; exit 1
fi

# 首次启动会自动建 SQLite 元库
nohup java -jar backend.jar \
  --spring.profiles.active=sqlite \
  --spring.config.additional-location=optional:file:./conf/ \
  --mybi.data-dir=./data \
  > logs/boot.log 2>&1 &

echo $! > mybi.pid
echo "[myBI] started pid=$(cat mybi.pid)"
echo "[myBI] 日志: $ROOT/logs/boot.log"
echo "[myBI] 默认账号 admin / admin123 （首次登录后请改密）"
echo "[myBI] 健康检查: curl -s http://127.0.0.1:8080/v1/auth/login"
