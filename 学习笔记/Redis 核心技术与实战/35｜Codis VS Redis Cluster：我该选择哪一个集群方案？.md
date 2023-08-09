---

title: 35｜Codis VS Redis Cluster：我该选择哪一个集群方案？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-24T21:14:27+08:00

---

- Codis 集群

  - Codis 集群的架构和关键组件图
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-35-1.png)

  - codis server

    - 进行了二次开发的 Redis 实例，其中增加了额外的数据结构，支持数据迁移操作，主要负责处理具体的数据读写请求

  - codis proxy

    - 接收客户端请求，并把请求转发给 codis server

  - Zookeeper 集群

    - 保存集群元数据，例如数据位置信息和 codis proxy 信息
    - 也可以换用 etcd 或本地文件系统保存元数据信息

      - etcd 是一个分布式键值对存储

  - codis dashboard 和 codis fe

    - 共同组成集群管理工具
    - codis dashboard 负责执行集群管理工作，包括增删 codis server、codis proxy 和进行数据迁移
    - codis fe 负责提供 dashboard 的 Web 操作界面，便于进行集群管理

- Codis 处理请求

  - 1. 先使用 codis dashboard 设置 codis server 和 codis proxy 的访问地址
  - 2. 客户端直接和 proxy 建立连接，不用修改客户端，和访问单实例 Redis 没区别
  - 3. proxy 接收到请求，查询请求数据和 codis server 的映射关系，转给相应的 server 处理，最后通过 proxy 把数据返回给客户端
  - 处理流程图
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-35-2.png)


- Codis 关键技术原理

  - 集群里的数据分布![](https://cdn.nlark.com/yuque/0/2022/png/958759/1667536105553-b0b66bcb-0c24-46eb-8cb7-104e37aabcce.png)

    - 1. 集群一共有 1024 个 Slot，编号依次是 0 到 1023

      - 可以手动，也可以通过 codis dashboard 进行自动分配

    - 2. 客户端要读写数据时，使用 CRC32 算法计算数据 key 的哈希值，把哈希值对 1024 取模得到对应 Slot 的编号

      - CRC32(key) % 1024 = n

    - 3. 即可知道数据保存在哪个 server 上

  - 数据路由表

    - 指 Slot 和 codis server 的映射关系
    - 在 codis dashboard 分配好路由表后会把路由表发送给 codis proxy，同时也会保存在 Zookeeper 中，codis proxy 会把路由表缓存在本地
    - 路由表的分配和使用过程
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-35-3.png)

  - 集群扩容和数据迁移

    - 增加 codis server

      - 1. 启动新的 codis server，将它加入集群
      - 2. 把部分数据迁移到新的 server

        - Codis 集群按照 Slot 的粒度进行数据迁移
          - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-35-4.png)

        - 1. 在源 server 上，Codis 从要迁移的 Slot 中随机选择一个数据，发送给目的 server
        - 2. 目的 server 确认收到数据后，会给源 server 返回确认消息。这时，源 server 会在本地将刚才迁移的数据删除
        - 3. 第一步和第二步就是单个数据的迁移过程。Codis 会不断重复这个迁移过程，直到要迁移的 Slot 中的数据全部迁移完成
        - 支持两种迁移模式
        - 同步迁移

          - 阻塞，此时源 server 无法处理新的请求操作

        - 异步迁移

          - 非阻塞，迁移的数据会被设置为只读，不会出现数据不一致的问题
          - 对于 bigkey，采用拆分指令的方式进行迁移：对 bigkey 的每个元素，用一条指令进行迁移

            - 会给目的 server 上被迁移中的 bigkey 设置临时过期时间，如果迁移过程发生故障，不会影响迁移的原子性，完成迁移后删除设置的临时过期时间

          - 可以通过异步迁移命令 SLOTSMGRTTAGSLOT-ASYNC 的参数 numkeys 设置每次迁移的 key 数量

    - 增加 codis proxy
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-35-5.png)

      - 1. 启动新的 proxy
      - 2. 通过 codis dashboard 把 proxy 加入集群即可

- Codis 集群可靠性

  - codis server

    - 给每个 server 配置从库，并使用哨兵机制进行监控
    - 此时每个 server 成为一个 server group，都是一主多从
    - server group 的 Codis 集群架构图
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-35-6.png)


  - codis proxy

    - 和 Zookeeper 搭配使用
    - 有超过半数的 Zookeeper 实例可以正常工作，Zookeeper 集群就可以提供服务
    - proxy 故障只需重启，然后通过 codis dashboard 从 Zookeeper 集群获取路由表即可恢复服务

- 切片集群方案选择建议

- Codis 和 Redis Cluster 的区别
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-35-7.png)

  - 1. 从稳定性和成熟度，选 Codis
  - 2. 从业务应用客户端兼容性，选 Codis
  - 3. 从数据迁移性能纬度看，选 Codis
  - 4. 从使用 Redis 新命令和新特性，选 Redis Cluster

    - Codis server 是基于开源的 Redis 3.2.8 开发的，已经不再维护
