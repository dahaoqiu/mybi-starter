# 示例数据集（3 条，来自认证问句节选）

> 用途：演示参数写法与"业务问句 → SQL"的对应关系。
> 完整 30 条（零售/制造）属于「行业认证问句包」商业素材，不在本仓库。

---

## 1. 品类销量 TOP5（排名）

```sql
SELECT p.category AS 品类, SUM(s.qty) AS 销量
FROM fact_sale s
JOIN dim_product p ON p.sku_id = s.sku_id
JOIN dim_store st ON st.store_id = s.store_id
WHERE s.dt >= ${startDate} AND s.dt < ${endDate}
  /*IF region*/ AND st.region IN ${region:in} /*END*/
GROUP BY p.category
ORDER BY 销量 DESC
LIMIT 5
```

- 参数：`startDate`(date,必填) `endDate`(date,必填) `region`(multiple,可选)
- 结论模板：`销量最高的是 {{top1.品类}}，共 {{top1.销量}} 件`

---

## 2. 每日销售趋势（趋势）

```sql
SELECT s.dt AS 日期, ROUND(SUM(s.amt),2) AS 销售额
FROM fact_sale s
WHERE s.dt >= ${startDate} AND s.dt < ${endDate}
GROUP BY s.dt
ORDER BY s.dt
```

- 参数：`startDate` `endDate`
- 注意：区间用 `>= AND <`，**不要 BETWEEN**（会漏最后一天）

---

## 3. 连续未达标门店（异常）

```sql
SELECT st.store_name AS 门店, COUNT(*) AS 未达标天数
FROM (
  SELECT s.store_id, s.dt, SUM(s.amt) AS amt
  FROM fact_sale s
  WHERE s.dt >= ${startDate} AND s.dt < ${endDate}
  GROUP BY s.store_id, s.dt
) d
JOIN dim_store st ON st.store_id = d.store_id
JOIN plan_target pt ON pt.store_id = d.store_id
  AND pt.dt = DATE(DATE_FORMAT(d.dt, '%Y-%m-01'))
WHERE d.amt < pt.target_amt / 30.0 * 0.8
GROUP BY d.store_id, st.store_name
HAVING COUNT(*) >= 3
ORDER BY 未达标天数 DESC
```

- 参数：`startDate` `endDate`
- 语义：日销售额低于月目标日均 80% 且连续 ≥3 天

---

## 通用约定

| 写法 | 含义 |
|---|---|
| `${name}` | 单值，走 `?` 绑定 |
| `${name:like}` | 模糊，自动包 `%…%` |
| `${name:in}` | 列表，**模板里不写括号** |
| `/*IF name*/ … /*END*/` | 参数为空则整段删除 |

**只允许单条 SELECT/WITH**；写操作、多语句会被拒绝（E2009/E2008）。
