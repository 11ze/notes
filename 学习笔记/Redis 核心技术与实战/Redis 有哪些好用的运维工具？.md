---

title: Redis 有哪些好用的运维工具？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-24T21:46:32+08:00

---

- 最基本的监控命令：INFO 命令

  - INFO 命令的返回信息
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-45-1.png)

  - 重点关注 stat、commandstat、cpu、memory 参数的返回结果
  - 通过 persistence 参数的返回结果查看 RDB 或者 AOF 的执行情况
  - 通过 replication 参数的返回结果查看主从集群的实时状态

- [面向 Prometheus 的 Redis-exporter 监控](https://prometheus.io/)

  - 开源的系统监控报警框架
  - 结合 [Grafana](https://grafana.com/) 进行可视化展示
  - 支持 Redis 2.0 ～ 6.0
  - 有插件，也可以运行 Lua 脚本
  - 主流工具（2021.10.1）

- 轻量级的监控工具

  - [Redis-stat](https://github.com/junegunn/redis-stat)
  - [Redis Live](https://github.com/snakeliwei/RedisLive)

- 数据迁移工具 [Redis-shake](https://github.com/tair-opensource/RedisShake)

  - 阿里云 Redis 和 MongoDB 团队开发的数据同步工具
  - 进行数据迁移的过程
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-45-2.png)

  - 运行原理

    - 先启动 Redis-shake 进程，进程模拟了一个 Redis 实例，然后进程和数据迁出的源实例进行数据的全量同步
    - 和 Redis 主从实例的全量同步类似
    - 源实例相当于主库，Redis-shake 相当于从库

      - 1. RDB 文件 -> Redis-shake -> 目的实例
      - 2. 增量命令 -> Redis-shake -> 目的实例

    - 优势

      - 支持单个实例、集群、proxy、云下的 Redis 实例的数据迁移

  - 迁移后通常需要对比源实例和目的实例的数据是否一致，如果不一致，需要找出来，从目的实例剔除或再次迁移不一致的数据

    - 阿里云团队开发的 [Redis-full-check](https://github.com/tair-opensource/RedisFullCheck)

      - 多轮比对
      - 三种对比模式

- 集群管理工具 [CacheCloud](https://github.com/sohutv/cachecloud)

  - 实现了主从集群、哨兵集群、Redis Cluster 的自动部署和管理
  - 提供 5 个运维操作和丰富的监控信息

- 评论区：热 key 查找工具 [redis-faina](https://github.com/facebookarchive/redis-faina)
- 其他章节提到的

  - [Redis 容量预估工具](http://www.redis.cn/redis_memory/)

    - [[11｜“万金油”的 String，为什么不好用了？]]
