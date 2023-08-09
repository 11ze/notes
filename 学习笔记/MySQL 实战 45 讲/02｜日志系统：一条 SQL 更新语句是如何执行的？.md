---

title: 02｜日志系统：一条 SQL 更新语句是如何执行的？
tags:
- MySQL
createdAt: 2023-05-17T09:52:27+08:00

---

## Update 语句执行流程

![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-02-1.png)

## 重要的日志模块：redo Log

- 是 InnoDB 引擎特有的日志
- WAL（Write-Ahead Logging）技术
  - 先写日志，再写磁盘
  - 当有一条记录需要更新的时候，InnoDB 引擎先把记录写到 redo log，并更新内存，引擎会在适当的时候，将这个操作记录更新到磁盘，这个更新往往是在系统比较空闲的时候做
- redo log 大小固定，比如可以配置为一组 4 个文件，每个文件的大小是 1GB，所有文件组成一块“粉板”
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-02-2.png)
  - write pos 是当前记录的位置，一边写一边后移，写到文件末尾后会回到文件开头
  - checkpoint 是当前要擦除的位置，也是往后推移并且循环的，擦除记录前要把记录更新到数据文件
  - write pos 和 checkpoint 之间的是“粉板”上还空着的部分，可以用来记录新的操作。
  - 如果 write pos 追上 checkpoint，表示“粉板”满了，这时候不能再执行新的更新，得停下来先擦掉一些记录，把 checkpoint 推进一下。
- crash-safe：有了 redo log，InnoDB 可以保证数据库发生异常重启也不丢失数据

## 重要的日志模块：binlog（归档日志）

- 是 Server 层的日志
- `statement` 格式：记 SQL 语句
- `row` 格式：记录行的内容，记两条，更新前和更新后都有
  - 建议使用

## Redo Log 和 Binlog 的不同

1. redo log 是 InnoDB 引擎特有的；binlog 是 MySQL 的 Server 层实现的，所有引擎都可以使用。
2. redo log 是物理日志，记录的是“在某个数据页上做了什么修改”；binlog 是逻辑日志，记录的是这个语句的原始逻辑，比如“给 ID=2 这一行的 c 字段加 1 ”。
    - 逻辑：其他引擎都能用，都讲得通这个“逻辑”
    - 物理：只有“我“能用，别人没有共享我的”物理格式“
3. redo log 是循环写，空间固定会用完；binlog 是追加写入。
    1. “追加写”是指 binlog 文件写到一定大小后会切换到下一个，并不会覆盖以前的日志。

## 两阶段提交

- 提交流程
  1. redolog 的 prepare 阶段
  2. 写 binlog
  3. redolog 的 commit
- 在 2 之前崩溃时，重启恢复后发现没有 commit，回滚；备份恢复，没有 binlog。一致
- 在 3 之前崩溃，重启恢复后发现虽然没有 commit，但满足 prepare 和 binlog 完整，自动 commit；备份恢复，有 binlog。一致

## 设置建议

- `innodb_flush_log_at_trx_commit` 建议设置成 1，表示每次事务的 redo log 都直接持久化到磁盘，保证 MySQL 异常重启之后数据不丢失
- `sync_binlog` 建议设置成 1，表示每次事务的 binlog 都持久化到磁盘，保证 MySQL 异常重启之后 binlog 不丢失

## 答疑文章（一）

### MySQL 怎么知道 Binlog 是完整的？

- 一个事务的 binlog 有完整格式：
- statement 格式的 binlog，最后会有 `COMMIT`；
- row 格式的 binlog，最后会有一个 `XID event`。
- MySQL 5.6.2 之后，引入了 `binlog-checksum` 参数，用于验证 binlog 内容的正确性

### Redo Log 和 Binlog 是怎么关联起来的?

- 它们有一个共同的数据字段 XID。崩溃恢复的时候，会按顺序扫描 redo log：
- 如果碰到既有 prepare、又有 commit 的 redo log，就直接提交；
- 如果碰到只有 parepare、而没有 commit 的 redo log，就拿着 XID 去 binlog 找对应的事务。

### 处于 Prepare 阶段的 Redo Log 加上完整 binlog，重启就能恢复，MySQL 为什么要这么设计?

- 与数据与备份的一致性有关。在时刻 B，也就是 binlog 写完以后 MySQL 发生崩溃，这时候 binlog 已经写入了，之后就会被从库（或者用这个 binlog 恢复出来的库）使用。所以，在主库上也要提交这个事务。采用这个策略，主库和备库的数据就保证了一致性。

### 如果这样的话，为什么还要两阶段提交呢？干脆先 Redo Log 写完，再写 binlog。崩溃恢复的时候，必须得两个日志都完整才可以。是不是一样的逻辑？

- 两阶段提交是经典的分布式系统问题，并不是 MySQL 独有。
- 这么做的必要性是事务的持久性问题。
  - 对于 InnoDB 引擎来说，如果 redo log 提交完成了，事务就不能回滚（如果这还允许回滚，就可能覆盖掉别的事务的更新）。而如果 redo log 直接提交，然后 binlog 写入的时候失败，InnoDB 又回滚不了，数据和 binlog 日志会不一致。

### 不引入两个日志，也就没有两阶段提交的必要了。只用 Binlog 来支持崩溃恢复，又能支持归档，不就可以了？

- ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-02-3.png)
- binlog 没有崩溃恢复的能力
  - 如果图中标的位置，binlog2 写完了，但是整个事务还没有 commit 的时候，MySQL 发生了 crash。重启后引擎内部事务 2 会回滚，然后应用 binlog2 可以补回来；但是对于事务 1，系统已经认为提交完成了，不会再应用一次 binlog1。但是，binlog 引擎使用的是 WAL 技术，执行事务的时候，写完内存和日志，事务就算完成了。如果之后崩溃，要依赖于日志来恢复数据页。如果在图中这个位置发生崩溃的话，事务 1 也是可能丢失了的，而且是数据页级的丢失。此时，binlog 里面并没有记录数据页的更新细节，是补不回来的。
- 如果优化一下 binlog 的内容，让它来记录数据页的更新可以吗？这其实就是又做了一个 redo log 出来。至少现在的 binlog 能力还不支持崩溃恢复。（MySQL 8.0）

### 那能不能反过来，只用 Redo log，不要 binlog？

- 如果只从崩溃恢复的角度来讲是可以的。把 binlog 关掉，这样就没有两阶段提交，但系统依然是 crash-safe 的。
- binlog 有着 redo log 无法替代的功能
  1. 归档。redo log 是循环写，写到末尾是要回到开头继续写的。这样历史日志没法保留，redo log 起不到归档的作用。
  2. MySQL 系统依赖于 binlog。binlog 作为 MySQL 一开始就有的功能，被用在了很多地方。其中，MySQL 系统高可用的基础就是 binlog 复制。
  3. 很多公司有异构系统（比如一些数据分析系统），这些系统靠消费 MySQL 的 binlog 来更新自己的数据。

### Redo Log 一般设置多大？

- redo log 太小会导致很快就被写满，然后不得不强行刷 redo log，WAL 机制的能力发挥不出来。
- 如果是现在常见的几个 TB 的磁盘的话，直接将 redo log 设置为 4 个文件、每个文件 1GB。

### 正常运行中的实例，数据写入后的最终落盘，是从 Redo Log 更新过来的还是从 Buffer Pool 更新过来的呢？

- redo log 并没有记录数据页的完整数据，它并没有能力自己去更新磁盘数据页，不存在“数据最终落盘，是由 redo log 更新过去”的情况。
- 如果是正常运行的实例，数据页被修改以后，跟磁盘的数据页不一致，称为脏页。最终数据落盘，就是把内存中的数据页写盘。这个过程，与 redo log 毫无关系。
- 在崩溃恢复场景中，InnoDB 如果判断到一个数据页可能在崩溃恢复的时候丢失了更新，就会将它读到内存，然后让 redo log 更新内存内容。更新完成后，内存页变成脏页，就回到了第一种情况的状态。

### Redo Log Buffer 是什么？是先修改内存，还是先写 Redo Log 文件？

- 在一个事务的更新过程中，日志需要写多次。
  - 比如：`begin; insert into t1 …; insert into t2 …; commit`;
  - 这个事务要往两个表中插入记录，插入数据的过程中，生成的日志都得先保存起来，但又不能在还没 commit 的时候就直接写到 redo log 文件里。
  - 所以，redo log buffer 就是一块内存，用来先存 redo 日志。
  - 在执行第一个 insert 的时候，数据的内存被修改了，redo log buffer 也写入了日志。
  - 但是，真正把日志写到 redo log 文件（文件名是 `ib_logfile+ 数字`），是在执行 commit 语句的时候做的。
  - 这里说的是事务执行过程中不会“主动去刷盘”，以减少不必要的 IO 消耗。但是可能会出现“被动写入磁盘”，比如内存不够、其他事务提交等情况。这个问题我们会在 [[22｜MySQL有哪些“饮鸩止渴”提高性能的方法？]] 中再详细展开。
- 单独执行一个更新语句的时候，InnoDB 会自己启动一个事务，在语句执行完成的时候提交。过程跟上面是一样的，只不过是“压缩”到了一个语句里面完成。
