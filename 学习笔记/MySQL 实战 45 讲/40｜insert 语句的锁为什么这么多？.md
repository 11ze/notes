---

title: 40｜insert 语句的锁为什么这么多？
tags:
- MySQL
createdAt: 2023-05-17T22:17:02+08:00

---

- insert … select 语句

  - 并发 insert 场景
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-40-1.png)


    - 实际的执行效果是，如果 session B 先执行，由于这个语句对表 t 主键索引加了 (-∞,1]这个 next-key lock，会在语句执行完成后，才允许 session A 的 insert 语句执行。
    - 但如果没有锁的话，就可能出现 session B 的 insert 语句先执行，但是后写入 binlog 的情况。于是，在 binlog_format=statement 的情况下，binlog 里面就记录了这样的语句序列：insert into t values(-1,-1,-1);insert into t2(c,d) select c,d from t;这个语句到了备库执行，就会把 id=-1 这一行也写到表 t2 中，出现主备不一致。

  - 是很常见的在两个表之间拷贝数据的方法
  - 在可重复读隔离级别下，这个语句会给 select 的表里扫描到的记录和间隙加读锁。

- insert 循环写入

  - 如果 insert 和 select 的对象是同一个表，则有可能会造成循环写入。这种情况下，我们需要引入用户临时表来做优化。
  - 怕边遍历原表边插入数据会查到刚插入的新数据，所以会先把查询结果放到临时表，再取出来进行插入操作
  - 这里需要给子查询加入 limit，不然就会全表扫描，导致给所有记录和空隙加锁

    - 8.x 优化了

- insert 唯一键冲突
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-40-2.png)


  - insert 语句如果出现唯一键冲突，会在冲突的唯一值上加共享的 next-key lock(S 锁)。因此，碰到由于唯一键约束导致报错后，要尽快提交或回滚事务，避免加锁时间过长。
  - 唯一键冲突加锁
  - 一个经典的死锁场景
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-40-3.png)


    - A 先加锁，B、C 发现唯一键冲突（c 是唯一索引，所以读是当前读），都加上读锁（间隙锁不互斥所以加成功，读、写锁会互斥，所以都在等待行锁释放），A 回滚，B、C 继续执行，都要加上写锁，互相等待对方的行锁，于是出现了死锁

- insert into … on duplicate key update

  - 这个语义的逻辑是，插入一行数据，如果碰到唯一键约束，就执行后面的更新语句。

    - 会给索引 c 上 (5,10] 加一个排他的 next-key lock（写锁）。

  - 如果有多个列违反了唯一性约束，就会按照索引的顺序，修改跟第一个索引冲突的行。
  - 执行这条语句的 affected rows 返回的是 2，很容易造成误解。

    - 真正更新的只有一行，只是在代码实现上，insert 和 update 都认为自己成功了，update 计数加了 1， insert 计数也加了 1。

- 评论区

  - 关于 insert 造成死锁的情况，并非只有 insert，delete 和 update 都可能造成死锁问题，核心还是插入唯一值冲突导致的线上的处理办法可以是 1 去掉唯一值检测 2 减少重复值的插入 3 降低并发线程数量
  - 关于数据拷贝大表，建议采用 pt-archiver，这个工具能自动控制频率和速度，建议在低峰期进行数据操作
  - 一般 select …lock in share mode 就是共享锁；select … for update 和 IUD 语句，就是排他锁。
