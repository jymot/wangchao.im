---
title: Https证书配置
date: 2017-01-19 08:18:35
categories: [Web]
tags: [Web, Https]
---
这几天把自己的博客配置了Https证书,这里主要记录一下我的配置过程。

首先采用的是[Let's Encrypt]颁发的免费证书,其次我是使用[acme.sh]配置的,这里主要说一下[acme.sh]的安装以及使用。

## 1.安装
官方方法使用如下命令即可:
```bash
curl  https://get.acme.sh | sh
```

如果执行失败,可以下载master分之最新代码,解压之后进入目录执行如下命令:
```bash
./acme.sh --install
```

安装成功后,acme.sh脚本在~/.acme.sh目录中,所以如果想直接执行脚本,那么需要设置环境变量,后文中因为配置过了环境变量所以直接执行了acme.sh脚本。

## 2.配置
安装成功后,我们需要创建一个存放[Let's Encrypt]验证文件的文件夹(最好不要存放到root目录中),比如我们创建如下目录:
```
mkdir -p /www/acme-challenges
```

<!--more-->

因为[Let's Encrypt]在验证时候,会访问下URL`http://wangchao.im//.well-known/acme-challenge`(wangchao.im为我的域名,后面配置中如果您要使用请替换为您的域名)进行验证,所以我们要配置`nginx`(因为我使用的是nginx,所以这里仅说一下nginx)使该URL代理我们刚才创建的目录,配置如下:
```
server {
    listen       80;
    server_name  wangchao.im www.wangchao.im;

    ...

    # 访问http时转到https
    location / {
       return 301 https://$http_host$request_uri;
    }

    # 用于验证服务, acme 会自动将认证 token 放在此文件夹下面, 并通过http请求来验证
    location ^~ /.well-known/acme-challenge/ {
      alias /www/acme-challenges/.well-known/acme-challenge/;
      #添加 $uri/ $uri.html 显示index.html
      try_files $uri $uri/ $uri.html =404;
    }

    # 和上面的效果相同
    #location ^~ /.well-known/acme-challenge/ {
    #   root /www/acme-challenges/;
    #   try_files $uri $uri/ $uri.html =404;
    #}
    ...
}
```

## 3.证书生成
我采用的是http方式,执行命令如下:
```bash
acme.sh --issue -d wangchao.im -d www.wangchao.im --webroot /www/acme-challenges/ 
```
通过`-d`添加多个域名,如果需要看日志可以追加`--debug`或者`--log`参数。
证书生成成功后,会出现在`~/.acme.sh/wangchao.im/`目录下,我们可以把它们复制出来,比如我复制到了`/etc/nginx/ssl/wangchao.im`目录中,然后执行如下脚本进行安装证书:
```bash
acme.sh --installcert  -d wangchao.im --keypath   /etc/nginx/ssl/wangchao.im/wangchao.im.key --fullchainpath /etc/nginx/ssl/wangchao.im/wangchao.im.cer --reloadcmd  "service nginx force-reload"
```

## 4.配置证书
创建行的`nginx`配置文件,添加如下内容(其中配置需要将域名和文件目录替换为您使用的名称和路径):
```bash

# HTTPS server
#
server {
    listen       443 ssl;
    server_name  wangchao.im www.wangchao.im;

    ## Strong SSL Security
    ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
    ssl on;
    ssl_certificate /etc/nginx/ssl/wangchao.im/wangchao.im.cer;
    ssl_certificate_key /etc/nginx/ssl/wangchao.im/wangchao.im.key;

    # Backwards compatible ciphers to retain compatibility with Java IDEs
    ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;

    # 根证书 + 中间证书, acme.sh 会自动生成一个 fullchain.cer,
    # 比如 /root/.acme.sh/wangchao.im/fullchain.cer
    # 将其拷贝到 /etc/nginx/ssl/wangchao.im/wangchao_im_fullchain.cer
    ssl_trusted_certificate    /etc/nginx/ssl/wangchao.im/wangchao_im_fullchain.cer;

    ssl_stapling               on;
    ssl_stapling_verify        on;

    location / {
       # root   /usr/share/nginx/html;
       # index  index.html index.htm;
       # 需要替换为自己的服务
       proxy_pass  http://127.0.0.1:4000;
    }

    ## Don't show the nginx version number, a security best practice
    server_tokens off;
}

```

配置成功后重启`nginx`就可以了。

目前由于`acme`协议和`letsencrypt CA`都在频繁的更新,因此`acme.sh`也经常更新以保持同步,我们可以设置自动更新,命令如下:
```bash
acme.sh  --upgrade  --auto-upgrade
```
如果需要关闭自动更新,执行如下命令:
```bash
acme.sh --upgrade  --auto-upgrade  0
```

## 参考文献
 - [Let's Encrypt]
 - [acme.sh]
 - [acme.sh wiki]


[Let's Encrypt]: https://letsencrypt.org/
[acme.sh]: https://github.com/Neilpang/acme.sh
[acme.sh wiki]: https://github.com/Neilpang/acme.sh/wiki/%E8%AF%B4%E6%98%8E
