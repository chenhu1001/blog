---
title: iOS直播技术分享-直播播放器（六）
date: 2016-10-25 14:07:25
categories: 音视频
tags: [音视频]
---
随着互联网技术的飞速发展，移动端播放视频的需求如日中天，由此也催生了一批开源、闭源的播放器，但是无论这个播放器功能是否强大、兼容性是否优秀，它的基本模块通常都是由以下部分组成：事务处理、数据的接收和解复用、音视频解码以及渲染，其基本框架如下图所示：
<!--more-->
![直播技术流程](http://chenhu1001.github.io/images/iOS直播技术分享-直播播放器（六）_1.png)
针对各种铺天盖地的播放器项目，选取了比较出众的ijkplayer进行源码剖析。它是一个基于FFPlay的轻量级Android/iOS视频播放器，实现了跨平台的功能，API易于集成；编译配置可裁剪，方便控制安装包大小。

# 一、总体说明
打开ijkplayer，可看到其主要目录结构如下:

tool - 初始化项目工程脚本
config - 编译ffmpeg使用的配置文件
extra - 存放编译ijkplayer所需的依赖源文件, 如ffmpeg、openssl等
ijkmedia - 核心代码
&emsp;&emsp;ijkplayer - 播放器数据下载及解码相关
&emsp;&emsp;ijksdl - 音视频数据渲染相关
ios - iOS平台上的上层接口封装以及平台相关方法
android - android平台上的上层接口封装以及平台相关方法

# 二、初始化流程
初始化完成的主要工作就是创建播放器对象，打开ijkplayer/ios/IJKMediaDemo/IJKMediaDemo.xcodeproj工程，可看到IJKMoviePlayerViewController类中viewDidLoad方法中创建了IJKFFMoviePlayerController对象，即iOS平台上的播放器对象。

```
- (void)viewDidLoad
{
    ......
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    ......
}
```

查看ijkplayer/ios/IJKMediaPlayer/IJKMediaPlayer/IJKFFMoviePlayerController.m文件，其初始化方法具体实现如下：

```
- (id)initWithContentURL:(NSURL *)aUrl
             withOptions:(IJKFFOptions *)options
{
    if (aUrl == nil)
        return nil;

    // Detect if URL is file path and return proper string for it
    NSString *aUrlString = [aUrl isFileURL] ? [aUrl path] : [aUrl absoluteString];

    return [self initWithContentURLString:aUrlString
                              withOptions:options];
}
```

```
- (id)initWithContentURLString:(NSString *)aUrlString
                   withOptions:(IJKFFOptions *)options
{
    if (aUrlString == nil)
        return nil;

    self = [super init];
    if (self) {
        ......
        // init player
        _mediaPlayer = ijkmp_ios_create(media_player_msg_loop);
        ......
    }
    return self;
}
```

可发现在此创建了IjkMediaPlayer结构体实例_mediaPlayer：

```
IjkMediaPlayer *ijkmp_ios_create(int (*msg_loop)(void*))
{
    IjkMediaPlayer *mp = ijkmp_create(msg_loop);
    if (!mp)
        goto fail;

    mp->ffplayer->vout = SDL_VoutIos_CreateForGLES2();
    if (!mp->ffplayer->vout)
        goto fail;

    mp->ffplayer->pipeline = ffpipeline_create_from_ios(mp->ffplayer);
    if (!mp->ffplayer->pipeline)
        goto fail;

    return mp;

fail:
    ijkmp_dec_ref_p(&mp);
    return NULL;
}
```

在该方法中主要完成了三个动作：

1、创建IJKMediaPlayer对象

```
IjkMediaPlayer *ijkmp_create(int (*msg_loop)(void*))
{
    IjkMediaPlayer *mp = (IjkMediaPlayer *) mallocz(sizeof(IjkMediaPlayer));
    ......
    mp->ffplayer = ffp_create();
    ......
    mp->msg_loop = msg_loop;
    ......
    return mp;
}
```

通过ffp_create方法创建了FFPlayer对象，并设置消息处理函数。

2、创建图像渲染对象SDL_Vout

```
SDL_Vout *SDL_VoutIos_CreateForGLES2()
{
    SDL_Vout *vout = SDL_Vout_CreateInternal(sizeof(SDL_Vout_Opaque));
    if (!vout)
        return NULL;

    SDL_Vout_Opaque *opaque = vout->opaque;
    opaque->gl_view = nil;
    vout->create_overlay = vout_create_overlay;
    vout->free_l = vout_free_l;
    vout->display_overlay = vout_display_overlay;

    return vout;
}
```

3、创建平台相关的IJKFF_Pipeline对象，包括视频解码以及音频输出部分

```
IJKFF_Pipeline *ffpipeline_create_from_ios(FFPlayer *ffp)
{
    IJKFF_Pipeline *pipeline = ffpipeline_alloc(&g_pipeline_class, sizeof(IJKFF_Pipeline_Opaque));
    if (!pipeline)
        return pipeline;

    IJKFF_Pipeline_Opaque *opaque     = pipeline->opaque;
    opaque->ffp                       = ffp;
    pipeline->func_destroy            = func_destroy;
    pipeline->func_open_video_decoder = func_open_video_decoder;
    pipeline->func_open_audio_output  = func_open_audio_output;

    return pipeline;
}
```

至此已经完成了ijkplayer播放器初始化的相关流程，简单来说，就是创建播放器对象，完成音视频解码、渲染的准备工作。
  
作者金山视频云，首发简书 [Jianshu.com](https://www.jianshu.com/p/daf0a61cc1e0 )





