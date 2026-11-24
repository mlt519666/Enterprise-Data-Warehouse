import pymysql
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker('zh_CN')

# 1. 先连接，不指定 database
conn = pymysql.connect(host='填地址', user='填用户名', password='填对应的密码', autocommit=True)
cursor = conn.cursor()

# 2. 自动创建数据库
cursor.execute("CREATE DATABASE IF NOT EXISTS data_center DEFAULT CHARSET utf8mb4;")
# 3. 切换到该数据库
conn.select_db('data_center')

# 4. 自动创建造数需要的两张表
cursor.execute("""
CREATE TABLE IF NOT EXISTS source_order (
    order_id VARCHAR(50), user_id INT, amount DECIMAL(10,2), create_time DATETIME
);
""")
cursor.execute("""
CREATE TABLE IF NOT EXISTS source_customer (
    user_id INT, user_name VARCHAR(50), city VARCHAR(50), level VARCHAR(20), update_time DATETIME
);
""")

# 清空历史脏数据
cursor.execute("TRUNCATE TABLE source_customer;")
cursor.execute("TRUNCATE TABLE source_order;")

# 5. 造 100 万订单
print("开始生成 100 万订单...")
order_data = []
for i in range(1000000):
    order_time = (datetime.now() - timedelta(days=random.randint(0, 365))).strftime('%Y-%m-%d %H:%M:%S')
    order_data.append((f"ORD_{i}", random.randint(1, 50000), round(random.uniform(10, 2000), 2), order_time))
    
    # 每 10 万条批量提交，防止内存撑爆
    if len(order_data) == 100000:
        cursor.executemany("INSERT INTO source_order (order_id, user_id, amount, create_time) VALUES (%s, %s, %s, %s)", order_data)
        order_data = []
        print(f"已插入订单: {i+1} 条")

# 6. 开始造 5 万客户 (包含最近更新的增量数据)
print("开始生成 5 万客户 (包含增量时间)...")
customer_data = []
for i in range(50000):
    # 前 1000 个用户模拟“最近发生过变更”，用于测试增量抽取
    if i < 1000:
        update_time = (datetime.now() - timedelta(hours=random.randint(1, 24))).strftime('%Y-%m-%d %H:%M:%S')
    else:
        update_time = (datetime.now() - timedelta(days=random.randint(10, 365))).strftime('%Y-%m-%d %H:%M:%S')
    
    level = random.choice(['普通', 'VIP', 'SVIP'])
    customer_data.append((i+1, fake.name(), fake.city(), level, update_time))

cursor.executemany("INSERT INTO source_customer (user_id, user_name, city, level, update_time) VALUES (%s, %s, %s, %s, %s)", customer_data)
conn.commit()

print("造数全部完成")
conn.close()
