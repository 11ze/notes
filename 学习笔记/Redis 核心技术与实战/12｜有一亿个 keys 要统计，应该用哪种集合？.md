---

title: 12｜有一亿个 keys 要统计，应该用哪种集合？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-21T22:54:45+08:00

---

- 聚合统计

  - 统计多个集合元素的聚合结果，包括：

    - 统计多个集合的共有元素（交集统计）
    - 把两个集合相比，统计其中一个集合独有的元素（差集统计）
    - 统计多个集合的所有元素（并集统计）

  - 使用 Set

    - 并集：SUNIONSTORE user:new user:id user:id:20200803
    - 差集：SDIFFSTORE user:new user:id:20200804 user:id
    - 交集：SINTERSTORE user:id:rem user:id:20200803 user:id:20200804
    - 计算复杂度较高，数据量较大时会导致 Redis 实例阻塞
    - 三个命令都会生成新 key，但从库一般是 readonly（不建议开写），想在从库操作需使用 SUNION、SDIFF、SINTER，这些命令可以计算出结果，但不会生成新 key
    - 可以从主从集群中选择一个从库专门负责聚合计算，或者是把数据读取到客户端，在客户端来完成聚合统计，这样就可以规避阻塞主库实例和其他从库实例的风险了

- 排序统计

  - 使用有序集合：List、Sorted Set
  - List 是按照元素进入 List 的顺序进行排序的，而 Sorted Set 可以根据元素的权重来排序
  - 数据更新频繁或需要分页显示，优先考虑使用 Sorted Set

- 二值状态统计

  - 指集合元素的取值就只有 0 和 1 两种
  - Bitmap

    - 对多个以日期为 key，位值为每个学生签到情况的 Bitmap，执行按位与操作可以统计出连续签到的学生数量
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-12-1.png)

    - 亦或者 uid:sign:3000:202008 2 1 可以统计学生在某段时间的签到情况
    - 优势：节省内存空间

- 基数统计

  - 指统计一个集合中不重复的元素个数，如统计网页的 UV
  - Set 和 Hash 消耗比较多的内存空间
  - HyperLogLog

    - 用于统计基数的数据类型
    - 会用就行
    - 标准误算率：0.81%
    - 最大优势：即使集合元素非常多，所需空间总是固定，很小
    - PFADD page1:uv user1 user2 user3
    - PFCOUNT page1:uv page2:uv = 统计结果总和

- 注意事项

  - 多个实例之间无法做聚合运算，可能会直接报错或者得到的结果是错误的
  - 统计数据与在线业务数据拆分开，实例单独部署，防止在做统计操作时影响到在线业务

- 以上数据类型汇总表格
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-12-2.png)
