---
title: TextView支持的HTML标签
date: 2016-01-12 13:39:26
categories: Android
tags: Android
---
Android中TextView并不支持所有的HTML标签，如果需要更为复杂的操作最好使用WebView，今天再网上看到TextView支持的HTML标签的总结，记录在这里：
<!--more-->
``` html
    HTML Tags Supported By TextView
    There is a lovely method on the android.text.Html class, 
    fromHtml(), that converts HTML into a Spannable for use with a TextView.
    
    However, the documentation does not stipulate what HTML tags are supported, 
    which makes this method a bit hit-or-miss. More importantly, it means that you
    cannot rely on what it will support from release to release.
    
    I have filed an issue requesting that Google formally document what it intends 
    to support. In the interim, from a quick look at the source code, here’s what 
    seems to be supported as of Android 2.1:
    
    <a href="...">
    <b>
    <big>
    <blockquote>
    <br>
    <cite>
    <dfn>
    <div align="...">
    <em>
    <font size="..." color="..." face="...">
    <h1>
    <h2>
    <h3>
    <h4>
    <h5>
    <h6>
    <i>
    <img src="...">
    <p>
    <small>
    <strike>
    <strong>
    <sub>
    <sup>
    <tt>
    <u>
```