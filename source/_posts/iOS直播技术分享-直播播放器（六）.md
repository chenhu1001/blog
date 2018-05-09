---
title: iOS直播技术分享-直播播放器（六）
date: 2016-10-25 14:07:25
categories: 音视频
tags: [音视频]
---
随着互联网技术的飞速发展，移动端播放视频的需求如日中天，由此也催生了一批开源、闭源的播放器，但是无论这个播放器功能是否强大、兼容性是否优秀，它的基本模块通常都是由以下部分组成：事务处理、数据的接收和解复用、音视频解码以及渲染，其基本框架如下图所示：
<!--more-->
![直播技术流程](http://7xk4rv.com1.z0.glb.clouddn.com/iOS%E7%9B%B4%E6%92%AD%E6%8A%80%E6%9C%AF%E5%88%86%E4%BA%AB-%E7%9B%B4%E6%92%AD%E6%92%AD%E6%94%BE%E5%99%A8%EF%BC%88%E5%85%AD%EF%BC%89_1.png)
针对各种铺天盖地的播放器项目，选取了比较出众的ijkplayer进行源码剖析。它是一个基于FFPlay的轻量级Android/iOS视频播放器，实现了跨平台的功能，API易于集成；编译配置可裁剪，方便控制安装包大小。

# 总体说明
打开ijkplayer，可看到其主要目录结构如下:

tool - 初始化项目工程脚本
config - 编译ffmpeg使用的配置文件
extra - 存放编译ijkplayer所需的依赖源文件, 如ffmpeg、openssl等
ijkmedia - 核心代码
&emsp;&emsp;ijkplayer - 播放器数据下载及解码相关
&emsp;&emsp;ijksdl - 音视频数据渲染相关
ios - iOS平台上的上层接口封装以及平台相关方法
android - android平台上的上层接口封装以及平台相关方法

# 初始化流程
初始化完成的主要工作就是创建播放器对象，打开ijkplayer/ios/IJKMediaDemo/IJKMediaDemo.xcodeproj工程，可看到IJKMoviePlayerViewController类中viewDidLoad方法中创建了IJKFFMoviePlayerController对象，即iOS平台上的播放器对象。

```
- (void)viewDidLoad
{
    ......
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    ......
}
```