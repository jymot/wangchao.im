---
title: Android 反编译工具
date: 2016-08-09 21:27:10
categories: Android
tags: [Android, Android安全, 反编译]
---
整理一些关于Android反编译相关的工具，点击标题查阅官方详细说明。
#### 1.[ApkTool]
个人认为最好用的Android反编译工具，通常用其对APK进行二次开发或重新签名等工作，当然它的反编译和编译命令也比较简单。
example:
```bash
$ apktool d test.apk
$ apktool b test
```
<!--more-->

#### 2.[jadx]
jadx强大之处在于可以直接反编译到java，而且还提供了GUI版本。
example:
```bash
jadx[-gui] [options] <input file> (.dex, .apk, .jar or .class)
options:
 -d, --output-dir           - output directory
 -j, --threads-count        - processing threads count
 -r, --no-res               - do not decode resources
 -s, --no-src               - do not decompile source code
 -e, --export-gradle        - save as android gradle project
     --show-bad-code        - show inconsistent code (incorrectly decompiled)
     --no-replace-consts    - don't replace constant value with matching constant field
     --escape-unicode       - escape non latin characters in strings (with \u)
     --deobf                - activate deobfuscation
     --deobf-min            - min length of name
     --deobf-max            - max length of name
     --deobf-rewrite-cfg    - force to save deobfuscation map
     --deobf-use-sourcename - use source file name as class name alias
     --cfg                  - save methods control flow graph to dot file
     --raw-cfg              - save methods control flow graph (use raw instructions)
 -f, --fallback             - make simple dump (using goto instead of 'if', 'for', etc)
 -v, --verbose              - verbose output
 -h, --help                 - print this help
Example:
 jadx -d out classes.dex
```
#### 3.[dex2jar]
将dex文件转为jar。
#### 4.[JD-GUI]
java反编译GUI。
#### 4.[smali/baksmali]
分别是smali文件转为dex和dex转smali的工具。
example:
```bash
java -jar smali.jar classout/ -o classes.dex
java -jar baksmali.jar -o classout/ classes.dex
```
#### 5.[AXMLPrinter2]
xml文件转成普通文本文件(txt)。
example:
```bash
java -jar AXMLPrinter2.jar main.xml > main.txt
```

[ApkTool]: https://github.com/iBotPeaches/Apktool
[jadx]: https://github.com/skylot/jadx
[dex2jar]: https://github.com/pxb1988/dex2jar
[JD-GUI]: https://github.com/java-decompiler/jd-gui
[smali/baksmali]: https://github.com/JesusFreke/smali
[AXMLPrinter2]: http://code.google.com/p/android4me/downloads/list