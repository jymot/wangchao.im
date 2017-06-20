---
title: Mac上如何配置周期任务和 easyhosts 的使用
date: 2017-06-20 17:06:09
categories: Mac
tags: [Mac, 周期, Hosts]
---

### [easyhosts](https://github.com/forkgood/easyhosts)
该项目基于 `Github` 项目整合的远程 `Hosts` 直链，适配多种规则、终端，每**30**分钟自动同步一次`Github`最新可用项目并提供打包下载。所以我们可以替换本地的`hosts`文件，已达到访问`Google，Facebook，Instagram`等网站的目的。

这里，我们只需要周期执行脚本，更新我们的`hosts`文件就可以了。

首先为们`clone`一下工程
```bash
git clone https://github.com/forkgood/easyhosts.git
```

然后将我们的更新脚本放到`clone`的目录中。

比如更新`hosts`文件的脚本叫`schedule-host.sh`，其内容如下：
```bash
#!/bin/bash
git pull
# 将 pwd 替换为你电脑的登陆密码，也就是 root 权限需要的密码。
# mac 中需要使用 hosts.txt 文件
echo "pwd"|sudo -S cp -rf  hosts.txt /etc/hosts
```

接下来就是周期执行脚本了。

### Mac上周期执行任务
主要有两种方式：
 * launchctl
 * Linux 上的 crontab
 
本次主要讲一下`launchctl`的使用。

##### 1.创建`plist`文件
比如文件名为`im.wangchao.schedulehosts.plist`,内容如下：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>im.wangchao.schedulehosts</string>   <!-- 名称 -->
	<key>ProgramArguments</key>
	<array>
		<string>/Users/xxx/xxx/easyhosts/schedule-host.sh</string>  <!-- 需要执行的脚本，绝对路径，这里直接使用上面创建的更新 hosts 的脚本 -->
	</array>
	<key>StartInterval</key>
	  <integer>18000</integer>  <!-- 执行的周期间隔，单位为秒 -->
</dict>
</plist>

```
为了确保我们的`plist`文件正确，我们可以使用`plutil -lint`对文件进行校验。

##### 2.保存`plist`文件
将我们刚刚创建的`plist`文件保存到`/Library/LaunchAgents`目录下即可。

 * ~/Library/LaunchAgents 由用户自己定义的任务项
 * /Library/LaunchAgents 由管理员为用户定义的任务项
 * /Library/LaunchDaemons 由管理员定义的守护进程任务项
 * /System/Library/LaunchAgents 由Mac OS X为用户定义的任务项
 * /System/Library/LaunchDaemons 由Mac OS X定义的守护进程任务项

其中`/System/Library`，`/Library`和`~/Library`目录的区别？
  
 * `/System/Library`目录是存放Apple自己开发的软件
 * `/Library`目录是系统管理员存放的第三方软件
 * `~/Library/`是用户自己存放的第三方软件
  
`LaunchDaemons`和`LaunchAgents`的区别？
  
 * `LaunchDaemons`是用户未登陆前就启动的服务（守护进程）
 * `LaunchAgents`是用户登陆后启动的服务（守护进程）

##### 3.加载`plist`文件
相关命令如下：
```bash
# 加载任务
launchctl load -w im.wangchao.schedulehosts.plist
# 卸载任务
launchctl unload -w im.wangchao.schedulehosts.plist
# 查看任务列表
launchctl list | grep 'im.wangchao.schedulehosts'
```