---
title: Mac MySql 的安装与卸载
date: 2017-06-29 19:39:07
categories: [MySQL]
tags: [MySQL]
---

## 安装
MySql的安装还是相对简单的，现在[官网](https://dev.mysql.com/downloads/mysql/)下载安装包，然后直接执行就可以了，需要注意的是，安装到最后可以会有一个弹框，里面的内容大概如下：
```
2017-06-29T11:24:48.600791Z 1 [Note] A temporary password is generated for root@localhost: &<lulOGYR6cU

If you lose this password, please consult the section How to Reset the Root Password in the MySQL reference manual.
```
这个是随机生成的`root`账号的密码，需要记录一下。安装完成就可以在`系统偏好设置`中看见`MySQL`了，然后就可以启动服务了。

`MySQL`安装到了`/usr/local/mysql-**`目录中，并且`/usr/local/mysql`为其软连接，我们设置一下`mysql/bin`环境变量，就可以在使用`mysql`命令了。

现在我们就需要用到刚刚安装最后给的密码了，使用如下命令登陆`MySQL`
```shell
mysql -uroot -p登陆密码
```
登陆成功后，通过以下命令修改密码
```sql
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('新密码');
```

注意如果登陆不成功或者修改密码失败，需要执行如下步骤:
```shell
# step.1 系统偏好设置中关闭MySQL服务

# step.2 
# 进入 mysql/bin
cd /usr/local/mysql/bin/
# 登录管理员权限
sudo su
# 禁止 mysql 验证功能, 执行后 mysql 会重启
./mysqld_safe --skip-grant-tables &

# step.3 
# 分别输入如下命令
./mysql
FLUSH PRIVILEGES
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('你的新密码');

```

## 卸载
完全卸载`MySQL`，执行如下命令即可：
```shell
sudo rm /usr/local/mysql
sudo rm -rf /usr/local/mysql*
sudo rm -rf /Library/StartupItems/MySQLCOM
sudo rm -rf /Library/PreferencePanes/My*
vim /etc/hostconfig  (and removed the line MYSQLCOM=-YES-)
rm -rf ~/Library/PreferencePanes/My*
sudo rm -rf /Library/Receipts/mysql*
sudo rm -rf /Library/Receipts/MySQL*
sudo rm -rf /var/db/receipts/com.mysql.*
```
