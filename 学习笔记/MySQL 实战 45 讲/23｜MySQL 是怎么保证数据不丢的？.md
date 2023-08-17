---
title: 23｜MySQL 是怎么保证数据不丢的？
tags:
  - MySQL
createdAt: 2023-05-17T21:13:12+08:00
updatedAt: 2023-08-17T14:25:25+08:00
---

只要 redo log 和 binlog 保证持久化到磁盘，就能确保 MySQL 异常重启后，数据可以恢复。

## binlog 的写入机制

- 写入逻辑：事务执行过程中，先把日志写到 binlog cache，事务提交时再把 binlog cache 写到 binlog 文件。

  - 一个事务的 binlog 是要确保一次性写入，不能被打断
  - 系统给 binlog cache 分配了一片内存，每个线程一个，
    - 参数 binlog_cache_size 用于控制单个线程内 binlog cache 所占内存的大小。如果超过了这个参数规定的大小，就要暂存到磁盘。
  - 事务提交时，执行器把 binlog cache 里的完整事务写入到 binlog 中，并清空 binlog cache。状态如图所示。
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-23-1.png)

    - 图中的 write，指的就是指把日志写入到文件系统的 page cache，并没有把数据持久化到磁盘，所以速度比较快。
    - 图中的 fsync，才是将数据持久化到磁盘的操作。一般情况下，我们认为 fsync 才占磁盘的 IOPS。
    - write 和 fsync 的时机，是由参数 sync_binlog 控制的：

      - 1. sync_binlog=0 的时候，表示每次提交事务都只 write，不 fsync；
      - 2. sync_binlog=1 的时候，表示每次提交事务都会执行 fsync；
      - 3. sync_binlog=N(N>1) 的时候，表示每次提交事务都 write，但累积 N 个事务后才 fsync。

        - 如果主机发生异常重启，会丢失最近 N 个事务的 binlog 日志。

## redo log 的写入机制

- 都先写到 redo log buffer
  - 不用每次生成后都直接持久化到磁盘
    - 如果事务执行期间 MySQL 异常重启，这部分日志丢了，由于事务并没有提交，所以没损失
  - 事务没提交，这时日志也有可能被持久化到磁盘

- redo log 的存储状态
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-23-2.png)

- 为了控制 redo log 的写入策略，InnoDB 提供了 innodb_flush_log_at_trx_commit 参数

  - 1. 设置为 0 的时候，表示每次事务提交时都只是把 redo log 留在 redo log buffer 中 ;
  - 2. 设置为 1 的时候，表示每次事务提交时都将 redo log 直接持久化到磁盘；
  - 3. 设置为 2 的时候，表示每次事务提交时都只是把 redo log 写到 page cache。

- InnoDB 有一个后台线程，每隔 1 秒，就会把 redo log buffer 中的日志，调用 write 写到文件系统的 page cache，然后调用 fsync 持久化到磁盘。
  - 没有提交的事务的 redo log 也会

- 另外两个会让没有提交的事务的 redo log 写入到磁盘的场景
  - 1. redo log buffer 占用的空间即将达到 innodb_log_buffer_size 一半的时候，后台线程会主动写盘。
    - 注意，由于这个事务并没有提交，所以这个写盘动作只是 write，而没有调用 fsync，也就是只留在了文件系统的 page cache。
  - 2. 并行的事务提交的时候，顺带将这个事务的 redo log buffer 持久化到磁盘。
    - 假设一个事务 A 执行到一半，已经写了一些 redo log 到 buffer 中，这时候有另外一个线程的事务 B 提交，如果 innodb_flush_log_at_trx_commit 设置的是 1，那么按照这个参数的逻辑，事务 B 要把 redo log buffer 里的日志全部持久化到磁盘。这时候，就会带上事务 A 在 redo log buffer 里的日志一起持久化到磁盘。

- 通常我们说 MySQL 的“双 1”配置，指的就是 sync_binlog 和 innodb_flush_log_at_trx_commit 都设置成 1。也就是说，一个事务完整提交前，需要等待两次刷盘，一次是 redo log（prepare 阶段），一次是 binlog。

## 组提交机制

- 日志逻辑序列号（log sequence number，LSN）
  - 单调递增，用来对应 redo log 的一个个写入点
  - 每次写入长度为 length 的 redo log， LSN 的值就会加上 length。
  - LSN 也会写到 InnoDB 的数据页中，来确保数据页不会被多次执行重复的 redo log

- 一次组提交里面，组员越多，节约磁盘 IOPS 的效果越好。但如果只有单线程压测，那就只能老老实实地一个事务对应一次持久化操作了。
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-23-3.png)

  - trx1 先到达，会被选为 leader
  - 开始写盘，因为组里有了三个事务，所以 LSN 变成了最大值 160
  - 等到 trx1 返回时，所有 LSN 小于等于 160 的 redo log 都已经被持久化到磁盘，所以 trx2 和 trx3 可以直接返回

- 在并发更新场景下，第一个事务写完 redo log buffer 以后，接下来这个 fsync 越晚调用，组员可能越多，节约 IOPS 的效果就越好。
- 为了让一次 fsync 带的组员更多，MySQL 有一个很有趣的优化：拖时间。

  - 两阶段提交
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-23-4.png)

  - 两阶段提交细化
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-23-5.png)

  - 写 binlog 是分成两步的

    - 1. 先把 binlog 从 binlog cache 中写到磁盘上的 binlog 文件；
    - 2. 调用 fsync 持久化。

  - MySQL 为了让组提交的效果更好，把 redo log 做 fsync 的时间拖到了步骤 1 之后
  - 3 执行很快，所以 binlog 的组提交效果通常不如 redo log 的效果好

- 提升 binlog 组提交的效果

  - 1. binlog_group_commit_sync_delay 参数，表示延迟多少微秒后才调用 fsync;
  - 2. binlog_group_commit_sync_no_delay_count 参数，表示累积多少次以后才调用 fsync。
  - 两个条件是 或 的关系

## WAL 机制是减少磁盘写，但每次提交事务都要写 redo log 和 binlog，磁盘读写没减少？

- redo log 和 binlog 都是顺序写，磁盘的顺序写比随机写速度要快；
- 组提交机制可以大幅度降低磁盘的 IOPS 消耗。

## MySQL 出现 IO 性能瓶颈的提升性能方法

- 1. 设置 binlog_group_commit_sync_delay 和 binlog_group_commit_sync_no_delay_count 参数，减少 binlog 的写盘次数。
  - 这个方法基于“额外的故意等待”来实现，因此可能会增加语句的响应时间，但没有丢失数据的风险。
- 2. 将 sync_binlog 设置为大于 1 的值（比较常见是 100~1000）。
  - ⚠️ 这样做的风险是，主机掉电时会丢 binlog 日志。
- 3. 将 innodb_flush_log_at_trx_commit 设置为 2。这样做的风险是，主机掉电的时候会丢数据。
  - 不建议设置为 0（只保存在内存中）
  - 0 跟 2 的性能差不多，但 2 的风险更小

## 数据库的 crash-safe 的作用

- 1. 如果客户端收到事务成功的消息，事务就一定持久化了；
  - 双 1 配置时
- 2. 如果客户端收到事务失败（比如主键冲突、回滚等）的消息，事务就一定失败了；
- 3. 如果客户端收到“执行异常”的消息，应用需要重连后通过查询当前状态来继续后续的逻辑。此时数据库只需要保证内部（数据和日志之间，主库和备库之间）一致就可以了。

## 思考题

- 你的生产库设置的是「双 1」吗？ 如果平时是的话，你有在什么场景下改成过“非双 1”吗？你的这个操作又是基于什么决定的？

  - 1. 业务高峰期
  - 2. 备库延迟
  - 3. 用备份恢复主库的副本，应用 binlog 的过程
  - 4. 批量导入数据的时候

- 我们都知道这些设置可能有损，如果发生了异常，你的止损方案是什么？
- 一般情况下，把生产库改成“非双 1 ”配置，是设置
  - `innodb_flush_logs_at_trx_commit=2`
  - `sync_binlog=1000`

## 评论区

- 看到的「binlog 的记录」是从 page cache 读，page cache 在操作系统文件系统上

  - ls 的结果也是

- 为什么 binlog cache 是每个线程自己维护的，而 redo log buffer 是全局共用的？

  - binlog 存储是以 statement 或者 row 格式存储的，而 redo log 是以 page 页格式存储的。page 格式，天生就是共有的，而 row 格式，只跟当前事务相关
  - 在这里联系到 binlog 的格式，statement 记录的是更新的 SQL，但是要写上下文，因此不能中断，不然同步到从库后从库无法恢复一样的数据内容

- 如果 `sync_binlog = N｜binlog_group_commit_sync_no_delay_count = M｜binlog_group_commit_sync_delay = 很大值`，这种情况 fsync 什么时候发生

  - sync_delay 和 sync_no_delay_count 的逻辑先走，因此该等还是会等。等到满足了这两个条件之一，就进入 sync_binlog 阶段。这时候如果判断 sync_binlog=0，就直接跳过，还是不调 fsync。
