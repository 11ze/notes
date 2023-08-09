---

title: 02｜数据结构：快速的 Redis 有哪些慢操作？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-18T21:02:10+08:00

---

- Redis 数据类型和底层数据结构的对应关系
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-02-3.png)

- Redis 使用一个哈希表 O(1) 保存所有键值对

  - 全局哈希表（数组）
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-02-4.png)


    - 哈希桶
    - 哈希桶

    - entry
    - entry

      - *key

        - String

      - *value

        - String｜List｜Hash｜Set｜Sorted Set

  - 每个数组元素称为一个哈希桶（指针）
  - 每个哈希桶保存多个键值对数据
  - 计算键的哈希值就可以知道对应的哈希桶位置

- 哈希冲突

  - 两个 key 的哈希值和哈希桶计算对应关系时，正好落在了同一个哈希桶中。
  - 解决方案：链式哈希。同一个哈希桶中的多个元素用一个链表来保存，它们之间依次用指针连接。
  - 当一个桶中的元素过多，访问时间变长时

    - 采用两个全局哈希表，当哈希表 1 不够大时 copy 到更大的哈希表 2

      - 问题：一次性复制会导致 Redis 线程阻塞

    - rehash：增加现有哈希桶的数量

      - 装载因子的大小 = 所有 entry 个数除以哈希表的哈希桶个数
      - < 1 或者在进行 RDB 和 AOF 重写时禁止 rehash

      - >= 1，且允许进行 rehash 时会进行 rehash

      - >= 5，立马开始 rehash

    - 渐进式 rehash

      - 每次处理请求时，顺带拷贝一部分数据到另一个哈希表。
      - 定时任务周期性地搬移一些数据到新的哈希表中

- 压缩列表 ziplist 的结构

  - 表头

    - zlbytes：列表长度
    - zltail：列表尾的偏移量
    - zllen：entry 个数

  - 表尾 zlend：列表结束，取值默认是 255
  - 元素 entry

    - prev_len 前一个 entry 的长度

      - 1 字节：上一个 entry 的长度 < 254 字节
      - 5 字节：1 字节以外的情况
      - prev_len的第一个字节表示一个entry的开始，如果等于255表示列表结束，如果等于254那后四个字节才是prev_len的实际值，如果小于254，那就不需要后四个字节，直接使用这一个字节表示prev_len的实际值
      - 当前一节点长度大于等于254时，第一个字节为254(1111 1110)作为标志，后面4个字节组成一个整型用来存储长度

    - encoding 编码方式，1 字节
    - content 实际数据

  - 其他操作同整数数组、双向列表
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-02-5.png)


  - 顺序查找 O(N)

- 跳表 O(logN)：多级索引，通过索引位置的几个跳转，实现数据的快速定位
- 不同操作的复杂度

  - 单元素操作是基础

    - 每一种集合类型对单个数据实现的增删改查操作

  - 范围操作非常耗时

    - 集合类型中的遍历操作，可以返回集合中的所有数据

      - 用 SCAN 代替遍历操作

  - 统计操作通常高效

    - 集合类型中对集合中所有元素个数的记录

  - 例外情况只有几个

    - 某些数据结构的特殊记录
