---
title: Linux 常用命令
date: 2017-10-09 20:48:17
categories: [Linux]
tags: [Linux]
---

### 1.cat
查看文件内容，可以结合`grep`使用
```bash
[root@user: ~]# cat test.txt
hahatest
aaadd
[root@user: ~]# cat test.txt | grep haha
hahatest
```

### 2.echo
输出字符，可以结合`>`或`>>`进行文件写入
```bash
[root@user: ~]# echo "haha" > test.txt
[root@user: ~]# echo "haha2" > test.txt
[root@user: ~]# cat test.txt
haha2
[root@user: ~]# echo "haha" >> test.txt
[root@user: ~]# cat test.txt
haha2
haha
```

### 3.touch
修改文件时间戳，或者新建一个不存在的文件
```bash
# 创建文件
[root@user: ~]# touch test.log test1.log
[root@user: ~]# ll
-rw-r--r-- 1 root root    0 9-28 16:01 test.log
-rw-r--r-- 1 root root    0 9-28 16:01 test1.log
-rw-r--r-- 1 root root    0 9-28 18:42 test3.log
# 设置test.log和test3.log的时间戳相同
[root@user: ~]# touch -r test3.log test.log
[root@user: ~]# ll
-rw-r--r-- 1 root root    0 9-28 18:42 test.log
-rw-r--r-- 1 root root    0 9-28 16:01 test1.log
-rw-r--r-- 1 root root    0 9-28 18:42 test3.log
# 设置文件时间戳
[root@user: ~]# touch -t 201711142234.50 test.log
[root@user: ~]# ll
-rw-r--r-- 1 root root    0 2017-11-14 test.log
-rw-r--r-- 1 root root    0 9-28 16:01 test1.log
-rw-r--r-- 1 root root    0 9-28 18:42 test3.log
```

### 4.tar
tar压缩相关
```bash
# 创建tar文件
[root@user: ~]# tar cvf target.tar dir/
# 解压缩tar文件
[root@user: ~]# tar xvf target.tar
# 查看tar文件
[root@user: ~]# tar tvf target.tar
```

### 5.grep
```bash
# 在文件中查找字符串(不区分大小写)
[root@user: ~]# grep -i "haha" test.txt
# 输出成功匹配的行，以及该行之后的三行
[root@user: ~]# grep -A 3 -i "haha" test.txt
# 在一个文件夹中递归查询包含指定字符串的文件
[root@user: ~]# grep -r "test" *
```

### 6.gzip
```bash
# 创建一个*.gz的压缩文件
[root@user: ~]# gzip test.txt
# 解压*.gz文件
[root@user: ~]# gzip -d test.txt.gz
# 显示压缩的比率
[root@user: ~]# gzip -l *.gz
compressed        uncompressed  ratio uncompressed_name
     23709               97975  75.8% asp-patch-rpms.txt
```

### 7.bzip2
```bash
# 创建*.bz2压缩文件
[root@user: ~]# bzip2 test.txt
# 解压*.bz2文件
[root@user: ~]# bzip2 -d test.txt.bz2
```

### 8.uzip
```bash
# 解压*.zip文件
[root@user: ~]# unzip test.zip
# 查看*.zip文件的内容
[root@user: ~]# unzip -l jasper.zip
Archive:  jasper.zip
Length     Date   Time    Name
--------    ----   ----    ----
40995  11-30-98 23:50   META-INF/MANIFEST.MF
32169  08-25-98 21:07   classes_
15964  08-25-98 21:07   classes_names
10542  08-25-98 21:07   classes_ncomp
```

### 9.shutdown
```bash
# 关闭系统并立即关机
[root@user: ~]# shutdown -h now
# 10分钟后关机
[root@user: ~]# shutdown -h +10
# 重启
[root@user: ~]# shutdown -r now
# 重启期间强制进行系统检查
[root@user: ~]# shutdown -Fr now
```

## 参考
[写代码怎能不会这些Linux命令？](https://zhuanlan.zhihu.com/p/28674639)
