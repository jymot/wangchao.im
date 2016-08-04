---
title: xcode7中NSURLSession发送HTTP异常
date: 2016-02-23 16:52:17
categories: iOS
tags: iOS
---
今天在使用NSURLSession时候报了如下的错误：
```
    Application Transport Security has blocked a cleartext HTTP (http://) 
    resource load since it is insecure. Temporary exceptions can be configured 
    via your app's Info.plist file.
```

<!--more-->

解决办法如下为在info.plist文件中添加：
```
<key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
```