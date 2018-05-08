---
title: iOS判断一个库是否包含bitcode
date: 2016-07-01 14:06:05
categories: iOS
tags: [iOS]
---
&emsp;&emsp;苹果在 Xcode 7 中引入了 bitcode，在打包提交时，会包含 bitcode。如果项目用到了以二进制格式发布的第三方库，第三方库也需要包含 bitcode 才行。如果没有包含 bitcode，编译时会报错，除非手动关闭 bitcode 特性。  
<!--more-->
&emsp;&emsp;除了通过编译时的报错来判断第三方库是否包含 bitcode，我们也可以自己检查。首先需要判断 library 是否是 fat 的，可以用 lipo 命令：

```
lipo -info libdemo.a
```

&emsp;&emsp;其中 libdemo.a 就是我们要检查的文件。一般第三方库都会发布 fat library 以支持各个 CPU 架构。
&emsp;&emsp;接着，如果是 fat library，需要将某个 CPU 架构的 slice 提取出来：

```
lipo -thin arm64 libdemo.a -output libdemo-arm64.a
```

&emsp;&emsp;这样，我们就将 arm64 这个 slice 提取出来了。接下来我们需要将这个 slice 里面的目标文件解压出来，可以用 ar 命令：

```
ar -x libdemo-arm64.a
```

&emsp;&emsp;假设我们解压了 libdemo_la-util.o 这个目标文件。最后，我们检查目标文件中，是否包含 __bicode 这个段（segment）：

```
otool -l libdemo_la-util.o | grep bitcode
```

&emsp;&emsp;如果找到了，说明第三方库是支持 bitcode 的。 
 
原文链接：http://www.tuicool.com/articles/nMzABvM