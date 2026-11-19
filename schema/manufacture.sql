-- 制造业问句包依赖的表结构（设计稿 v1.0）
-- 用途：实跑验证 / 客户接数时的目标结构；实际实施可映射到客户自己的表，只需视图对齐列名
-- 方言：MySQL 5.7+（演示库可直接执行）

CREATE TABLE dim_workcenter (
  wc_id      VARCHAR(8)  PRIMARY KEY          COMMENT '工作中心/产线编号 WC01',
  wc_name    VARCHAR(64) NOT NULL             COMMENT '产线名称',
  line_name  VARCHAR(32)                      COMMENT '所属车间',
  wc_type    VARCHAR(16)                      COMMENT '类型：装配/加工/包装',
  eq_count   INT          DEFAULT 0           COMMENT '该产线设备数（算稼动率用）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工作中心';

CREATE TABLE dim_product (
  sku_id       VARCHAR(16) PRIMARY KEY        COMMENT '产品编号',
  sku_name     VARCHAR(64) NOT NULL           COMMENT '产品名称',
  product_type VARCHAR(32)                    COMMENT '产品类型：A型/B型/C型',
  std_cost     DECIMAL(12,2)                  COMMENT '标准成本'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品';

CREATE TABLE fact_work_order (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  dt          DATE NOT NULL                   COMMENT '工单日期（统计口径）',
  wo_no       VARCHAR(32) NOT NULL            COMMENT '工单号',
  wc_id       VARCHAR(8)  NOT NULL            COMMENT '产线',
  sku_id      VARCHAR(16) NOT NULL            COMMENT '产品',
  plan_qty    INT NOT NULL                    COMMENT '计划数量',
  actual_qty  INT NOT NULL DEFAULT 0          COMMENT '实际数量',
  plan_start  DATE                            COMMENT '计划开工',
  plan_end    DATE                            COMMENT '计划完工',
  actual_end  DATE                            COMMENT '实际完工（NULL=未完工）',
  status      VARCHAR(16)                     COMMENT '已完成/在制/延期',
  KEY idx_dt (dt),
  KEY idx_wc_dt (wc_id, dt),
  KEY idx_wo (wo_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工单';

CREATE TABLE fact_quality (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  dt           DATE NOT NULL                  COMMENT '检验日期',
  wo_no        VARCHAR(32)                    COMMENT '关联工单',
  wc_id        VARCHAR(8) NOT NULL            COMMENT '产线',
  sku_id       VARCHAR(16) NOT NULL           COMMENT '产品',
  inspect_qty  INT NOT NULL                   COMMENT '检验数量',
  ok_qty       INT NOT NULL                   COMMENT '合格数量',
  defect_qty   INT NOT NULL                   COMMENT '不良数量',
  defect_type  VARCHAR(32)                    COMMENT '缺陷类型：尺寸超差/外观划伤/装配错位/材料缺陷/其他',
  KEY idx_dt (dt),
  KEY idx_wc_dt (wc_id, dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='质量检验';

CREATE TABLE fact_downtime (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  dt           DATE NOT NULL                  COMMENT '停机日期',
  wc_id        VARCHAR(8) NOT NULL            COMMENT '产线',
  equipment_no VARCHAR(32) NOT NULL           COMMENT '设备编号 EQ001',
  start_time   DATETIME                       COMMENT '开始时间',
  end_time     DATETIME                       COMMENT '结束时间',
  minutes      INT NOT NULL                   COMMENT '停机分钟',
  reason       VARCHAR(32)                    COMMENT '原因：设备故障/换型/缺料/待检/计划保养/其他',
  KEY idx_dt (dt),
  KEY idx_eq (equipment_no),
  KEY idx_wc (wc_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='停机记录';

-- 演示数据规模建议（供工程侧实跑用）：
--   产线 6 条 × 产品 40 个 × 180 天
--   fact_work_order ≈ 6 × 40 × 180 / 3 ≈ 1.4 万行
--   fact_quality    ≈ 1.4 万行；fact_downtime ≈ 3 千行
-- 造数要点（避免零售包踩过的坑）：
--   1) actual_qty 必须随产线/产品/日期变化，不能用同一表达式；
--   2) plan_qty 与 actual_qty 要有 ±30% 的偏差，否则达成率恒为 100%；
--   3) defect_qty 按产线给不同基线（如 1%~6%），否则"良率异常"永远无数据；
--   4) downtime 的 reason 要真的分布在 6 个值上，否则占比图只有一类；
--   5) plan_end/actual_end 要有 10%~15% 的延期样本，否则"延期工单"为空。
