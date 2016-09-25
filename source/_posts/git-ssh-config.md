---
title: Git配置SSH
date: 2016-01-11 21:07:32
categories: Git
tags: Git
---
#### 1.设置Git的用户名和邮件
执行如下命令：
``` linux
    git config --global user.name "UserName"
    git config --global user.email "username@xx.xx"
```
<!--more-->
将上面的UserName和username@xx.xx替换成你的用户名和邮件
#### 2.生成密钥
使用ssh-keygen生成密钥，如下：
``` linux
    ssh-keygen -t rsa -C "username@xx.xx"
```
执行命令后，会提示录入密码，可忽略（如果不是第一次执行该命令，会提示是否覆盖），最后在用户目录下的.ssh目录中会生成id_rsa和id_rsa.pub文件
#### 3.将密钥添加至ssh-agent
我们可以将密钥添加到ssh-agent中进行管理，再添加之前，需要确保ssh-agent可用，执行如下命令：
``` linux
    eval "$(ssh-agent -s)"
```
执行之后，会显示Agent的pid，然后我们用ssh-add将密钥添加到ssh-agent，执行如下命令：
``` linux
    ssh-add ~/.ssh/id_rsa
```
#### 4.添加SSH keys
在github的Settings中，找到SSh keys，点击Add SSH key，将id_rsa.pub内容添加即可。