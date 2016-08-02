---
title: Android NDK - Type Signatures
date: 2016-08-02 08:08:20
categories: Android
tags: NDK
---
### 1.The JNI uses the Java VM’s representation of type signatures.

| Type Signature     | Java Type     |
| ----- | ------ |
| Z | boolean |
| B | byte |
| C | char |
| S | short | 
| I | int |
| J | long |
| F | float |
| D | double |
| L fully-qualified-class | fully-qualified-class |
| [ type | type[] |
| ( arg-types ) ret-type | method type |

### 2.其中前几个基本类型比较好理解，只对对象和数组进行举例：

| Type Signature   | Java Type   |
| ------ | ------ |
| Ljava/lang/String; | String |
| [ I | int[] |
| [ Ljava/lang/Object; | Object[] |

 * 对象类型：以"L"开头，以";"结尾，中间是用"/" 隔开。如上表第1个
 * 数组类型：以"["开，。如上表（n维数组的话，则是前面多少个"["而已，如"[[I"表示“int[][]”）
 * 对象数组类型：同数组类型
 
 
### 3.还有就是方法的signature，举几个例子：
 
 | signature  | Java Type   |
 | ------ | ------ |
 | ()Ljava/lang/String; | String func() |
 | (ILjava/lang/String;)I | int func(int a, String b) |
 | ([I)V | void func(int[] arr) |