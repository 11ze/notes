---
title: 18｜为什么这些 SQL 语句逻辑相同，性能却差异巨大？
tags:
  - MySQL
createdAt: 2023-05-17T20:43:36+08:00
updatedAt: 2023-08-17T14:25:33+08:00
---

## 案例一：条件字段函数操作

- 原语句：`mysql> select count(*) from tradelog where month(t_modified)=7;`
  - 字段值如：2017-7-1
- 对索引字段做函数操作，可能会破坏索引值的有序性，因此优化器就决定放弃走树搜索功能
- 但是，优化器并不是要放弃使用这个索引，还可以选择遍历主键索引，也可以选择遍历索引 t_modified
- 优化方案：`mysql> select count(*) from tradelog where    -> (t_modified >= '2016-7-1' and t_modified<'2016-8-1') or    -> (t_modified >= '2017-7-1' and t_modified<'2017-8-1') or     -> (t_modified >= '2018-7-1' and t_modified<'2018-8-1');`

## 案例二：隐式类型转换

- `mysql> select * from tradelog where tradeid=110717;`
  - 相当于：`mysql> select * from tradelog where CAST(tradid AS signed int) = 110717;`
- 因为 tradeid 的字段类型是 varchar(32)，输入的参数是整形，所以该语句需要走全表扫描
  - 如果字段是整形，输入是字符串，则可以走索引
- 数据类型转换的规则
- 为什么有数据类型转换就需要走全索引扫描
  - 这条语句触发了我们上面说到的规则：对索引字段做函数操作，优化器会放弃走树搜索功能。

## 案例三：隐式字符编码转换

- 两个表的字符集不同，一个是 utf8，一个是 utf8mb4，所以做表连接查询的时候用不上关联字段的索引
  - utf8mb4 是 utf8 的超集。类似地，在程序设计语言里面，做自动类型转换的时候，为了避免数据在转换过程中由于截断导致数据错误，也都是“按数据长度增加的方向”进行转换的。
  - 例子：`select * from trade_detail where CONVERT(traideid USING utf8mb4)=$L2.tradeid.value;`
- 优化方案
  1. 把两个表的字段的字符集改成 utf8mb4
     - 推荐做法
  2. 如果表数据量太大，或者业务上暂时不能做这个 DDL 的话，只能采用修改 SQL 语句的方法
  - `mysql> select d.* from tradelog l , trade_detail d where d.tradeid=CONVERT(l.tradeid USING utf8) and l.id=2;`

## 案例说明

- 案例都在说同一件事：对索引字段做函数操作，可能会破坏索引值的有序性，因此优化器就决定放弃走树搜索功能。
- 虽然执行过程中可能经过函数操作，但是最终在拿到结果后，server 层还要做一轮判断。

## 评论区

- 表的访问顺序与连接方式、条件字段有关，跟书写顺序无关
  - 可参考《数据库索引设计与优化》第八章的表访问顺序对索引设计的影响
- 先 where，再 order by，最后 limit。
- 字符串都选 utf8mb4
