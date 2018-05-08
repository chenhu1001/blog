---
title: iOS播放动态gif图片
date: 2016-06-20 14:05:55
categories: iOS
tags: [iOS]
---
&emsp;&emsp;图片分为静态和动态两种，图片的格式有很多种，在开发中比较常见的是.png和.jpg的静态图片，但有的时候在App中需要播放动态图片，比如.gif格式的小表情头像，在IOS中并没有提供直接显示动态图片的控件，下面就介绍几种显示动态图片的方式。
<!--more-->
### 一、UIImageView用来显示图片，使用UIImageView中的动画数组来实现图片的动画效果

``` 
// 创建UIImageView，添加到界面 
UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
[self.view addSubview:imageView]; 
//
// 创建一个数组，数组中按顺序添加要播放的图片（图片为静态的图片） 
NSMutableArray *imgArray = [NSMutableArray array]; 
for (int i=1; i<7; i++) { 
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"clock%02d.png",i]]; 
    [imgArray addObject:image]; 
} 
// 把存有UIImage的数组赋给动画图片数组 imageView.animationImages = imgArray; 
// 设置执行一次完整动画的时长
 imageView.animationDuration = 6*0.15; 
// 动画重复次数 （0为重复播放） imageView.animationRepeatCount = 0; 
// 开始播放动画  [imageView startAnimating]; 
// 停止播放动画 - (void)stopAnimating; 
// 判断是否正在执行动画 - (BOOL)isAnimating;
```

## 二、用UIWebView来显示动态图片

``` 
// 得到图片的路径 
NSString *path = [[NSBundle mainBundle] pathForResource:@"happy" ofType:@"gif"]; 
// 将图片转为NSData 
NSData *gifData = [NSData dataWithContentsOfFile:path]; 
// 创建一个webView，添加到界面 
UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 150, 200, 200)]; 
[self.view addSubview:webView]; 
// 自动调整尺寸 
webView.scalesPageToFit = YES;
// 禁止滚动
webView.scrollView.scrollEnabled = NO; 
// 设置透明效果 
webView.backgroundColor = [UIColor clearColor];webView.opaque = 0; 
// 加载数据 
[webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
```

## 三、使用第三方FLAnimatedImage

```
FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif"]]];
FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
imageView.animatedImage = image;
imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
[self.view addSubview:imageView];
```

## 四、总结
1、通过UIImageView显示动画效果，实际上是把动态的图拆成了一组静态的图，放到数组中，播放的时候依次从数组中取出。如果播放的图片比较少占得内存比较小或者比较常用（比如工具条上一直显示的动态小图标），可以选择用imageNamed：方式获取图片，但是通过这种方式加到内存中，使用结束，不会自己释放，多次播放动画会造成内存溢出问题。因此，对于大图或经常更换的图，在取图片的时候可以选择imageWithContentsOfFile:方式获取图片，优化内存。  
2、使用UIWebView显示图片需要注意显示图片的尺寸与UIWebView尺寸的设置，如果只是为了显示动态图片，可以禁止UIWebView滚动。在显示动态图片的时候，即使是动图的背景处为透明，默认显示出来是白色背景，这个时候需要手动设置UIWebView的透明才能达到显示动图背景透明的效果。  
3、UIImageView与第三方的FLAnimatedImage都是通过定时器来控制图片模拟的动画，播放的时候是设置每一帧的时长，因此在使用的时候，要尽量与动图原本的时长靠近，不然动画效果会有些奇怪。而通过UIWebView加载Gif动图的时候会保持原有的帧速，不需要再次设置。

转载请注明原地址，Clang的博客：https://chenhu1001.github.io 谢谢！