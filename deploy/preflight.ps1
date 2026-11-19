# 安装自检 9 项（Windows）
$Pass = 0; $Warn = 0; $Fail = 0
function Report([string]$Level, [string]$Name, [string]$Msg) {
  Write-Host "[$Level] $Name — $Msg"
  switch ($Level) {
    "通过" { $script:Pass++ }
    "警告" { $script:Warn++ }
    "失败" { $script:Fail++ }
  }
}

Write-Host "=== myBI preflight $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="

# 1 JDK
try {
  $v = & java -version 2>&1 | Select-Object -First 1 | Out-String
  if ($v -match 'version "1[7-9]|version "[2-9][0-9]') {
    Report "通过" "JDK" $v.Trim()
  } else {
    Report "失败" "JDK" "需要 17+，当前: $($v.Trim())。请设 JAVA_HOME=D:\tools\jdk-17"
  }
} catch {
  Report "失败" "JDK" "未找到 java"
}

# 2 端口
$busy = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
if ($busy) {
  $pids = ($busy | Select-Object -ExpandProperty OwningProcess -Unique) -join ","
  Report "失败" "端口8080" "已被占用 PID=$pids。结束进程或改 --server.port"
} else {
  Report "通过" "端口8080" "空闲"
}

# 3 磁盘
$drive = (Get-Item .).PSDrive.Name
$freeGB = [math]::Round((Get-PSDrive $drive).Free / 1GB, 1)
if ($freeGB -ge 2) { Report "通过" "磁盘" "可用约 ${freeGB}G" }
else { Report "失败" "磁盘" "可用 <2G。请清理磁盘" }

# 4 内存
$os = Get-CimInstance Win32_OperatingSystem
$freeMB = [math]::Round($os.FreePhysicalMemory / 1024, 0)
if ($freeMB -ge 1024) { Report "通过" "内存" "可用约 ${freeMB}MB" }
else { Report "警告" "内存" "可用约 ${freeMB}MB，建议 ≥1GB" }

# 5 data 可写
New-Item -ItemType Directory -Force -Path data | Out-Null
try {
  $probe = Join-Path "data" ".preflight_write"
  Set-Content -Path $probe -Value "ok" -ErrorAction Stop
  Remove-Item $probe -Force
  Report "通过" "数据目录" "data/ 可写"
} catch {
  Report "失败" "数据目录" "data/ 不可写：$($_.Exception.Message)"
}

# 6 元库
Report "通过" "元库" "默认 SQLite（无需预装数据库）"

# 7 业务库（可选环境变量）
if ($env:MYBI_BIZ_MYSQL_HOST) {
  Report "警告" "业务库" "已设置 MYBI_BIZ_MYSQL_HOST，请用客户端确认 utf8mb4 与账号权限"
} else {
  Report "通过" "业务库" "未配置探测（安装后在系统内配置数据源）"
}

# 8 时区
$tz = [TimeZoneInfo]::Local.DisplayName
if ($tz -match "中国|China|Beijing|台北|\+08") { Report "通过" "时区" $tz }
else { Report "警告" "时区" "当前=$tz。应用默认 Asia/Shanghai" }

# 9 防火墙
Report "警告" "防火墙" "请在 Windows 防火墙/安全组放行 8080（或对外端口）"

Write-Host "=== 汇总: 通过=$Pass 警告=$Warn 失败=$Fail ==="
if ($Fail -gt 0) {
  Write-Host "存在失败项，请修复后再安装。"
  exit 1
}
Write-Host "可以继续安装。"
exit 0
