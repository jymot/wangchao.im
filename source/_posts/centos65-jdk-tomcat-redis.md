---
title: CentOS 6.5 配置 JDK + Tomcat + Redis 以及部署 Java Web
date: 2017-07-06 19:22:08
categories: [Linux]
tags: [Linux, Server]
---
今天在**CentOS 6.5**下简单部署了**Web App**,下面简单记录一下正题的过程。

## 1.JDK
[http://www.oracle.com/technetwork/java/javase/downloads/index.html](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
首先是**JDK**的安装(本文以1.8为例)，具体执行步骤如下：
```shell
cd /usr
# 创建 java 目录
mkdir java
cd java
# 下载 JDK 1.8
curl -O http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
# 解压
tar -zxvf jdk-8u131-linux-x64.tar.gz
```
然后配置环境变量，执行`vi /etc/profile`，并添加如下内容：
```shell
#set java environment
JAVA_HOME=/usr/java/jdk1.8.0_131
JRE_HOME=/usr/java/jdk1.8.0_131/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH
```
然后执行`source /etc/profile`后执行`java -version`对刚刚的配置进行验证。

当然也可以用`yum`安装**JDK**，首先使用`yum search java | grep jdk`查看版本，然后执行`yum install java-1.8.0-openjdk`进行安装，安装完成后会在`/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.75.x86_64`目录中。

<!--more-->

## 2.Tomcat
[http://tomcat.apache.org/download-80.cgi](http://tomcat.apache.org/download-80.cgi)
安装以及配置步骤如下（本文以tomcat-8.5.16为例）
### 1.下载
```shell
# /usr/share 中创建 apache-tomcat 目录，然后进入该目录
cd /usr/share/apache-tomcat
curl -O http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v8.5.16/bin/apache-tomcat-8.5.16.tar.gz
tar -zxvf apache-tomcat-8.5.16.tar.gz
```
### 2.配置Tomcat为服务运行
首先在`/etc/init.d`目录中创建`tomcat`脚本
```shell
cd /etc/init.d
vi tomcat
```
然后录入如下内容(注意替换为你的`JDK`和`Tomcat`的目录)：
```
#!/bin/bash
# description: Tomcat Start Stop Restart
# processname: tomcat
# chkconfig: 234 20 80
JAVA_HOME=/usr/java/jdk1.8.0_131
export JAVA_HOME
PATH=$JAVA_HOME/bin:$PATH
export PATH
CATALINA_HOME=/usr/share/apache-tomcat/apache-tomcat-8.5.16
case $1 in start)
sh $CATALINA_HOME/bin/startup.sh
;;
stop)
sh $CATALINA_HOME/bin/shutdown.sh
;;
restart)
sh $CATALINA_HOME/bin/shutdown.sh
sh $CATALINA_HOME/bin/startup.sh
;;
esac
exit 0
```
然后授予脚本权限
```shell
chmod 755 tomcat
```
使用`chkconfig`启动`tomcat`
```shell
chkconfig --add tomcat
chkconfig --level 234 tomcat on
```
验证
```shell
chkconfig --list tomcat
```
然后就可以启动，停止或者重启`tomcat`服务了
```shell
# 启动
service tomcat start
# 停止
service tomcat stop
# 重启
service tomcat restart
```
可以通过如下命令查看日志是否报错
```shell
tail -f /usr/share/apache-tomcat/apache-tomcat-8.5.16/logs/catalina.out
```
启动服务后，就可以访问`http://服务器ip:8080`查看`Tomcat`主页了。

## 3.Redis
### 1.安装依赖(如果以安装可以忽略)
```shell
yum install gcc-c++
yum install -y tcl
yum install wget
```
### 2.获取文件
可以直接直接下载压缩包或者`clone` `GitHub`上最新代码并切换到响应分支，本位以`3.2`版本为例
```shell
# 下载压缩包并且解压，也可以用 curl
wget http://download.redis.io/releases/redis-3.2.0.tar.gz
tar -xzvf redis-3.2.0.tar.gz
# clone 最新代码并且切换到3.2分支
git clone git@github.com:antirez/redis.git 
git checkout -b 3.2 origin/3.2
```
### 3.安装
然后进入到`redis`根目录分别执行如下命令
```shell
make
make install
```
然后直接执行`redis-server`就可以了，起服务后可以使用`redis-cli`进行验证。

### 4.配置
当然启动服务需要一些特殊配置的话，我们可以配置`redis.conf`文件，为了不破坏原文件，可以先复制一份
```shell
mkdir -p /etc/redis
cp redis.conf /etc/redis
```
然后根据不同需求进行不同的配置后，就可以使用如下命令执行了
```shell
/usr/local/bin/redis-server /etc/redis/redis.conf
```
使用如下命令查看服务
```shell
ps -ef | grep redis 
```
如果需要开机启动，那么需要将命令写入`/etc/rc.local`中
```shell
echo "/usr/local/bin/redis-server /etc/redis/redis.conf &" >> /etc/rc.local
```

## 4.部署
部署`Web App`就相对简单了很多，首先确保依赖的服务是否开启，比如`mysql`，`redis`等，然后将打好的`war`包放到`Tomcat`目录下的`webapps`目录中(也就是本文/usr/share/apache-tomcat/apache-tomcat-8.5.16/webapps)，然后启动`Tomcat`就可以了，`war`包会自动解压，比如`war`包名称为`test.war`,然后通过`http://服务ip:8080/test`对该应用进行验证。

如果`8080`端口有冲突，我们需要配置不同的端口，那么进入`Tomcat`目录中的`conf`目录，然后在`server.xml`文件中找到类似如下的配置：
```xml
<Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
```
然后修改`port`即可。


