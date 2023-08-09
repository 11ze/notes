---

title: 28｜Pika：如何基于 SSD 实现大容量 Redis？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-23T21:04:30+08:00

---

- 基于大内存实现大容量 Redis 实例的潜在问题

  - 1. 内存快照 RDB 生成和恢复效率低
  - 2. 主从节点全量同步时长增加、缓冲区易溢出

- Pika 键值数据库

  - Pika 设计目标

    - 一、单实例可以保存大容量数据，同时避免实例恢复和主从同步时的潜在问题
    - 二、和 Redis 数据类型保持兼容，可以平滑迁移到 Pika 上

  - 整体架构
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-28-1.png)

  - 1. 网络框架
  - 2. Pika 线程模块

    - 多线程
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-28-2.png)

    - 一个请求分发线程 DispatchThread
    - 一组工作线程 WorkerThread
    - 一个线程池 ThreadPool

  - 3. Nemo 存储模块

    - 实现 Pika 和 Redis 的数据兼容

      - List
        - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-28-3.png)

      - Set
        - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-28-4.png)

      - Hash
        - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-28-5.png)

      - Sorted Set
        - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-28-6.png)


    - 不用修改业务应用中操作 Redis 的代码

  - 4. RocksDB

    - RocksDB 写入数据的基本流程
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-28-7.png)

    - 基于 SSD 保存数据
    - 是一个持久化键值数据库
    - 保存数据

      - 使用两小块内存空间 Memtable1 和 Memtable2 交替缓存写入的数据

        - 大小可设置
        - max_write_buffer_number 控制写限速

      - 其中一块写满后，RocksDB 把数据以文件的形式快速写入底层的 SSD

    - 读取数据

      - 先在 Member 中查询，查询不到再到数据文件中查询

    - 避免了内存快照的生成和恢复问题
    - 在把数据写入 Memtable 时，也会把命令操作写到 binlog 文件中。

  - 5. binlog 机制

    - 实现增量命令同步
    - 节省了内存，避免缓冲区溢出

  - 其他优势

    - 1. 实例重启快
    - 2. 主从库执行全量同步风险低，不受内存缓冲区大小的限制

  - 不足

    - 1. 性能比用内存低

      - 多线程模型一定程度上弥补从 SSD 存取数据造成的性能损失

    - 2. 写 binlog 时影响性能

  - 降低性能影响的建议

    - 1. 利用 Pika 的多线程模型，增加线程数量，提升 Pika 的并发请求处理能力
    - 2. 为 Pika 配置高配的 SSD，提升 SSD 自身的访问性能

  - 工具

    - 使用 aof_to_pika 命令迁移 Redis 数据到 Pika 中
    - [Github｜Pika](https://github.com/OpenAtomFoundation/pika/wiki)
