-- 1. 订单贴源层
CREATE TABLE IF NOT EXISTS ods_order (
    order_id VARCHAR(50),
    user_id INT,
    amount DECIMAL(10,2),
    create_time DATETIME
);

-- 2. 客户贴源层
CREATE TABLE IF NOT EXISTS ods_customer (
    user_id INT,
    user_name VARCHAR(50),
    city VARCHAR(50),
    level VARCHAR(20),
    update_time DATETIME
);

-- 3. 日志贴源层
CREATE TABLE IF NOT EXISTS ods_log (
    log_id VARCHAR(50),
    user_id INT,
    action_type INT,
    event_time DATETIME
);