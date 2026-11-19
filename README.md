# myBI Starter

myBI 的公开入口：集成示例 + **社区版安装包下载**。

- 本仓库里的脚本 / 文档：Apache-2.0  
- 社区版二进制（可运行）：见右侧 **[Releases](https://github.com/dahaoqiu/mybi-starter/releases)**，不含源码  

引擎源码在私有仓；社区版可长期自用，须保留 myBI 品牌。白标、嵌入等需商业授权。

## 先跑起来（社区版）

1. 打开 [Releases](https://github.com/dahaoqiu/mybi-starter/releases)，下载 `mybi-community-1.0.0.zip`
2. 解压，机器需 **JDK 17**
3. 安装：

```powershell
# Windows
.\preflight.ps1
.\install.ps1
```

```bash
# Linux / macOS
chmod +x *.sh
./preflight.sh
./install.sh
```

浏览器打开提示的地址。默认账号 `admin` / `admin123`，装完先改密码。

业务库在系统里自己配（MySQL / SQL Server 等）。元数据默认用包内 SQLite。

## 本仓库还有什么

| 目录 | 用途 |
|---|---|
| `schema/` | 中间库参考表结构（可选） |
| `examples/` | 示例数据 / SQL（可选） |
| `deploy/` | 部署脚本参考 |
| `docs/` | 参数语法、部署说明 |
| `client/` | iframe 嵌入最小示例 |

这些材料方便你建库、写 SQL、对接；**单独 clone 本仓没有引擎 jar，跑不了系统**——请用上面的 Release 包。

参数常见写法：`${name}`、`${name:like}`、`${name:in}`、`/*IF name*/ ... /*END*/`。

## 版本说明

| | 说明 |
|---|---|
| 社区版（Release 包） | 可部署自用，含主功能与 AI 入口；保留品牌 |
| 专业版 / OEM | 白标、嵌入、权限增强等，需授权 |

更多说明：`COMMUNITY-EDITION.md`、`PROJECT-INTRO.md`。品牌规则：`TRADEMARKS.md`。

## 联系

商务邮箱 / 微信：待填写。
