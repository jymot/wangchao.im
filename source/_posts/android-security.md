---
title: Android安全之完整性校验
date: 2016-01-17 08:14:19
categories: Android
tags: [Android, Android安全]
---
最近在研究Android安全应用加固相关的技术，今天我先简单说下APK的完整性校验，首先我们先看一下一般APK里面的构造，下图为直接解压APK的目录结构：
<!--more-->
![目录结构](/images/android-integrity-01-20160120.png)
我们可以看到META-INF目录里面的MANIFEST.MF清单文件，里面记录了所有文件的SHA-1，所以我们当我们APK包中资源或dex有改变时候，或者二次打包（关于二次打包可以看我另外一篇文章
[Android二次打包](/2016/01/20/android-secondary-build/)）的时候，
该清单文件都会改变，所以我们就可以校验这个文件来确保APK的完整性，中心思想说完了那么我们下面说一下具体实现。

首先，我们需要获取到META-INF目录，我们知道安装一个APK后，会在存放在手机如下目录
```java
    /data/app/im.xxx.app-1.apk
```
在代码中我们可以使用
```java
    context.getPackageCodePath();
```
获取该文件路径，因为/data/app目录是只读的，所以我们需要把该APK拷贝出来，比如拷贝到包目录下的files或caches目录，然后我们把拷贝出来的APK解压到临时目录，我们这是就可以找到其对应的META-INF目录，接下来我们需要做的就是校验清单文件，到这里，我们可以计算出当前运行APK清单文件的摘要，所以我们只需要和我们打包时候清单文件摘要进行对比，即可得出当前APK是否被篡改，如果不相等即被篡改。那么打包时候计算的摘要要放到那里呢，当然是META-INF目录里面，我在打包结束的时候，在META-INF中创建了一个文件，文件名字为`SPECIAL-清单的md5`，所以我们在校验的时候，需要判断META-INF目录中以`SPECIAL-`开头的文件是否存在，并且截取后面的摘要值和META-INF目录中MANIFEST.MF计算的摘要进行对比，部分实现代码如下：
```java

    final private Runnable r = new Runnable() {
            @Override
            public void run() {
                //savePath = context.getFilesDir().getPath();
                String copyPath = savePath.concat("/copyApp.apk");
                //copy apk
                FileUtils.copyFile(codePath, copyPath);
    
                File copyApp = new File(copyPath);
                String renamePath = savePath.concat("/copyApp.zip");
                File renameApp = new File(renamePath);
                boolean result = copyApp.renameTo(renameApp);
                if (result){
                    String decompressPath = savePath.concat("/temp" + System.currentTimeMillis());
                    //decompress
                    try {
                        FileUtils.decompressZip(renameApp, decompressPath);
                        FileUtils.deleteFile(renameApp);
    
                        File meta_inf = new File(decompressPath + "/META-INF");
                        File[] metaFileArray = meta_inf.listFiles();
                        String checkEncryptDigest = null;
                        for (int i = 0; i < metaFileArray.length; i++){
                            final String fileName = metaFileArray[i].getName();
                            if (fileName.startsWith("SPECIAL-")){
                                checkEncryptDigest = fileName.substring(8);
                            }
                            Log.e(TAG, "fileName : " + fileName);
                        }
    
                        if (TextUtils.isEmpty(checkEncryptDigest)){
                            Log.e(TAG, "non integrity! file is not exists");
                        }
    
                        File manifest_mf = new File(decompressPath + "/META-INF/MANIFEST.MF");
                        String digest = DigestUtils.md5(manifest_mf);
                        if (TextUtils.isEmpty(digest)){
                            Log.e(TAG, "original digest is null");
                            return;
                        }
    
                        //todo 解密 checkEncryptDigest 得到摘要和 digest 进行比较
                        String checkDigest = "";
    
                        if (digest.equals(checkDigest)){
                            Log.e(TAG, "apk is integrity!");
                        } else {
                            Log.e(TAG, "non integrity!");
                        }
    
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        };
        
```

所以，我们可以知道当前APK是否被篡改，以上为部分代码，里面涉及到了`FileUtils`和`DigestUtils`类，还有未对md5加密，所以最后创建在META-INF中的文件应该是`SPECIAL-加密后的md5，并做Base64编码`，然后我们在代码里面解密后在进行校验（如果不加密，那么黑客在二次打包时候，很容易知道这个文件是干什么的，所以可以自己生成一个二次打包后的校验文件，所以我们需要进行加密，这样就算知道文件的作用但是没有我们的密钥也无法模拟创建校验文件）。后面整理完后，我会把工程整理好放到Github上。

有些同学会问，如何在打好的APK的META-INF中创建文件，下面贴出脚本：
```python

    #! /usr/bin/python
    import zipfile
    import sys
    import shutil
    
    src_empty_file = "empty"
    src_apk = sys.argv[1]
    shutil.copy(src_apk,channel_apk)
    
    zipped = zipfile.ZipFile(channel_apk, 'a', zipfile.ZIP_DEFLATED)
    special_md5 = "META-INF/SPECIAL-{md5}".format(md5 = sys.argv[2])
    zipped.write(src_empty_file, special_md5)
    zipped.close()
    
```
所以调用时候传入两个参数，第一个为需要修改的APK路径，第二个参数为清单文件的MD5。
