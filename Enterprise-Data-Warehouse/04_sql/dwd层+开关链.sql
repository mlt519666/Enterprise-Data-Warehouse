-- DWD层
DROP TABLE IF EXISTS dwd_customer_zip;

CREATE TABLE dwd_customer_zip (
    user_id INT COMMENT '用户ID',
    user_name VARCHAR(50) COMMENT '姓名',
    city VARCHAR(50) COMMENT '城市',
    `level` VARCHAR(20) COMMENT '会员等级',
    start_date DATE COMMENT '生效日期',
    end_date DATE COMMENT '失效日期(9999-12-31为当前有效)'
);

-- 初始化环境（测试数据）
-- 确保 ODS 层的 1 号客户初始城市为“重庆市”
UPDATE ods_customer SET city = '重庆市' WHERE user_id = 1;

-- 拉链表全量初始化
INSERT INTO dwd_customer_zip (user_id, user_name, city, `level`, start_date, end_date)
SELECT 
    user_id, 
    user_name, 
    city, 
    `level`, 
    '2023-01-01' AS start_date, 
    '9999-12-31' AS end_date
FROM ods_customer;

-- 业务数据发生变更（T+1 日增量）
-- 从“重庆市”搬家到了“上海市”，源端数据发生变化
UPDATE ods_customer SET city = '上海市', update_time = NOW() WHERE user_id = 1;

-- 关链：把发生变更的老数据标记为昨天失效
UPDATE dwd_customer_zip t1
JOIN ods_customer t2 ON t1.user_id = t2.user_id
SET t1.end_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
WHERE t1.end_date = '9999-12-31' 
  AND (t1.city != t2.city OR t1.level != t2.level);

-- 开链：把 ODS 里的新状态插入拉链表，作为今天起生效的当前记录
INSERT INTO dwd_customer_zip (user_id, user_name, city, `level`, start_date, end_date)
SELECT 
    t2.user_id, 
    t2.user_name, 
    t2.city, 
    t2.level, 
    CURDATE() AS start_date, 
    '9999-12-31' AS end_date
FROM ods_customer t2
LEFT JOIN dwd_customer_zip t1 ON t2.user_id = t1.user_id AND t1.end_date = '9999-12-31'
WHERE t1.user_id IS NULL OR t1.city != t2.city OR t1.level != t2.level;

-- 最终结果查询
SELECT * FROM dwd_customer_zip WHERE user_id = 1;

-- 查当前有效数据（快照）
SELECT * FROM dwd_customer_zip WHERE end_date = '9999-12-31' AND user_id = 1;