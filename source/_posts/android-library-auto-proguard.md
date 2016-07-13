---
title: Android Library 混淆
date: 2016-07-13 08:32:44
categories: Android
tags: Proguard
---
我们使用或者自己创建Library库的时候，难免会增加一些混淆规则。但是这些规则需要手动增加到引用这个Library库主工程混淆文件中，非常的不方便。今天无意中发现一个自动讲Library库中的混淆规则加入到主工程混淆文件的方法，具体如下：

* 将该Library库需要的混淆规则写入到该库的混淆文件中
* 在该Library库的build.gradle文件中的defaultConfig里配置consumerProguardFiles属性

```gradle
defaultConfig {
    consumerProguardFiles 'proguard-rules.txt'
}
```
如上所示，*proguard-rules.txt*为Library库中混淆文件的文件名。
需要注意的是，混淆文件中不支持如下指令：
```
-injars, -outjars, -libraryjars, -printmapping
```