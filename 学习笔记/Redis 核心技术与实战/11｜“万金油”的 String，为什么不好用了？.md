---

title: 11｜“万金油”的 String，为什么不好用了？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-19T22:32:31+08:00

---

- [Redis 容量预估工具](http://www.redis.cn/redis_memory/)
- String 类型

  - 元数据：内存空间记录数据长度、空间使用等信息
  - int 编码方式：当保存 64 位有符号整数时，会保存为 8 字节的 Long 类型整数
  - 简单动态字符串（Simple Dynamic String，SDS）结构体的组成

    - 图 SDS
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-11-1.png)
    - buf：字节数组，保存实际数据。为了表示字节数组的结束，Redis 会自动在数组最后加一个“\0”，这就会额外占用 1 个字节的开销
    - len：占 4 个字节，表示 buf 的已用长度
    - alloc：也占 4 个字节，表示 buf 的实际分配长度，一般大于 len

  - RedisObject 结构体

    - 图
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-11-2.png)

    - 包含了 8 字节的元数据和一个 8 字节指针
    - 指针指向实际数据，如 SDS
    - int 编码：当保存 Long 类型整数时，指针直接赋值为整数数据
    - embstr 编码：保存 <= 44 字节的字符串数据，元数据、指针和 SDS 是一块连续的内存区域
    - raw 编码：保存 > 44 字节的字符串数据，给 SDS 分配独立的空间

- 哈希表的每一项是一个 dictEntry 的结构体，指向一个键值对

  - 有三个 8 字节的指针
  - 分别指向 key、value和下一个 dictEntry

- Redis 使用的内存分配库 jemalloc

  - 根据申请的字节数 N，找一个比 N 大的最接近 N 的 2 的幂次数作为分配的空间

    - 减少频繁分配的次数

- 压缩列表 ziplist
- 示例：用集合类型保存单值的键值对

  - 图片 ID 1101000060
  - 对象 ID 3302000080
  - 二级编码：hset 1101000 060 3302000080
  - 查找时会遍历压缩列表
  - Sorted Set 也可以达到类似的效果，不过插入时性能没 Hash 高

    - 需排序，而 Hash 直接插入尾部

- Hash 类型设置了用压缩列表保存数据时的两个阈值，一旦超过了阈值，Hash 类型就会用哈希表来保存数据

  - hash-max-ziplist-entries：表示用压缩列表保存时哈希集合中的最大元素个数
  - hash-max-ziplist-value：表示用压缩列表保存时哈希集合中单个元素的最大长度
  - 数据一旦用了哈希表保存就不会自动转回成压缩列表

- 选用 Hash 和 Sorted Set 存储时，节省空间，但设置过期会变得困难
- 选用 String 存储时，可以单独设置每个 key 的过期时间，还可以设置 maxmemory 和淘汰策略，以这种方式控制整个实例的内存上限
