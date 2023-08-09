---

title: 39｜Redis 6.0 的新特性：多线程、客户端缓存与安全
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-24T21:29:34+08:00

---

- 多 IO 线程

  - 作用：使用多个 IO 线程并行读取网络请求、进行协议解析、回写 Socket

    - 主线程和 IO 线程协作完成请求处理

      - 阶段一：服务端和客户端建立 Socket 连接，并分配处理线程
      - 阶段二：IO 线程读取并解析请求
      - 阶段三：主线程执行请求操作
        - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-39-1.png)

      - 阶段四：IO 线程回写 Socket 和主线程清空全局队列
        - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-39-2.png)

    - 启用多线程命令：io-threads-do-reads yes
    - 设置线程个数命令：io-threads 6

      - 一般要小于实例所在机器的 CPU 核个数
      - 例如，对于一个 8 核的机器来说，Redis 官方建议配置 6 个 IO 线程

    - 如果在实际应用中，发现 Redis 实例的 CPU 开销不大，吞吐量却没有提升，可以考虑使用 Redis 6.0 的多线程机制，加速网络处理，进而提升实例的吞吐量

  - 注意事项：多 IO 线程只负责处理网络请求，不执行命令操作
  - 适用场景：提升 Redis 吞吐量

- 客户端缓存

  - 作用

    - 普通模式：检测客户端读取的 key 的修改情况

      - 服务端对于记录的 key 只会报告一次 invalidate 消息，如果 key 再被修改，服务端就不会再次给客户端发送 invalidate 消息

    - 广播模式：将 key 的失效消息发送给所有客户端

      - 客户端需执行命令注册要跟踪的 key

        - CLIENT TRACKING ON BCAST PREFIX user

    - 重定向模式：支持使用 RESP 2 协议的客户端

      - Redis 6.0 之前的客户端可以使用此模式
      - 客户端 B 只支持 RESP 2 协议

        - 客户端 B 执行，客户端 B 的 ID 号是 303
        - SUBSCRIBE _redis_:invalidate

      - 客户端 A 支持 RESP 3 协议，兼容方案

        - 执行 CLIENT TRACKING ON BCAST REDIRECT 303 将获取到的失效消息转发给 B

  - 注意事项：普通模式和广播模式需要启用 RESP 3 协议接收失效消息
  - 适用场景：加速业务应用访问

- 访问权限控制

  - 作用：区分不同用户，支持以用户和 key 为粒度设置某个或某类命令的调用权限

    - 一些可用的操作汇总图
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-39-3.png)

  - 适用场景：支持多用户以不同权限访问 Redis

- RESP 3 协议

  - 作用：使用不同开头字符表示多种数据类型，简化客户端开发复杂度
  - 适用场景：高效支持不同数据类型使用，支持客户端缓存

- 新特性汇总图
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-39-4.png)
