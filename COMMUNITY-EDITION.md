# 社区版 vs 商业版（对齐 DataEase 模式）

> 目标：**下载就能用、企业可内网自用**；赚钱靠 **品牌锁 + X-Pack 功能 + 原厂支持**，不靠「禁止一切商用」。

---

## 1. 产品分层（DataEase 同构）

| 能力 | 社区版（免费） | 专业版 | OEM / 企业版 |
|---|---|---|---|
| 价格 | **永久免费** | 按套授权 | 按套 / 渠道 |
| 私有化部署 | ✅ | ✅ | ✅ |
| 用户数 | **20** | 合同约定 | 合同约定 |
| 原生 SQL 数据集 + 参数引擎 | ✅ | ✅ | ✅ |
| 报表设计器 / PDF·Excel 导出 | ✅ | ✅ | ✅ |
| 定时任务 | ✅ | ✅ | ✅ |
| **AI 问数（L1 认证 + L2 探索）** | ✅ | ✅ | ✅ |
| 行级权限 RLS | ❌ | ✅ | ✅ |
| 审计日志 / 诊断包 | ❌ | ✅ | ✅ |
| 嵌入（iframe / SSO / API） | ❌ | ✅ | ✅ |
| **白标（换品牌 / Logo）** | ❌ **禁止** | ✅ | ✅（核心卖点） |
| 行业认证问句包 | 可选自建 | 另购加速包 | 另购 / 定制 |
| 原厂支持 | 社区文档 | 邮件 / 工单 | 二线 + SLA |
| 改名后转售 / 二开闭源交付 | ❌ | 需商业条款 | ✅ OEM 合同 |

**官方口径（学 DataEase）：**

- 公司内部装社区版做报表 → **可以**；
- 二开后换皮拿去卖 / 嵌进收费产品 → **不行**，买专业版或 OEM；
- 社区版**必须保留 myBI 品牌与版权信息**（见 `TRADEMARKS.md`）。

---

## 2. 无 license.json 时的默认行为

启动时若找不到 `license/license.json`，进入 **COMMUNITY** 模式：

| 项 | 值 |
|---|---|
| `edition` | `community` |
| `maxUsers` | 20 |
| `features` | `["ai"]` |
| `watermark` | false |
| `allowWrite` | true |
| 有效期 | 永久（至 2099） |

商业 License 用 `features[]` 解锁：`whiteLabel` / `rls` / `audit` / `embed` / `ai`（可叠加）。

签发示例：

```text
java -cp backend.jar com.mybi.report.license.LicenseCli \
  --customer 某某公司 --edition pro --env prod --maxUsers 50 \
  --expireAt 2027-12-31 \
  --features ai,rls,audit,embed,whiteLabel \
  --out license.json
```

---

## 3. 技术闸（按优先级）

| # | 限制 | 实现 | 现状 |
|---|---|---|---|
| 1 | 功能闸 `features[]` | `LicenseService.hasFeature` / `assertFeature` | ✅ |
| 2 | 白标入口置灰 | 系统设置「外观/品牌」无 `whiteLabel` 不可编辑 | ✅ |
| 3 | 席位上限 | `assertCanAddUser` | ✅ |
| 4 | 机器码绑定 | 商业 License 可选 | ✅ |
| 5 | 过期只读 | 商业 License 到期 → READ_ONLY | ✅ |
| 6 | 商标 / Logo | 社区版禁止去品牌分发 | 条款 + TRADEMARKS |

> 内网离线照样能用社区版；**不靠联网心跳**。防「白嫖卖货」靠品牌条款 + 白标收费，不靠把客户锁死。

---

## 4. 话术对照

| 客户问 | 回答 |
|---|---|
| 能下载自己装吗？ | 能，社区版永久免费。 |
| 公司内网做经营报表可以吗？ | 可以，保留 myBI 品牌即可。 |
| 能不能改成我们的名字给客户？ | 不能，需 OEM / 专业版白标。 |
| 能不能嵌进我们的 SaaS 收费？ | 需嵌入 + 商业授权。 |
| AI 社区版有吗？ | 有。L1 认证问句 + L2 探索；模型自备（Ollama / BYOK）。 |

---

## 5. 一句话

> **社区版让人敢装、敢用；专业版/OEM 卖换皮、嵌入、权限与支持。**  
> 这与 DataEase「GPLv3 + 禁改 Logo + X-Pack」是同一类商业模型，只是 myBI 引擎本体仍走商业二进制分发，公开仓是 starter 示例。
