---
title: Laravel 开发注意事项
tags:
  - PHP
  - 开发
  - 规范
created: 2023-11-21T10:09:09+08:00
updated: 2024-05-30T23:00:00+08:00
---

## MySQL

- 时区：Asia/Shanghai
- binlog 格式：row
- 隔离级别：读提交
  - `select @@transaction_isolation;`
  - `set @global transaction isolation level read committed;`

## 目录说明

1. Requests 表单验证
2. Controllers 控制器，无业务或写简单的业务逻辑
3. Services 行业务逻辑处理
4. Models 定义模型，提供数据库操作
5. Traits 需要复用的代码

### 任务调度

> <https://learnku.com/docs/laravel/10.x/scheduling/14875#running-the-scheduler>

添加到部署 PHP 的服务器的 crontab 中

```shell
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

## 数据库规范

- 隔离级别：读提交
- 表名均使用小写加下划线且复数形式（除非单词没有复数）
- 表字段名均使用小写加下划线
- 普通索引使用 idx_ 开头
- 唯一索引使用 uk_ 开头
- 索引名里的表名使用大驼峰形式
- 索引名里的字段名使用小驼峰形式
- 索引名太长可用缩写
- 作为索引的字符串类型字段的长度不能大于 191
- 日期字段均使用 datetime 类型（避免时区问题）
- 索引字段均不允许为 null（暂时只有 datetime 类型可能为 null，2023-06-16）
- 添加新字段时必须有默认值或 nullable
- 需要区分字母大小写的字段使用 binary 类型，如 `$table->string('fixed_id', 191)->collation('utf8mb4_bin')`
- 表、列和 Model 对应的字段必须有注释，参考 User 和 Student Model

## 开发规范

- 只在配置文件里使用 `env()` 函数
- 只使用 `===` 和 `!==`，不使用 == 和 !=
- 使用 Carbon 日期类型
- 使用小驼峰形式的变量名、方法名
- 对于接口可选参数都需要添加 `nullable`，如：`'name' => 'nullable|string'`

## Eloquent ORM

- [文档](https://learnku.com/docs/laravel/10.x/eloquent/14888)
- [集合](https://learnku.com/docs/laravel/10.x/collections/14862)
- 查看生成的 SQL：`DB::enableQueryLog(); DB::getQueryLog();`
- 在循环里 $role->users 这种查询会触发 N+1 问题，使用 with 方法预加载
  - `Role::with('users')->get();`
  - 或在 Model 里设置 `protected $with = ['users'];`
    - 小心循环引用，如：`User::with('roles')->get();` 会导致死循环
- 批量插入数据
  - `User::insert()` 支持批量插入，但是仅支持传入数组，不支持传入 Collection
  - 需要先调用 `toArray()` 方法再入 `insert()`
  - 如果遇到日期字段，需要 `toArray()` 后再调用 `Carbon::parse('field')->toIso8601String()` 方法
- 基于 Model 使用 join 时，最后要在 get() 里指定字段，否则数据可能错误，关联模型的字段不会受指定字段影响
  - 如 User::join(Student)->get()，id 会被覆盖变成 student.id，改为 User::join(Student)->get(['users.*']) 即可
    - user->student 能正常拿到、从接口返回学生信息
- 关联模型查询

    ```php
    ## 查找出拥有指定 id 的角色的学生
    Student::whereHas('users.roles', function ($query) use ($roleId) {
        $query->where('id', $roleId);
    })->get();
    ```

- 基于关联模型排序

    ```php
    // examArrangement->examCourse->class->name
    ->join('course_grade_exam_batch_courses', 'course_grade_exam_batch_courses.id', '=', 'course_grade_exam_arrangements.exam_course_id')
    ->join('school_roll_classes', 'school_roll_classes.id', '=', 'course_grade_exam_batch_courses.class_id')
    ->orderBy('school_roll_classes.name', 'asc')
    ```

## 本地文件存储

- 文件存储在 `storage/app/public` 目录下，保存的路径时不需要加 `public/` 前缀
- 保存客户端上传的文件
  - `use app\FileTrait`;
  - `$file = $this->fileSave($request->file, 'enrollment/guide')`;
- 生成访问链接时使用 `\Illuminate\Support\Facades\Storage::url()` 方法
- 生成文件访问链接
  - `Storage::url()` 方法
    - 文件保存位置 `storage/app/public/`
  - 或 `url(config('app.url').'/static/forms/缓考申请表.pdf'`
    - 文件在 public/
- Request
  - 文件字段使用 `Illuminate\Http\UploadedFile` 类型，如 `@property \Illuminate\Http\UploadedFile $file`
  - 验证规则使用 `file` 或 `image`，其他类型可以考虑使用 `mimes`，如：`'file' => 'required|file|mimes:doc,docx'`
    - 对于 Office 文件，可以考虑多加一个 `bin` 到 `mimes`，如：`'file' => 'required|file|mimes:doc,docx,bin'`，但必须用原文件名保存文件
- TODO：可能需要 Nginx + Lua 脚本来实现文件访问权限控制

## 生成 Model 关系图

- 安装 graphviz
- composer install
- 修改 `config/erd-generator.php`
- php artisan generate:erd [filename].png

## 获取反代 IP

- Nginx

```Nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $http_host;
```

- 设置中间件里的可信任列表

```PHP
# app/Http/Middleware/TrustProxies.php
protected $proxies = '*';
```

```PHP
// config/app.php，这样设置未生效，待查
'trusted_proxies' => [
    '*',
],
```

- 获取

```PHP
$request->ip();
```

## 修改 storage_path() 默认路径

```shell
# .env

# 自定义 storage_path() 路径
LARAVEL_STORAGE_PATH=/custom_path
```

## laravel-ide-helper

[GitHub - barryvdh/laravel-ide-helperl](https://github.com/barryvdh/laravel-ide-helper)

## 在线查看日志

- [GitHub - rap2hpoutre/laravel-log-viewer](https://github.com/rap2hpoutre/laravel-log-viewer)
