---

title: 经典的 Redis 学习资料
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-24T21:38:18+08:00

---

- 工具书：《Redis 使用手册》

  - 最有用的是「数据结构与应用」的内容
  - 工具网站

    - [Redis 命令参考](https://redis.io/commands/)

- 原理书：《Redis 设计与实现》

  - 重点学习 Redis 底层数据结构、RDB 和 AOF 持久化机制、哨兵机制和切片集群的介绍
  - 出版日期较早，针对的是 Redis 3.0

- 实战书：《Redis 开发与运维》

  - 介绍了 Redis 的 Java 和 Python 客户端，以及 Redis 用于缓存设计的关键技术和注意事项，这些内容在其他参考书中不太常见，重点学习
  - 围绕客户端、持久化、主从复制、哨兵、切片集群等几个方面，着重介绍了在日常的开发运维过程中遇到的问题和“坑”，都是经验之谈，可以帮助提前做规避
  - 针对 Redis 阻塞、优化内存使用、处理 bigkey 这几个经典问题，提供了解决方案

- 扩展阅读

  - 《操作系统导论》

    - 和 Redis 直接相关的部分：对进程、线程的定义，对进程 API、线程 API 以及对文件系统 fsync 操作、缓存和缓冲的介绍

  - 《大规模分布式存储系统：原理解析与架构实战》

    - 分布式系统章节

  - Redis 的关键机制和操作系统、分布式系统的对应知识点
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-42-1.png)


- 《Redis 深度历险：核心原理与应用实践》
