---

title: 18｜波动的响应延迟：如何应对变慢的 Redis？（上）
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-22T21:27:57+08:00

---

- Redis 真的变慢了吗？

  - 1. 查看 Redis 的响应延迟

    - redis-cli --latency -h host -p port

  - 2. 基于当前环境下的 Redis 基线性能做判断

    - 基线性能：一个系统在低压力、无干扰下的基本性能，这个性能只由当前的软硬件配置决定
    - redis-cli 命令提供的 -intrinsic-latency 选项可以用来检测和统计测试期间的最大延迟，这个延迟可以作为基线性能

      - 要在服务器端运行，只考虑服务器端软硬件环境的影响

    - Redis 运行时延迟是其基线性能的 2 倍及以上表示 Redis 变慢了

- 如何应对 Redis 变慢？

  - 从慢查询命令开始排查，并且根据业务需求替换慢查询命令
  - 在客户端进行排序、交集、并集操作，不使用 SORT、SUNION、SINTER 命令，避免拖慢 Redis 实例
  - 排查过期 key 的时间设置，并根据实际使用需求，设置不同的过期时间，给过期时间加上随机数

- 在 Redis 中，还有哪些其他命令可以代替 KEYS 命令，实现同样的功能呢？这些命令的复杂度会导致 Redis 变慢吗？

  - 使用 SCAN 命令获取整个实例所有 key

    - SCAN $cursor COUNT $count

      - 一次最多返回 count 个数的 key，数量不会超过 count

    - 不会漏 key

      - SCAN 采用高位进位法的方式遍历哈希桶，当哈希表扩容后，通过此算法遍历，旧哈希表中的数据映射到新哈希表，依旧会保留原来的先后顺序，此时不会遗漏也不会重复 key

    - 可能会返回重复的 key

      - 与 Redis 的 Rehash 机制有关，哈希表缩容时，已经遍历过的哈希表会映射到新哈希表没有遍历到的位置

  - Redis 针对 Hash/Set/Sorted Set 提供了 HSCAN/SSCAN/ZSCAN 命令，用于遍历一个 key 中的所有元素，建议在获取一个 bigkey 的所有数据时使用，避免发生阻塞风险

    - key 的元素较少时，底层采用 intset/ziplist 方式存储，会无视命令的 count 参数

  - Redis 4.0 之后可以使用异步线程机制减少主线程阻塞
