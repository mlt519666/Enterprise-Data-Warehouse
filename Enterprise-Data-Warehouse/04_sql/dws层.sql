-- dws层
CREATE TABLE IF NOT EXISTS dws_user_funnel (
stat_date DATE,
view_users INT,
cart_users INT, 
pay_users INT
);

INSERT INTO dws_user_funnel (stat_date, view_users, cart_users, pay_users)
SELECT 
    stat_date,
    -- 浏览人数：包含所有有行为的人
    COUNT(DISTINCT user_id) AS view_users,
    -- 加购人数：找出有加购、或者有支付的用户
    COUNT(DISTINCT CASE WHEN action_type IN (2, 3) THEN user_id END) AS cart_users,
    -- 支付人数：只找有支付的用户
    COUNT(DISTINCT CASE WHEN action_type = 3 THEN user_id END) AS pay_users
FROM (
    -- 聚合出每天每个用户的行为
    SELECT DATE(event_time) AS stat_date, user_id, MAX(action_type) AS action_type
    FROM ods_log
    GROUP BY DATE(event_time), user_id
) t
GROUP BY stat_date;

-- 2. 创建销售日报表并插入数据
CREATE TABLE IF NOT EXISTS dws_daily_sales (
sale_date DATE, 
order_count INT,
total_amount DECIMAL(15,2)
);

INSERT INTO dws_daily_sales (sale_date, order_count, total_amount)
SELECT DATE(create_time), COUNT(order_id), SUM(amount)
FROM ods_order GROUP BY DATE(create_time);