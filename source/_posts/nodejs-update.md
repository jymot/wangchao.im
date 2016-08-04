---
title: NodeJs更新
date: 2016-01-10 12:55:44
categories: NodeJs
tags: NodeJs
---
### 1.更新npm
``` linux
    npm update -g
```
<!--more-->
### 2.更新nodejs
#### 1) Clear NPM's cache:
``` linux
    sudo npm cache clean -f
```
#### 2) Install a little helper called 'n'
``` linux
    sudo npm install -g n
```
#### 3) Install latest stable NodeJS version
``` linux
    sudo n stable
```