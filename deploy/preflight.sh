#!/usr/bin/env bash
# 安装自检 9 项：通过 / 警告 / 失败 + 一句话怎么修
set -u
PASS=0; WARN=0; FAIL=0
report() {
  local level="$1"; local name="$2"; local msg="$3"
  echo "[$level] $name — $msg"
  case "$level" in
    通过) PASS=$((PASS+1));;
    警告) WARN=$((WARN+1));;
    失败) FAIL=$((FAIL+1));;
  esac
}

echo "=== myBI preflight $(date '+%F %T') ==="

# 1 JDK
if command -v java >/dev/null 2>&1; then
  ver=$(java -version 2>&1 | head -n1)
  if echo "$ver" | grep -Eq 'version "1[7-9]|version "[2-9][0-9]'; then
    report "通过" "JDK" "$ver"
  else
    report "失败" "JDK" "需要 17+，当前: $ver。请设置 JAVA_HOME 到 JDK 17"
  fi
else
  report "失败" "JDK" "未找到 java。请安装 JDK 17 并加入 PATH"
fi

# 2 端口 8080
if command -v ss >/dev/null 2>&1; then
  if ss -lnt | grep -q ':8080'; then
    report "失败" "端口8080" "已被占用。改 --server.port 或结束占用进程"
  else
    report "通过" "端口8080" "空闲"
  fi
elif command -v netstat >/dev/null 2>&1; then
  if netstat -an 2>/dev/null | grep -Eq '[\.:]8080 .*LISTEN'; then
    report "失败" "端口8080" "已被占用"
  else
    report "通过" "端口8080" "空闲（netstat）"
  fi
else
  report "警告" "端口8080" "无法检测（无 ss/netstat），请人工确认"
fi

# 3 磁盘
root_free_kb=$(df -Pk . 2>/dev/null | awk 'NR==2{print $4}')
if [[ -n "${root_free_kb:-}" ]]; then
  free_gb=$((root_free_kb/1024/1024))
  if (( free_gb >= 2 )); then
    report "通过" "磁盘" "可用约 ${free_gb}G"
  else
    report "失败" "磁盘" "可用 <2G。请清理磁盘或换安装目录"
  fi
else
  report "警告" "磁盘" "无法检测 df"
fi

# 4 内存
if [[ -r /proc/meminfo ]]; then
  mem_kb=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
  mem_mb=$((mem_kb/1024))
  if (( mem_mb >= 1024 )); then
    report "通过" "内存" "可用约 ${mem_mb}MB"
  else
    report "警告" "内存" "可用约 ${mem_mb}MB，建议 ≥1GB"
  fi
else
  report "警告" "内存" "非 Linux 或无法读 /proc/meminfo"
fi

# 5 data 目录可写
mkdir -p data 2>/dev/null || true
if touch data/.preflight_write 2>/dev/null; then
  rm -f data/.preflight_write
  report "通过" "数据目录" "data/ 可写"
else
  report "失败" "数据目录" "data/ 不可写。检查权限与磁盘只读挂载"
fi

# 6 元库形态（默认 SQLite；可选探测 MySQL）
if [[ -n "${MYBI_META_MYSQL_URL:-}" ]]; then
  if command -v mysql >/dev/null 2>&1; then
    report "警告" "元库MySQL" "已设置 MYBI_META_MYSQL_URL，请人工确认 utf8mb4 与权限"
  else
    report "警告" "元库MySQL" "无 mysql 客户端，跳过版本/字符集探测"
  fi
else
  report "通过" "元库" "默认 SQLite（无需预装数据库）"
fi

# 7 业务库（可选）探测
if [[ -n "${MYBI_BIZ_MYSQL_HOST:-}" ]]; then
  if command -v mysql >/dev/null 2>&1; then
    cs=$(mysql -h"$MYBI_BIZ_MYSQL_HOST" -P"${MYBI_BIZ_MYSQL_PORT:-3306}" -u"${MYBI_BIZ_MYSQL_USER:-root}" -p"${MYBI_BIZ_MYSQL_PASS:-}" -N -e "SELECT DEFAULT_CHARACTER_SET_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=DATABASE();" 2>/dev/null || true)
    if [[ "$cs" == "utf8mb4" ]]; then
      report "通过" "业务库字符集" "utf8mb4"
    elif [[ -n "$cs" ]]; then
      report "失败" "业务库字符集" "当前=$cs。执行: ALTER DATABASE \`库名\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    else
      report "警告" "业务库字符集" "连不上或无权限，请检查账号"
    fi
  else
    report "警告" "业务库" "未安装 mysql 客户端，跳过"
  fi
else
  report "通过" "业务库" "未配置探测（安装后在系统内配置数据源即可）"
fi

# 8 时区
tz=$(date +%z 2>/dev/null || echo "")
if [[ "$tz" == "+0800" ]]; then
  report "通过" "时区" "+0800"
else
  report "警告" "时区" "当前=$tz。建议服务器设为 Asia/Shanghai（应用已默认 Asia/Shanghai）"
fi

# 9 防火墙 / 外网可达性提示
report "警告" "防火墙" "请确认安全组/防火墙放行 8080（或你的对外端口）；本机无法代你改云厂商规则"

echo "=== 汇总: 通过=$PASS 警告=$WARN 失败=$FAIL ==="
if (( FAIL > 0 )); then
  echo "存在失败项，请修复后再安装。"
  exit 1
fi
echo "可以继续安装。"
exit 0
