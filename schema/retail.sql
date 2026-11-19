-- =============================================================================
-- 零售加速包 · 参考中间库 DDL（可选，非引擎强制模型）
-- 绑定：pack-retail-v1.0.json
-- 规范：projectDoc/商业化/44-中间库建设与三件套交付.md（先读 §0：两层）
-- 口径：projectDoc/商业化/25-语义层字段与指标清单.md
-- 演示造数：packs/validate/01-demo-retail.sql
--
-- 重要：
--   · myBI 主产品不规定客户必须有哪些业务表；实施方按业务自由建表、自由写 SQL。
--   · 本文件仅供「购买/使用零售认证问句包」时对齐依赖，或作演示库模板。
--   · 客户已有表名/列名不同：用包导入映射，不必照搬本 DDL。
--   · 抽数、清洗、调度 = 渠道/客户责任；产品不做 ETL 平台。
-- =============================================================================

SET NAMES utf8mb4;
SET time_zone = '+08:00';

-- 建议：客户自建库名，例如 bi_middle_retail；以下仅示例
-- CREATE DATABASE bi_middle_retail DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE bi_middle_retail;

-- ---------------------------------------------------------------------------
-- 1. 门店维
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_store (
  store_id   VARCHAR(8)  NOT NULL COMMENT '门店编码',
  store_name VARCHAR(64) NOT NULL COMMENT '门店名称',
  region     VARCHAR(16) NOT NULL COMMENT '区域（华东/华北/华南…）',
  city       VARCHAR(32)          COMMENT '城市',
  open_date  DATE                 COMMENT '开业日',
  PRIMARY KEY (store_id),
  KEY idx_region (region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='门店维';

-- ---------------------------------------------------------------------------
-- 2. 商品维
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_product (
  sku_id    VARCHAR(16)   NOT NULL COMMENT 'SKU 编码',
  sku_name  VARCHAR(64)   NOT NULL COMMENT '商品名称',
  category  VARCHAR(32)   NOT NULL COMMENT '品类',
  price     DECIMAL(10,2)          COMMENT '标价（含税参考）',
  cost      DECIMAL(10,2)          COMMENT '成本（毛利用）',
  PRIMARY KEY (sku_id),
  KEY idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品维';

-- ---------------------------------------------------------------------------
-- 3. 销售事实（粒度：日 × 门店 × SKU）
--    amt = 含税销售额；是否已扣退款由数据源保证（见 25 / 44 §2.3）
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fact_sale (
  id         BIGINT        NOT NULL AUTO_INCREMENT,
  dt         DATE          NOT NULL COMMENT '业务日',
  store_id   VARCHAR(8)    NOT NULL COMMENT '门店',
  sku_id     VARCHAR(16)   NOT NULL COMMENT 'SKU',
  qty        INT           NOT NULL COMMENT '销量（件）',
  amt        DECIMAL(12,2) NOT NULL COMMENT '销售额（含税）',
  refund_amt DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '退款金额',
  PRIMARY KEY (id),
  KEY idx_dt_store (dt, store_id),
  KEY idx_dt_sku   (dt, sku_id),
  KEY idx_store_dt (store_id, dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售事实日×店×SKU';

-- ---------------------------------------------------------------------------
-- 4. 月度目标（粒度：月 × 门店；dt = 每月 1 日）
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS plan_target (
  dt         DATE          NOT NULL COMMENT '目标月（每月1日）',
  store_id   VARCHAR(8)    NOT NULL COMMENT '门店',
  target_amt DECIMAL(12,2)          COMMENT '目标销售额',
  PRIMARY KEY (dt, store_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='门店月目标';

-- ---------------------------------------------------------------------------
-- 5. 只读账号模板（按环境改密码；生产务必独立账号）
-- ---------------------------------------------------------------------------
-- CREATE USER 'bi_ro'@'%' IDENTIFIED BY 'CHANGE_ME';
-- GRANT SELECT ON bi_middle_retail.* TO 'bi_ro'@'%';
-- FLUSH PRIVILEGES;

-- ---------------------------------------------------------------------------
-- 6. 建库后自检（手工执行，期望 4 行表 + 索引存在）
-- ---------------------------------------------------------------------------
-- SHOW TABLES;
-- SHOW INDEX FROM fact_sale;
-- SELECT MAX(dt) AS data_as_of FROM fact_sale;
