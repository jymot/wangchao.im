---
title: Android 5.0后自定义权限注意事项
date: 2016-05-03 13:35:05
categories: Android
tags: Android Permission
---
### Android 5.0 说明
Starting in Android 5.0, the system enforces a new uniqueness restriction on custom permissions 
for apps that are signed with different keys. Now only one app on a device can define a given 
custom permission (as determined by its name), unless the other app defining the permission is 

<!--more-->

signed with the same key. If the user tries to install an app with a duplicate custom permission 
and is not signed with the same key as the resident app that defines the permission, the system blocks 
the installation.

### 解释
所以当我们在Android 5.0以及以上系统中使用自定义权限的时候，如果两个APK具有相同的签名，那么就不能使用相同命名的自定义权限。