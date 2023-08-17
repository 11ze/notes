---
title: 12｜为什么我的 MySQL 会“抖”一下？
tags:
  - MySQL
createdAt: 2023-08-17T14:32:34+08:00
updatedAt: 2023-08-17T14:32:34+08:00
---

## 概念

- 脏页：跟磁盘数据页内容不一致的内存数据页
- 干净页：跟磁盘数据页内容一致的内存数据页

## 何时内存中的脏页往硬盘上刷？

1. redo log 满
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-12-1.png)
  - 把绿色部分的日志对应的所有脏页都 flush 到磁盘上
  - 之后，write pos 到 cp' 之间是可以再写入的 redo log 的区域
2. 当需要新的内存页，而内存不够用的时候，就要淘汰一些数据页，空出内存给别的数据页使用。如果淘汰的是“脏页”，就要先将脏页写到磁盘
- 不直接把内存淘汰掉，下次需求请求的时候从磁盘读入数据页，然后拿 redo log 出来应用的原因：为了保证每个数据页有两种状态
    1. 内存里存在，内存里肯定是正确的结果，直接返回；
    2. 内存里没有数据，可以肯定数据文件上是正确的结果，读入内存后返回。
1. MySQL 认为系统“空闲”的时候会刷，忙的时候也会找机会刷
2. 正常关闭数据库时，会把内存的脏页都 flush 到磁盘上，下次启动时直接从磁盘读数据，启动速度快

- 第 2 种情况是常态
  - InnoDB 用缓冲池管理内存，缓冲池中的内存页有三种状态
    1. 还没有使用：很少
    2. 使用了并且是干净页
    3. 使用了并且是脏页。
- 当要读入的数据页没有在内存的时候，必须到缓冲池申请一个数据页
    - 把最久不使用的数据页从内存中淘汰掉
    - 影响性能的情况
      1. 一个查询要淘汰的脏页个数太多，会导致查询的响应时间明显变长；
      2. 日志写满，更新全部堵住，写性能跌为 0
- InnoDB 刷脏页的控制策略
  - `innodb_io_capacity`
    1. 建议设置成磁盘的 IOPS
    2. 通过 fio 工具测试 IOPS
      - `fio -filename=$filename -direct=1 -iodepth 1 -thread -rw=randrw -ioengine=psync -bs=16k -size=500M -numjobs=10 -runtime=10 -group_reporting -name=mytest`
  - InnoDB 刷盘速度主要参考两个因素
      1. 脏页比例
        - `innodb_max_dirty_pages_pct` 脏页比例，默认值 75%
        - 平时多关注脏页比例，不要让它经常接近 75%
        - 脏页比例通过 `Innodb_buffer_pool_pages_dirty/Innodb_buffer_pool_pages_total` 得到，具体的命令参考下面的代码
          - `mysql> select VARIABLE_VALUE into @a from global_status where VARIABLE_NAME = 'Innodb_buffer_pool_pages_dirty';select VARIABLE_VALUE into @b from global_status where VARIABLE_NAME = 'Innodb_buffer_pool_pages_total';select @a/@b;`
        - InnoDB 会根据当前的脏页比例（假设为 M），算出一个范围在 0 到 100 之间的数字，计算这个数字的伪代码类似这样
          - 伪代码
            - `F1(M){ if M>=innodb_max_dirty_pages_pct then return 100; return 100*M/innodb_max_dirty_pages_pct;}`
      2. redo log 写盘速度
        - InnoDB 每次写入的日志都有一个序号，当前写入的序号跟 checkpoint 对应的序号之间的差值，我们假设为 N。InnoDB 会根据这个 N 算出一个范围在 0 到 100 之间的数字，这个计算公式可以记为 F2(N)。F2(N) 算法比较复杂，你只要知道 N 越大，算出来的值越大就好了。
        - 根据上述算得的 F1(M) 和 F2(N) 两个值，取其中较大的值记为 R，之后引擎就可以按照 `innodb_io_capacity` 定义的能力乘以 R% 来控制刷脏页的速度。
        - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-12-2.png)
- 在 InnoDB 中，`innodb_flush_neighbors` 参数就是用来控制这个行为的，值为 1 的时候会有上述的“连坐”机制，值为 0 时表示不找邻居，自己刷自己的。
  - 使用 SSD 这类 IOPS 比较高的设备时，建议设为 0
  - MySQL 8.0 中默认值为 0

## 思考题

- 一个内存配置为 128GB、`innodb_io_capacity` 设置为 20000 的大规格实例，正常会建议你将 redo log 设置成 4 个 1GB 的文件。
- 但如果你在配置的时候不慎将 redo log 设置成了 1 个 100M 的文件，会发生什么情况呢？又为什么会出现这样的情况呢？
  - 每次事务提交都要写 redo log，如果设置太小，很快就会被写满，write pos 一直追着 CP
  - 系统不得不停止所有更新，推进 checkpoint
  - 现象：磁盘压力很小，但是数据库出现间歇性的性能下跌

## 评论区

- redo log 在“重放”的时候，如果一个数据页已经刷过，会识别出来并跳过
  - 基于 LSN（log sequence number 日志序列号）
  - 每个数据页头部有 LSN，8 字节，每次修改都会变大。
  - 对比这个 LSN 跟 checkpoint 的 LSN，比 checkpoint 小的一定是干净页
- 将脏页 flush 到磁盘上是直接将脏页数据覆盖到对应磁盘上的数据
- 断电重启后从 checkpoint 的位置往后扫，已经扫过盘的不会重复应用 redo log
- 名词解释
  - plush：刷脏页
  - purge：清 undo log
  - merge：应用 change buffer
    - change buffer 只对非唯一索引有效
- 常见的误用场景
  - 很多测试人员在做压力测试的时候 出现刚开始 insert update 很快 一会 就出现很慢,并且延迟很大，大部分是因为 redo log 设置太小（跟上面思考题相同原理）
