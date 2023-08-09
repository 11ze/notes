---

title: 19｜波动的响应延迟：如何应对变慢的 Redis？（下）
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-23T20:49:49+08:00

---

- 文件系统：AOF 模式
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-19-1.png)


  - AOF 重写会对磁盘进行大量 IO 操作，fsync 需要等到数据写到磁盘后才能返回
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-19-2.png)

  - everysec 时，使用后台子线程调用 fsync 写日志

    - 虽然 fsync 由后台子线程负责执行，但主线程会监控 fsync 的执行进度
    - 上次 fsync 未执行完时，下次 fsync 会被阻塞

  - always 时，主线程中调用 fsync

- 避免使用操作系统的 swap

  - 增加机器的内存
  - 使用 Redis 集群
  - 查看 Redis 进程的 swap 使用情况

    - 1. redis-cli info | grep process_id
    - 2. cd /proc/{process_id}
    - 3. cat smaps | egrep '^(Swap|Size)'

- 操作系统：内存大页

  - 写时复制：一旦数据要被修改，Redis 不会直接修改内存中的数据，会先拷贝一份再进行修改
  - 常规内存机制只用拷贝 4KB，内存大页需要拷贝 2MB
  - 关闭即可

    - 1. cat /sys/kernel/mm/transparent_hugepage/enabled 查看是否 always 打开
    - 2. 关闭：echo never > /sys/kernel/mm/transparent_hugepage/enabled

- Checklist

  - 1. 获取 Redis 实例在当前环境下的基线性能
  - 2. 是否用了慢查询命令？使用其他命令替代慢查询命令，或者把聚合计算命令放在客户端做
  - 3. 是否对过期 key 设置了相同的过期时间？对于批量删除的 key，可以在每个 key 的过期时间上加一个随机数，避免同时删除
  - 4. 是否存在 bigkey？ 对于 bigkey 的删除操作，如果你的 Redis 是 4.0 及以上的版本，可以直接利用异步线程机制减少主线程阻塞；如果是 Redis 4.0 以前的版本，可以使用 SCAN 命令迭代删除；对于 bigkey 的集合查询和聚合操作，可以使用 SCAN 命令在客户端完成
  - 5. Redis AOF 配置级别是什么？业务层面是否的确需要这一可靠性级别？如果我们需要高性能，同时也允许数据丢失，可以将配置项 no-appendfsync-on-rewrite 设置为 yes，避免 AOF 重写和 fsync 竞争磁盘 IO 资源，导致 Redis 延迟增加
  - 6. Redis 实例的内存使用是否过大？发生 swap 了吗？增加机器内存，或者是使用 Redis 集群，分摊单机 Redis 的键值对数量和内存压力。同时，要避免出现 Redis 和其他内存需求大的应用共享机器的情况
  - 7. 在 Redis 实例的运行环境中，是否启用了透明大页机制？直接关闭内存大页机制就行了
  - 8. 是否运行了 Redis 主从集群？如果是的话，把主库实例的数据量大小控制在 2~4GB，以免主从复制时，从库因加载大的 RDB 文件而阻塞
  - 9. 是否使用了多核 CPU 或 NUMA 架构的机器运行 Redis 实例？使用多核 CPU 时，可以给 Redis 实例绑定物理核；使用 NUMA 架构时，注意把 Redis 实例和网络中断处理程序运行在同一个 CPU Socket 上
  - 10. Redis 所在的机器上有没有一些其他占内存、磁盘 IO 和网络 IO 的程序，比如说数据库程序或者数据采集程序。如果有的话，建议将这些程序迁移到其他机器上运行
  - 11. 避免存储 bigkey，Redis 4.0+ 可开启 lazy-free 机制
  - 12. 使用长连接
  - 13. 生成 RDB 和 AOF 重写 fork 耗时严重

    - a. 实例尽量小
    - b. 尽量部署在物理机上
    - c. 优化备份策略
    - d. 合理配置 repl-backlog 和 slave-clent-output-buffer-limit 避免全量同步
    - e. 视情况关闭 AOF
    - f. 监控 latest_fork_usec 耗时是否变长
