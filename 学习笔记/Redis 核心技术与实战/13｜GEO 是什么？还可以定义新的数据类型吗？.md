---

title: 13｜GEO 是什么？还可以定义新的数据类型吗？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-22T21:16:00+08:00

---

- LBS：位置信息服务（Location-Based Service）
- GEO：数据类型

  - 底层数据结构用 Sorted Set 实现
  - GeoHash 编码方法

    - 基本原理：二分区间，区间编码

    - 对经纬度分别编码，再组合
    - 经度范围 [-180, 180]，纬度范围 [-90, 90]
    - 1. 做 N 次二分区操作，N 可以自定义
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-13-1.png)

    - 2. 根据经纬度值落在左还是右分区得到 1 位编码值
    - 3. 重复 N 次，得到一个 N bit 的数

      - 例：116.37 => 11010

    - 4. ：最终编码值的组合规则
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-13-2.png)


      - 偶数位依次是经度的编码值
      - 奇数位依次是纬度的编码值

    - 经纬度 => Sorted Set 元素的权重分数
