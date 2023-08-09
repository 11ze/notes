---

title: 34｜到底可不可以使用 join ？
tags:
- MySQL
createdAt: 2023-05-17T21:59:52+08:00

---

- Index Nested-Loop Join（NLJ）

  - 1. 使用 join 语句，性能比强行拆成多个但表执行 SQL 语句的性能要好；
  - 2. 如果使用 join 语句的话，需要让小表做驱动表
  - 前提是“可以使用被驱动表的索引”

- Simple Nested-Loop Join

  - MySQL 没用

- Block Nested-Loop Join（BNL）
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/mysql45-34-1.png)


  - 1. 被驱动表没有索引
  - 2. 驱动表中取出所有满足条件的数据，读入线程内存 join_buffer 中

    - 如果 join_buffer 满了，进入下一步，比较完放入结果集后，清空 join_buffer，回到这一步
    - join_buffer_size 设置 join_buffer 的大小

  - 3. 扫描被驱动表，把每一行拿出来跟 join_buffer 中的数据做对比，满足 join 条件的，作为结果集的一部分返回

    - 跟 Simple xx join 一样的扫描行数
    - 不同的是一个是每一行都在驱动表全表扫描作比较，一个在内存比较

  - 不用分段时，选哪个表做驱动表都一样

    - 1. 两个表都做一次全表扫描 M+N
    - 2. 内存中的判断次数 M*N

  - 分段时，选择小表做驱动表

    - 驱动表 N 行，被驱动表 M 行
    - N 越大，分段次数越多，M 被扫的次数越多
    - 调大 join_buffer_size 可以加快没用到被驱动表索引的 join 语句

- 能不能用 join 语句？

  - 如果可以使用 Index Nested-Loop Join 算法，也就是说可以用上被驱动表上的索引，其实是没问题的；
  - 判断要不要使用 join 语句时，就是看 explain 结果里面，Extra 字段里面有没有出现“Block Nested Loop”字样，有就不用

- 选择大表还是小表做驱动表

  - 总是应该用小表
  - 小表：在决定哪个表做驱动表的时候，应该是两个表按照各自的条件过滤，过滤完成之后，计算参与 join 的各个字段的总数据量，数据量小的那个表，就是“小表”，应该作为驱动表。

- 思考题

  - 如果被驱动表是一个大表，并且是一个冷数据表，除了查询过程中可能会导致 IO 压力大以外，你觉得对这个 MySQL 服务还有什么更严重的影响吗？（这个问题需要结合上一篇文章的知识点）
