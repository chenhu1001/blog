---
title: macOS下如何编译FFmpeg for macOS APP
date: 2017-08-11 14:39:15
categories: 音视频
tags: [音视频]
---
我们今天来说说如何编译出适用于macOS APP的库，包括动态库和静态库。
## 一、基本编译
1、首先我们下载一个最新的ffmpeg源码。

```
git clone https://git.ffmpeg.org/ffmpeg.git
```

2、配置./configure选项，这个要注意需要设置对macOS最低版本的要求，否则是默认当前本机的最新系统如，这样的话在使用库的时候，如果是APP要运行在10.10及之下的系统时候，就会报错。
<!--more-->

```
--extra-cflags=-mmacosx-version-min=10.8 --extra-ldflags=-mmacosx-version-min=10.8
```

3、执行./configure内容如下：

```
./configure --target-os=darwin --enable-static --enable-swscale --enable-nonfree  --enable-gpl --enable-version3 --enable-nonfree --disable-programs  --libdir=/ffmpegbuild/lib --incdir=/ffmpegbuild/include --enable-shared --extra-cflags=-mmacosx-version-min=10.8 --extra-ldflags=-mmacosx-version-min=10.8 
```

4、执行编译和安装

```
make && sudo make install  
```

5、在根目录下的ffmpegbuild目录中，就是编译好的头文件和库文件，包括静态库和动态库。

## 二、高级编译

前面的之所以说是基本编译，主要都是ffmpeg自带的库的编译，包括了几乎全部的大部分的Decoder解码编译器，但是对于Encoder编码编译器，却不是特别多，比如aac就只有解码器没有编码器，如果想要对一个音频转换到aac格式，那么这时候就需要用的aac编码器。

1、下载和编译aac库

```
git clone https://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
./autogen.sh /* 执行这个一步的需要automake，如果没有可以直接brew install automake */
./configure —enable-shared —enable-static —prefix=/Users/forcetech/Downloads/opt/
make && sudo make install
```

当然也可以直接通过brew安装编译后的aac库，下面是我使用的命令

```
brew install fdk-aac
```

2、下载和编译x264库

```
git clone http://git.videolan.org/git/x264.git.
cd x264
./configure —disable-asm —enable-shared —enable-static —prefix=/Users/forcetech/Downloads/opt/
make && sudo make install
 ```

当然也可以直接通过brew安装编译后的x264库，下面是我使用的命令行

```
brew install x264
```

3、./configure配置
这里要注意，需要把acc、x264的库文件和头文件的路径加到配置里面，要不回出错，提示aac not found。

```
./configure --target-os=darwin --enable-static --enable-swscale --enable-libfdk-aac --enable-libx264 --enable-nonfree  --enable-gpl --enable-version3 --enable-nonfree --disable-programs  --libdir=/ffmpegbuild/lib --incdir=/ffmpegbuild/include --enable-shared --extra-cflags=-mmacosx-version-min=10.8 --extra-ldflags=-mmacosx-version-min=10.8 --extra-cflags=-I/Users/forcetech/Downloads/opt/include --extra-ldflags=-L/Users/forcetech/Downloads/opt/lib --prefix=/Users/forcetech/Downloads/opt/
```

4、执行编译和安装

```
make && sudo make install  
```

5、在根目录下的ffmpegbuild目录中，就是编译好的头文件和库文件，包括静态库和动态库。

