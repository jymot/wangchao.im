---
title: CentOS 忘记 MySQL root 密码
date: 2017-07-06 13:28:12
categories: [MySQL]
tags: [MySQL]
---

**CentOS**系统下忘记常常会因为种种原因忘记**MySQL**中**root**的密码，废话不多说直接进入正题（需要注意的是，由于修改密码的过程中**MySQL**是没有密码保护的，请确认当前环境是否安全）。

#### 1.修改登陆设置
```shell
vi /etc/my.cnf
```
然后在`[mysqld]`区域追加`skip-grant-tables`并保存，比如：
```
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
skip-grant-tables
```

#### 2.重启`mysqld`服务
```shell
service mysqld restart
```

#### 3.修改密码
直接执行`mysql`，然后更新密码
```shell
# 进入 mysql
mysql

# 切换 database
mysql> use mysql;
# 更新密码
mysql> update user set password=password('new password') where user='root';
# 刷新MySQL的系统权限相关表
mysql> flush privileges; 
# 退出
mysql> quit
```

### 4.恢复登陆设置并且重启`mysqld`服务
将最开始在`/etc/my.cnf`中加的`skip-grant-tables`删除，并保存。然后重启`mysqld`服务即可。
```shell
service mysqld restart
```



