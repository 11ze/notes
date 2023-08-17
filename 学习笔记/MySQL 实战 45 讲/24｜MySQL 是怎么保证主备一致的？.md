---
title: 24｜MySQL 是怎么保证主备一致的？
tags:
  - MySQL
createdAt: 2023-05-17T21:20:58+08:00
updatedAt: 2023-08-17T14:25:24+08:00
---

本章的内容是所有 MySQL 高可用方案的基础

## 将备库设置为只读模式（readonly）

1. 防止误操作
2. 防止切换逻辑有 bug，比如切换过程中出现双写造成主备不一致
3. 可以用 readonly 状态判断节点的角色
4. readonly 设置对超级权限用户（super）无效，用于同步更新的线程拥有超级权限

## 一个 update 语句在节点 A 执行，然后同步到节点 B 的完整流程图。（主备同步内部流程）

- ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-24-1.png)

- 主备关系由备库指定
- 搭建完成后由主库决定“要发数据给备库”

## 一个事务日志同步的完整过程（基于长连接）

- 1. 在备库 B 通过 change master 命令设置主库 A 的 IP、端口、用户名、密码，以及从哪个位置开始请求 binlog，这个位置包含文件名和日志偏移量
- 2. 在备库 B 上执行 start slave 命令，这时候备库会启动两个线程，就是图中的 io_thread 和 sql_thread。其中 io_thread 负责与主库建立连接。
- 3. 主库 A 校验完用户名、密码后，开始按照备库 B 传过来的位置，从本地读取 binlog，发给 B。
- 4. 备库 B 拿到 binlog 后，写到本地文件，称为中转日志（relay log）。
- 5. sql_thread 读取中转日志，解析出日志里的命令，并执行。
  - 后来由于多线程复制方案的引入，sql_thread 演化成为了多个线程跟本章讲的原理没有直接关系

## binlog 的三种格式对比（建议设置为 row）

- statement
  - 记录 SQL 原文
    - unsafe 的，比如一个 delete 语句，在主库跟在备库的执行结果可能不一样
      - 有些语句执行依赖上下文，比如会有 SET TIMESTAMP=时间戳 用来设置接下来的 now() 函数的返回时间
  - 比如带了 limit，在主备上用到了不同的索引
  - ⚠️ 可能导致数据不一致
- raw
  - 记录变更前和变更后的数据或被删的数据，是安全的
  - 很占空间
- mixed = statement + row
  - MySQL 自己判断执行的语句应该使用哪种格式的日志
  - 用得不多

## 查看 binlog

- 首先通过 show variables like 'log_%' 查看 log_bin 参数是否为 ON
  - mysql> show binary logs; 获取binlog文件列表
  - mysql> show binlog events; 只查看第一个binlog文件的内容
  - mysql> show binlog events in 'mysql-bin.000001'; # 查看指定 binlog 文件的内容
  - mysql> show master status；查看当前正在写入的 binlog 文件
- 需要借助 mysqlbinlog 工具，用下面这个命令解析和查看 binlog 中的内容
  - 比如事务的 binlog 是从 8900 这个位置开始，可以用 start-position 参数来指定从这个位置的日志开始解析
    - `mysqlbinlog -vv data/master.000001 --start-position=8900;`

## 越来越多的场景要求把格式设置为 row，最直接的好处是可以恢复数据

- delete 语句
  - 记录被删的数据
- insert 语句
  - 把语句转成 delete 执行即可
- update 语句
  - binlog 记录修改前和修改后的整行数据
  - 对调两行信息再到数据库里面执行即可
- MariaDB 的 [Flashback](https://mariadb.com/kb/en/flashback/) 工具基于上面的原理回滚数据
  - 前提：
    - binlog_format=row
    - binlog_row_image=FULL
- 标准做法
  - 1. 用 mysqlbinlog 工具解析出来
  - 2. 把解析结果整个发给 MySQL 执行
  - 类似于：将 master.000001 文件从第 2738 字节到第 2973 字节中间这段内容解析出来，放到 MySQL 去执行。
    - mysqlbinlog master.000001 --start-position=2738 --stop-position=2973 | mysql -h127.0.0.1 -P13000 -uuser -ppwd;

## 循环复制问题

- 实际生产上使用比较多的是双 M 结构（互为主备）
  - 相比于主从，在切换时不用修改主备关系

- 业务逻辑在节点 A 上更新了一条语句，然后再把生成的 binlog 发给节点 B，节点 B 执行完这条更新语句后也会生成 binlog。（我建议你把参数 log_slave_updates 设置为 on，表示备库执行 relay log 后生成 binlog）。

- 解决（在某些场景下还是有可能出现死循环，看下一章）
  1. 规定两个库的 server id 必须不同
  2. 一个备库接到 binlog 并重放时，生成与原 binlog 的 server id 相同的新的 binlog
  3. 每个库在收到从自己的主库发过来的日志后，先判断 server id

## 思考题

- 什么场景下会出现循环复制？

- 一种场景是，在一个主库更新事务后，用命令 set global server_id=x 修改了 server_id。等日志再传回来的时候，发现 server_id 跟自己的 server_id 不同，就只能执行。
- 三个 M
  - 可以通过暂时修改 server id 解决
  - 但出现循环复制时应该考虑是不是数据本身已经失去可靠性

## 评论区

- binlog 准备写到 binlog file 时都会先判断写入后是否超过设置的 max_binlog_size 值如果超过，rotate 自动生成下一个 binlog file 记录这条 binlog 信息
  - 一个事务的 binlog 日志不会被拆到两个 binlog 文件，所以会等到日志写完才 rotate，所以可以看到超过配置大小上限的 binlog 文件

- 如果一张表并没有主键，插入的一条数据和这张表原有的一条数据所有字段都是一样的，然后对插入的这条数据做恢复，会不会把原有的那条数据删除？

  - 会删除一条，有可能删除到之前的那条
  - 因为表没有主键的时候，binlog 里面就不会记录主键字段，即：binlog 不会记录 InnoDB 隐藏的主键 id 字段

- 如果“redo 没有及时刷盘，binlog 刷盘了”之后瞬间数据库所在主机掉电，主机重启，MySQL 重启以后，这个事务会丢失；会引起日志和数据不一致，这也是要默认设置双 1 的原因之一
- 主库 ssd，备库机械硬盘，此时可以试试备库非双 1
- 联表一般在业务层面进行
