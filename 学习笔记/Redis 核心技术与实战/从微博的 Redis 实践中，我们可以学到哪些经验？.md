---

title: 从微博的 Redis 实践中，我们可以学到哪些经验？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-24T21:54:19+08:00

---

- 微博对 Redis 的技术需求

  - 1. 能够提供高性能、高并发的读写访问，保证读写延迟低
  - 2. 能够支持大容量存储
  - 3. 可以灵活扩展，对于不同业务能进行快速扩容

- 对 Redis 的基本改进

  - 避免阻塞和节省内存
  - 持久化需求：使用全量 RDB + 增量 AOF 复制
  - 在 AOF 日志写入刷盘时，用额外的 BIO 线程负责实际的刷盘工作，避免 AOF 日志慢速刷盘阻塞主线程
  - 增加 aofnumber 配置项设置 AOF 文件的数量
  - 使用独立的复制线程进行主从库同步，避免对主线程的阻塞影响

- 定制化设计了 LongSet 数据类型
- 数据区分冷热度

  - 用异步线程将冷数据从 Redis 迁移到 RocksDB，保存到硬盘中
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-47-1.png)


- 服务化改造

  - 使用 Redis 集群服务不同的业务场景需求，每一个业务拥有独立的资源
  - 所有的 Redis 实例形成资源池，轻松扩容
  - 采用类似 Codis 的方案，通过集群代理层连接客户端和服务端

    - 客户端连接监听和端口自动增删
    - Redis 协议解析：确定需要路由的请求，如果是非法和不支持的请求，直接返回错误
    - 请求路由：根据数据和后端实例间的映射规则，将请求路由到对应的后端实例进行处理，并将结果返回给客户端
    - 指标采集监控：采集集群运行的状态，并发送到专门的可视化组件，由这些组件进行监控处理
    - 配置中心：管理整个集群的元数据

  - 微博 Redis 服务化集群架构图
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-47-2.png)


- [万亿级日访问量下，Redis 在微博的 9 年优化历程](https://mp.weixin.qq.com/s?__biz=MzkwOTIxNDQ3OA==&mid=2247532706&idx=1&sn=8bdd9a61633ff1a5d121af62cb5c4f51&source=41#wechat_redirect)
