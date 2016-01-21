---
title: OpenSSL之RSA
date: 2016-01-21 22:02:22
categories: Openssl
tags: RSA
---
OpenSSL集成了众多密码算法，今天主要说下RSA非对称加解密以及在Android中的使用。
那么我们需要先了解一下OpenSSL关于RSA的相关命令使用方法
<!--more-->
### CMD
#### 1.生成私钥
```bash
    openssl genrsa -out private.pem 1024
```
如上所示，我们即生成了名为private.pem的私钥文件，密钥长度1024，密钥长度范围在512～2024之间
#### 2.生成公钥
```bash
    openssl rsa -in private.pem -pubout -out public.pem
```
所以我们就生成了公钥文件
#### 3.公钥加密
```bash
    openssl rsautl -encrypt -in fileName -inkey public.pem -pubin -out fileName.en 
```
如上所示，我们用公钥对fileName文件进行了加密得到fileName.en文件
#### 4.私钥解密
```bash
    openssl rsautl -decrypt -in fileName.en -inkey private.key -out fileName.de
```
我们用私钥对fileName.en文件解密得到fileName.de文件

### Android
说到这里，对于RSA的基本操作就结束了，但是我们一般生成密钥对后，我们需要在我们的代码中使用，这里以Android
为例，但是我们在代码中不能直接使用之前生成的私钥，需要对密钥进行PKCS#8编码，执行如下命令：
```bash
    openssl pkcs8 -topk8 -in private.pem -out private_android.pem -nocrypt
```
我们得到的private_android.pem就可以在代码中使用了
