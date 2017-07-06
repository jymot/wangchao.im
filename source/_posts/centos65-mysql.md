---
title: CentOS 6.5 卸载/安装 MySQL
date: 2017-07-06 20:32:38
categories: [Linux]
tags: [Linux, MySQL, Server]
---
由于`CentOS 6.5`自带了`MySQL 5.1`，所以我们如果需要安装其他版本时候需要先卸载之前的版本
```shell
# 先查看mysql存在的文件
rpm -qa | grep -i mysql
# 根据查询出来的文件进行删除, ...为上面查出来的其他内容
yum remove mysql mysql-server mysql-libs ...
# 最后删除配置文件
rm -rf /var/lib/mysql
rm /etc/my.cnf
```

然后就可以开始安装新版本的`MySQL`了
```shell
# 安装wget, 如果已经安装请忽略
yum install wget -y
# 安装编译环境，如果以安装请忽略
yum -y install make gcc gcc-c++ zlib-devel libaio
# 安装repo rpm包
wget dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
yum localinstall mysql-community-release-el6-5.noarch.rpm
# 安装 mysql 相关
yum -y install mysql-server mysql mysql-devel
# 设置开机启动
chkconfig mysqld on
# 启动mysql
service mysqld start
```
默认登陆密码查询
```shell
cat /var/log/mysqld.log | grep 'password'
```
如果忘记登陆密码，可以转到这篇[文章](https://wangchao.im/2017/07/06/centos-mysql-forget-password/)

最后，安装完了可以删除 MySQL 的 Repository ，这样可以减少 yum 检查更新的时间，使用下面的命令
```shell
yum -y remove mysql-community-release-el6-5.noarch
```

#### 基本命令
```shell
# 查看系统已存在的数据库
show databases; 
# 选择需要使用的数据库
use databasesname;   
# 删除选定的数据库
drop database databasename;
# 退出数据库的连接
exit    
# 建立名为test的数据库
create database test01;
# 列出当前数据库下的表
show tables;        

# 开放远程登录权限
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```
