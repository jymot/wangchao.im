---
title: Electron 打包
date: 2016-10-12 20:43:58
categories: Electron
tags: [Electron, Javascript]
---
最近简单看了下[Electron],[Electron]是什么?引用官网的一句话__Build cross platform desktop apps with JavaScript, HTML, and CSS__。简单的看了一下API然后做了一个小Demo,但是最后打包的时候还是查了一些资料,下面对打包做一个简单的介绍。

<!--more-->

打包使用[electron-packager],安装方法如下:
```bash
# for use in npm scripts
npm install electron-packager --save-dev

# for use from cli
npm install electron-packager -g
```
安装完成后,打包命令如下:
```bash
electron-packager <sourcedir> <appname> --platform=<platform> --arch=<arch> [optional flags...]

#例如
electron-packager ./app AppName --platform=darwin --arch=x64 --overwrite --ignore=dev-settings --prune
```
参数说明:

| 参数 | 说明 |
| ------ | ----------- |
| prune | 打包之前运行npm prune --production命令，devDependencies中的包都不会打包进去，很大程度减小包的大小 |
| asar | 自动运行 asar pack ，也可最后手动运行，更加可控 |
| ignore | 此参数指定的文件，将不会随带打包进去 |
| overwrite | 覆盖模式打包 |


[Electron]: http://electron.atom.io/
[electron-packager]: https://github.com/electron-userland/electron-packager
