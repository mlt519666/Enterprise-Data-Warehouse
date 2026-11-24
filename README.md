模拟企业级数仓建模、增量ETL调度与数据质量监控平台


## 项目简介

本项目是一套完整的模拟数据仓库与ETL实战平台。从底层环境搭建、海量数据生成，到ETL增量抽取、数仓分层建模，再到最终的BI商业可视化，实现了数据全生命周期的流转。



## 技术架构

* 基础设施：阿里云 ECS、Linux、Docker、MySQL 8.0

* 数据生成：Python (Faker)、Java (Spring Boot API)

* ETL工具：Kettle (Spoon, Job)

* BI可视化：Power BI 



## 核心亮点

1. 海量数据接入：Python 生成 100万+ 订单与 5万客户数据；Java 接口提供实时 JSON 日志流。

2. 增量抽取机制：基于 `update\_time` 时间戳“水印”，利用 Kettle 仅抽取 T+1 日变更数据。

3. 数仓分层与拉链表：基于 MySQL 搭建 ODS->DWD->DWS 架构。在 DWD 层设计拉链表，完美追踪客户地址变更的历史状态。

4. 数据质量监控：Kettle 链路中嵌入过滤节点，对空值主键进行实时拦截与告警。

5. BI 商业大屏：Power BI 直连数仓，实现销售趋势、活跃客户与用户转化漏斗的动态展示。



## 目录结构

* 01_python：百万级源数据造数脚本

* 02_java_api：Spring Boot 实时日志接口源码

* 03_kettle：全量与增量 ETL 转换文件 (.ktr)

* 04_sql：数仓建表与拉链表核心 SQL 脚本

* 05_powerbi：BI 仪表盘效果截图



## 快速部署

1. 部署 MySQL 与 Java 环境。

2. 运行 Python 脚本生成测试数据。

3. 使用 Kettle 运行 .ktr文件进行数据抽取。

4. 在 Navicat 中执行 04_sql下的脚本完成数仓加工。

5. 使用 Power BI 连接 MySQL 即可查看报表。

