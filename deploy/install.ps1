# Windows 安装：解压后在包根目录执行
# powershell -ExecutionPolicy Bypass -File .\install.ps1
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host "[myBI] install root = $Root"

# preflight
$pre = Join-Path $Root "preflight.ps1"
if (Test-Path $pre) {
  & $pre
  if ($LASTEXITCODE -ne 0) { throw "preflight 未通过" }
}

if (-not $env:JAVA_HOME) {
  foreach ($c in @("D:\tools\jdk-17", "C:\Program Files\Java\jdk-17", "C:\Program Files\Eclipse Adoptium\jdk-17*")) {
    $hit = Get-Item $c -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) { $env:JAVA_HOME = $hit.FullName; break }
  }
}
if (-not $env:JAVA_HOME) { throw "请设置 JAVA_HOME 为 JDK 17" }
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
$jv = & java -version 2>&1 | Select-Object -First 1
Write-Host "[myBI] java = $jv"

New-Item -ItemType Directory -Force -Path data, conf, logs, license, backup, web | Out-Null
if (-not (Test-Path "conf\application-local.yml")) {
  @"
mybi:
  data-dir: ./data
spring:
  profiles:
    active: sqlite
"@ | Set-Content -Path "conf\application-local.yml" -Encoding UTF8
}

$jar = Get-ChildItem -Path $Root -Filter "backend.jar" -ErrorAction SilentlyContinue
if (-not $jar) { $jar = Get-ChildItem -Path $Root -Filter "report-*.jar" | Select-Object -First 1 }
if (-not $jar) { throw "缺少 backend.jar" }

# 停旧进程
if (Test-Path "mybi.pid") {
  $old = Get-Content "mybi.pid" -ErrorAction SilentlyContinue
  if ($old) { Stop-Process -Id ([int]$old) -Force -ErrorAction SilentlyContinue }
}

$args = @(
  "-jar", $jar.FullName,
  "--spring.profiles.active=sqlite",
  "--spring.config.additional-location=optional:file:./conf/",
  "--mybi.data-dir=./data",
  "--server.port=8080"
)
$p = Start-Process -FilePath "java" -ArgumentList $args -WorkingDirectory $Root -RedirectStandardOutput "logs\boot.log" -RedirectStandardError "logs\boot.err.log" -PassThru -WindowStyle Hidden
$p.Id | Set-Content "mybi.pid"
Write-Host "[myBI] started pid=$($p.Id)"
Write-Host "[myBI] 日志: $Root\logs\boot.log"
Write-Host "[myBI] 默认账号 admin / admin123 （请立即改密）"
Write-Host "[myBI] 健康: 稍后访问 http://127.0.0.1:8080 或调用 /v1/auth/login"
