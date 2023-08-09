---

title: 14｜如何在 Redis 中保存时间序列数据？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-22T21:18:22+08:00

---

- 要求

  - 写要快
  - 查询模式多

- 一、同时使用 Hash 和 Sorted Set

  - {1: a, 2: b, 3: c} + setKey: {1: a, 2: b, 3: c}

    - Hash 负责单键查询，Sorted Set 负责范围查询

  - 多个写操作的原子性

    - MULTI 命令：表示一系列原子性操作的开始
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-14-1.png)

    - EXEC 命令：表示一系列原子性操作的结束
    - 建议客户端使用 pipeline，一次性批量发送命令给服务端，减少网络 IO 次数

  - 聚合计算需要借助客户端，数据量大时比较耗资源

- 二、RedisTimeSeries

  - 是专门为时间序列数据访问设计的扩展模块
  - 支持聚合计算
  - 可以按标签属性过滤查询数据集合
  - 不属于内建功能模块，需要先把它的源码单独编译成动态链接库 redistimeseries.so，再使用 loadmodule 命令进行加载

- 方案选择建议

  - 部署环境中网络带宽高、Redis 实例内存大，可以优先考虑第一种方案
  - 部署环境中，网络、内存资源有限，而且数据量大，聚合计算频繁，需要按数据集合属性查询，可以优先考虑第二种方案
  - 更好的选择：使用时序数据库

- 思考题

  - 使用 Sorted Set 保存时序数据，把时间戳作为 score，把实际的数据作为 member，有什么潜在的风险？

    - 如果对某一个对象的时序数据记录很频繁的话，这个 key 很容易变成一个 bigkey，在 key 过期释放内存时可能引发阻塞风险
    - 存在 member 重复的问题

  - 如果你是 Redis 的开发维护者，你会把聚合计算也设计为 Sorted Set 的内在功能吗？不会。

    - 因为聚合计算是 CPU 密集型任务，Redis 在处理请求时是单线程的，也就是它在做聚合计算时无法利用到多核 CPU 来提升计算速度
    - 如果计算量太大，也会导致 Redis 的响应延迟变长，影响 Redis 的性能
