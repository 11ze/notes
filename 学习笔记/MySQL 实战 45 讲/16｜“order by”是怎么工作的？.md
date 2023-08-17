---
title: 16｜“order by”是怎么工作的？
tags:
  - MySQL
createdAt: 2023-05-17T20:29:49+08:00
updatedAt: 2023-08-17T14:25:36+08:00
---

- MySQL 会给每个线程分配一块内存用于排序，称为 sort_buffer
- `select city,name,age from t where city='杭州' order by name limit 1000;`

  - `city varchar 16，name varchar 16，age int 11`，city 有索引
  - 1. 初始化 sort_buffer，确定放入 name、city、age 这三个字段；
  - 2. 从索引 city 找到第一个满足 `city='杭州'` 条件的主键 id；
  - 3. 到主键 id 索引取出整行，取 name、city、age 三个字段的值，存入 sort_buffer 中；
  - 4. 从索引 city 取下一个记录的主键 id；
  - 5. 重复步骤 3、4 直到 city 的值不满足查询条件为止；
  - 6. 对 sort_buffer 中的数据按照字段 name 做快速排序；

    - 可能在内存中完成，也可能需要使用外部排序，这取决于排序所需的内存和参数 sort_buffer_size。

  - 7. 按照排序结果取前 1000 行返回给客户端。
  - 全字段排序
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-16-1.png)

- sort_buffer_size，是 MySQL 为排序开辟的内存（sort_buffer）的大小。如果要排序的数据量小于 sort_buffer_size，排序就在内存中完成。但如果排序数据量太大，内存放不下，则不得不利用磁盘临时文件辅助排序。
- 确定一个排序语句是否使用了临时文件

```SQL
/* 打开 optimizer_trace，只对本线程有效 */
SET optimizer_trace='enabled=on';

/* @a 保存 Innodb_rows_read 的初始值 */
select VARIABLE_VALUE into @a from  performance_schema.session_status where variable_name = 'Innodb_rows_read';

/* 执行语句 */
select city, name,age from t where city='杭州' order by name limit 1000;

/* 查看 OPTIMIZER_TRACE 输出 */
SELECT * FROM `information_schema`.`OPTIMIZER_TRACE`\G

/* @b 保存 Innodb_rows_read 的当前值 */
select VARIABLE_VALUE into @b from performance_schema.session_status where variable_name = 'Innodb_rows_read';

/* 计算 Innodb_rows_read 差值 */
select @b-@a;
```

- 外部排序时，一般使用归并排序算法
- 如果 MySQL 认为排序的单行长度太大会怎么做呢？

  - max_length_for_sort_data，在 MySQL 中控制用于排序的行数据的长度。如果单行的长度超过这个值，MySQL 就认为单行太大，要换一个算法。

    - 如果只算 rowid 还是小于此设置，一样是 rowid 排序，但是会转用磁盘排序

  - 设置值为 16，小于前面查询语句排序的三个字段的总和
  - 此时因为无法直接返回了，整个执行流程变成下面的样子
  - 1. 初始化 sort_buffer，确定放入两个字段，即 name 和 id；
  - 2. 从索引 city 找到第一个满足 `city='杭州'` 条件的主键 id；
  - 3. 到主键 id 索引取出整行，取 name、id 这两个字段，存入 sort_buffer 中；
  - 4. 从索引 city 取下一个记录的主键 id；
  - 5. 重复步骤 3、4 直到不满足 `city='杭州'` 条件为止；
  - 6. 对 sort_buffer 中的数据按照字段 name 进行排序；
  - 7. 遍历排序结果，取前 1000 行，并按照 id 的值回到原表中取出 city、name 和 age 三个字段返回给客户端。

    - 不需要在服务端再耗费内存存储结果，直接返回给客户端

  - rowid 排序
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-16-2.png)

- 全字段排序 VS rowid 排序

  - MySQL 的一个设计思想：如果内存够，就要多利用内存，尽量减少磁盘访问。
  - 对于 InnoDB 表来说，rowid 排序会要求回表多造成磁盘读，因此不会被优先选择。

- 如果数据天然有序，则 order by 并不需要上面的排序操作，会执行快很多

  - 比如将 city 索引改成 city + name 的联合索引

- 如果建立三个字段的联合索引，还能省去回表过程

  - Explain 结果的 Extra 字段如果有 Using index 则表示使用了覆盖索引
  - 回表的操作是随机 IO，会造成大量的随机读，不一定比全字段排序对磁盘的访问少

## 思考题

- 假设你的表里面已经有了 city_name(city, name) 这个联合索引，然后你要查杭州和苏州两个城市中所有的市民的姓名，并且按名字排序，显示前 100 条记录。如果 SQL 查询语句是这么写的 ：
- `mysql> select * from t where city in ('杭州',"苏州") order by name limit 100;`
- 这个语句执行的时候会有排序过程吗，为什么？
  - 有，单个 city 内部的 name 才是递增的
- 如果业务端代码由你来开发，需要实现一个在数据库端不需要排序的方案，你会怎么实现呢？
  - 分成两个查询语句分别查一百条，然后在业务代码中合并查询结果
- 进一步地，如果有分页需求，要显示第 101 页，也就是说语句最后要改成 “limit 10000,100”， 你的实现方法又会是什么呢？
  - `select * from t where city="杭州" order by name limit 10100; select * from t where city="苏州" order by name limit 10100。`
    - 数据量太大时可以把 * 改写成只返回必要的数据

## 评论区

- varchar(n)，n 的值中，255 是个边界，小于等于 255 需要一个字节记录长度，超过就需要两个字节
- 排序相关的内存在排序后就会被释放
- 假设给一行的 a 值加 1，执行器先找引擎取行，此时已经加了写锁
- 引擎内部自己调用，读取行，不加扫描行数

  - 对于 using index condition 的场景，执行器只调用了一次查询接口，回表是由存储层来完成的，所以扫描行数只算一次，即只算走索引搜索的过程中扫描的行数。
  - 加索引的时候，要扫描全表，但如果是inplace DDL（[[13｜为什么表数据删掉一半，表文件大小不变？]]），你会看到扫描行数是 0，也是因为这些扫描动作都是引擎内部自己调用的。

- Using where 包含了一个“值比较”的过程。

  - using index condiction 索引下推
  - using index 索引覆盖
  - using where 代表过滤元组，可以理解为使用了 where
  - using where 和 using index一起出现代表使用了索引过滤数据
