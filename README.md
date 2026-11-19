# myBI Starter · 集成示例

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](./LICENSE)
[![Edition](https://img.shields.io/badge/engine-commercial-orange.svg)](#与引擎本体的关系)

> **本仓库是集成示例与工具，不是引擎源码。**  
> 引擎本体（后端 + 前端）为**商业软件**，另仓私有维护；此处只放可自由使用的 Schema、示例数据、部署脚本与嵌入示例。

**一句话**：把 SQL 变成可交付报表的私有化制表引擎——示例层开源，引擎商业授权。

---

## 它解决什么问题

给**实施方 / 甲方 IT / 行业 ISV**：客户要的是能交付的报表，不是再上一套 BI 门户。

| 痛点 | myBI 的做法 |
|---|---|
| 手搓报表慢 | SQL 贴进引擎 → 参数面板 → 画布 → 导出 PDF |
| 直连生产不安全 | 建议只读中间库；本仓库提供参考建表脚本 |
| 白标 / 嵌入难 | 商业版支持换品牌与 iframe 嵌入（见 `client/` 最小示例） |

**不是**：大屏设计器、套打/审批流、多租户 SaaS、经营分析产品。

---

## 本仓库有什么（Apache-2.0）

| 目录 | 内容 |
|---|---|
| `schema/` | 中间库参考 DDL（零售 / 制造） |
| `examples/` | 可导入的示例数据 SQL |
| `deploy/` | docker-compose、preflight、安装脚本骨架 |
| `docs/` | 部署手册、参数语法速查、升级说明 |
| `client/` | iframe + token 嵌入最小页 |

引擎二进制与源码**不在**本仓库。获取商业版见下文「商业授权」。

---

## 快速试用（示例数据）

```bash
git clone https://github.com/<你的账号>/mybi-starter.git
cd mybi-starter

# 1) 在 MySQL 执行 schema + examples（按 docs 说明）
# 2) 安装商业版引擎（Release 包），配置只读账号连该库
# 3) 按 docs/参数语法速查.md 建数据集与报表
```

参数写法摘要：`${name}` / `${name:like}` / `${name:in}` / `/*IF name*/ ... /*END*/`。

---

## 与引擎本体的关系

```
mybi-starter（本仓，公开，Apache-2.0）  ← 集成材料
        │
        ▼ 连接 / 嵌入
myBI 引擎（商业授权：二进制或源码授权） ← 调度、权限、白标、设计器、导出…
```

| | Starter | 引擎 |
|---|---|---|
| 许可 | Apache-2.0 | 商业 EULA / 源码授权合同 |
| 能否商用本仓内容 | ✅ | 需授权 |
| 含后端/前端实现 | ❌ | ✅ |

对外话术建议：**「集成示例开源，引擎商业授权」**——不要把核心仓标成 open source。

---

## 商业授权

适用于：项目交付、OEM 白标、企业内部生产经营、SaaS/转售。

- 标准版 / OEM / 源码授权：见销售材料或邮件咨询  
- 联系：`<填写商务邮箱>` · 微信：`<填写>`

试用与正式包通过私有产品页 / Release 分发（含 License 校验）。

---

## 许可

[Apache License 2.0](./LICENSE) —— 可商用、可修改、可再分发，保留版权与许可声明即可。

Apache-2.0 **仅覆盖本仓库内容**，不授予 myBI 引擎任何权利。商标与产品名使用见商业合同与商标声明。

---

## 贡献

欢迎对 Schema、文档、部署脚本、嵌入示例提 Issue / PR。引擎本体不接受对本公开仓的「源码级」贡献路径。
