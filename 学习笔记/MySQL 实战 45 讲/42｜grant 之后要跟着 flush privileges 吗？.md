---

title: 42｜grant 之后要跟着 flush privileges 吗？
tags:
- MySQL
createdAt: 2023-05-17T22:23:12+08:00

---

- 不用
- 在 MySQL 里面，用户名 (user)+ 地址 (host) 才表示一个用户，因此 ua@ip1 和 ua@ip2 代表的是两个不同的用户。
- 全局权限

  - 保存在 mysql.user 表
  - 给用户 ua 赋一个最高权限，语句：grant all privileges on *.* to 'ua'@'%' with grant option;

    - 同时更新了磁盘和内存
    - 1. 磁盘上，将 mysql.user 表里，用户’ua’@’%'这一行的所有表示权限的字段的值都修改为‘Y’；
    - 2. 内存里，从数组 acl_users 中找到这个用户对应的对象，将 access 值（权限位）修改为二进制的“全 1”。
    - 在这个 grant 命令执行完成后，如果有新的客户端使用用户名 ua 登录成功，MySQL 会为新连接维护一个线程对象，然后从 acl_users 数组里查到这个用户的权限，并将权限值拷贝到这个线程对象中。之后在这个连接中执行的语句，所有关于全局权限的判断，都直接使用线程对象内部保存的权限位。
    - revoke 命令也一样

- db 权限

  - 保存在 mysql.db 表
  - 让用户 ua 拥有库 db1 的所有权限：grant all privileges on db1.* to 'ua'@'%' with grant option;

    - 1. 磁盘上，往 mysql.db 表中插入了一行记录，所有权限位字段设置为“Y”；
    - 2. 内存里，增加一个对象到数组 acl_dbs 中，这个对象的权限位为“全 1”。
    - 每次需要判断一个用户对一个数据库读写权限的时候，都需要遍历一次 acl_dbs 数组
    - acl_dbls 是一个全局数组
    - 如果已经 use database_name，则在切换出该库之前，session 就一直有该库权限

- 表权限和列权限

  - 表权限定义存放在表 mysql.tables_priv 中，列权限定义存放在表 mysql.columns_priv 中。这两类权限，组合起来存放在内存的 hash 结构 column_priv_hash 中。
  - column_priv_hash 也是一个全局对象

- 如果内存的权限数据和磁盘数据表相同的话，不需要执行 flush privileges。
- 如果我们都是用 grant/revoke 语句来执行的话，内存和数据表本来就是保持同步更新的。

  - flush privileges 语句可以用来重建内存数据，达到一致状态。

- flush privileges 使用场景

  - 直接手动修改系统权限表时

- grant 命令加了 identified by ‘密码’

  - 1. 如果用户’ua’@’%'不存在，就创建这个用户，密码是 pa；
  - 2. 如果用户 ua 已经存在，就将密码修改成 pa。
  - 不建议的写法，容易不慎把密码给改了

- 评论区

  - 文章内容总结
    - ![Uploading file...3lmt9]()
