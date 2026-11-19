# myBI Starter

myBI 的集成示例仓库（[Apache-2.0](./LICENSE)）。

这里只有建库脚本、示例数据、部署骨架和嵌入样例，**没有**引擎源码。引擎是单独的商业产品；社区安装包或商业授权请从产品渠道获取。

类似「产品本体私有、示例公开」的拆法，和不少国产交付型工具一样：先让你把库和 SQL 跑通，再决定要不要上引擎。

## 有什么

| 目录 | 内容 |
|---|---|
| `schema/` | 中间库参考表结构 |
| `examples/` | 示例数据 / SQL |
| `deploy/` | 部署与检查脚本 |
| `docs/` | 部署、参数说明 |
| `client/` | 简单 iframe 嵌入页 |

## 怎么用

```bash
git clone https://github.com/dahaoqiu/mybi-starter.git
cd mybi-starter
# 按 docs 建库、导 examples，再用 myBI 引擎连上该库
```

参数常见写法：`${name}`、`${name:like}`、`${name:in}`、`/*IF name*/ ... /*END*/`。

## 和引擎的关系

| | 本仓库 | myBI 引擎 |
|---|---|---|
| 内容 | 脚本与文档 | 设计器、导出、权限、AI 等 |
| 许可 | Apache-2.0 | 商业授权 / 社区二进制条款 |
| 能否当产品用 | 不能单独当报表系统 | 可以 |

本仓里的文件可以按 Apache-2.0 商用（例如参考 `schema/` 建自己的库）。这不等于可以免费使用或转售引擎。品牌与 Logo 见 [TRADEMARKS.md](./TRADEMARKS.md)。

## 授权与联系

社区版可自用（保留品牌）。白标、嵌入、OEM 等需要商业授权。

邮箱 / 微信：待填写。

更完整的产品介绍见 [PROJECT-INTRO.md](./PROJECT-INTRO.md)（若仓库中已同步）。
