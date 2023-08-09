---

title: 35｜join 语句怎么优化？
tags:
- MySQL
createdAt: 2023-05-17T22:03:17+08:00

---

- Multi-Range Read 优化（MRR）

  - 目的：尽量使用顺序读盘
  - 因为大多数的数据都是按照主键递增顺序插入得到的，所以我们可以认为，如果按照主键的递增顺序查询的话，对磁盘的读比较接近顺序读，能够提升读性能。

    - MRR 的设计思路

  - 优化后的执行流程
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-35-1.png)


    - 1. 根据索引 a，定位到满足条件的记录，将 id 值放入 read_rnd_buffer 中 ;

      - read_rnd_buffer：MySQL 的随机读缓冲区。当按任意顺序读取行时（例如按照排序顺序）将分配一个随机读取缓冲区，进行排序查询时，MySQL 会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度。

    - 2. 将 read_rnd_buffer 中的 id 进行递增排序；
    - 3. 排序后的 id 数组，依次到主键 id 索引中查记录，并作为结果返回。
    - read_rnd_buffer 的大小是由 read_rnd_buffer_size 参数控制的。如果步骤 1 中，read_rnd_buffer 放满了，就会先执行完步骤 2 和 3，然后清空 read_rnd_buffer。之后继续找索引 a 的下个记录，并继续循环。

  - 想要稳定地使用 MRR 优化的话，需要设置set optimizer_switch="mrr_cost_based=off"。

    - 官方文档的说法，是现在的优化器策略，判断消耗的时候，会更倾向于不使用 MRR，把 mrr_cost_based 设置为 off，就是固定使用 MRR 了。

  - 提升性能的核心：在索引 a 上做一个范围查询，拿到足够多的主键 id，通过排序后，再去主键索引查数据，才能体现出“顺序性”的优势。
  - 用了 order by 就不要用 MRR 了

- Batched Key Access（BKA）

  - MySQL 5.6
  - 对 NLJ 算法的优化

    - NLJ 用不到 join_buffer，BKA 可以
    - 每多一个 join，就多一个 join_buffer

  - 启用方法，在执行 SQL 语句之前，先设置：set optimizer_switch='mrr=on,mrr_cost_based=off,batched_key_access=on';
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-35-2.png)


    - 前两个参数的作用是要启用 MRR。BKA 算法的优化要依赖于 MRR。

  - MySQL · 特性分析 · 优化器 MRR & BKA：[PolarDB 数据库内核月报](http://mysql.taobao.org/monthly/2016/01/04/)
  - 并不是“先计算两个表 join 的结果，再跟第三个表 join”，而是直接嵌套查询的。

- BNL 算法的性能问题

- BNL 算法对系统的影响

- 1. 可能会多次扫描被驱动表，占用磁盘 IO 资源；
- 2. 判断 join 条件需要执行 M*N 次对比（M、N 分别是两张表的行数），如果是大表就会占用非常多的 CPU 资源；
- 3. 可能会导致 Buffer Pool 的热数据被淘汰，影响内存命中率。

- 如果一个使用 BNL 算法的 join 语句，多次扫描一个冷表，而且这个语句执行时间超过 1 秒，就会在再次扫描冷表的时候，把冷表的数据页移到 LRU 链表头部。
- 业务正常访问的数据页，没有机会进入 young 区域。
- 影响 Buffer Pool 的正常运作

- 减小影响的方法：增大 join_buffer_size 的值，减少对被驱动表的扫描次数
- 执行语句之前，通过理论分析和查看 explain 结果的方式，确认是否要使用 BNL 算法，如果确认优化器会使用，就需要做优化

- BNL 转 BKA

- 1. 一些情况下，直接在被驱动表上建索引
- 2. 不能建索引时，使用临时表

- 1. 把被驱动表中满足条件的数据放到临时表中
- 2. 为了让 join 使用 BKA 算法，给临时表的字段加上索引
- 3. 让驱动表和临时表做 join 操作
- SQL：create temporary table temp_t(id int primary key, a int, b int, index(b))engine=innodb;insert into temp_t select * from t2 where b>=1 and b<=2000;select * from t1 join temp_t on (t1.b=temp_t.b);

- 这里用内存临时表的效果更好create temporary table temp_t(id int primary key, a int, b int, index (b))engine=memory;insert into temp_t select * from t2 where b>=1 and b<=2000;select * from t1 join temp_t on (t1.b=temp_t.b);

- 思路：用上被驱动表的索引，触发 BKA 算法

- 扩展 -hash join

- Mysql 8.0.18 已经支持 Hash-join8.0.20 版本以上官方已经移除BNL的支持，全部替换成 hash -join
- join_buffer 维护的无序数组替换成哈希表

- N * M => 1 * M

- 自己在业务端实现

- 1. select * from t1;取得表 t1 的全部 1000 行数据，在业务端存入一个 hash 结构，比如 C++ 里的 set、PHP 的数组这样的数据结构。
- 2. select * from t2 where b>=1 and b<=2000; 获取表 t2 中满足条件的 2000 行数据。
- 3. 把这 2000 行数据，一行一行地取到业务端，到 hash 结构的数据表中寻找匹配的数据。满足匹配的条件的这行数据，就作为结果集的一行。

- 执行效率：hash join > 临时表

- BKA 优化是 MySQL 已经内置支持的，建议默认使用；
- 评论区

- where in (?)，？的多个值不需要排序
- 固态硬盘的顺序写还是比随机写快
