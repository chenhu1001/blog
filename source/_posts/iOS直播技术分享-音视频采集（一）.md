---
title: iOS直播技术分享-音视频采集（一）
date: 2016-07-02 14:06:16
categories: 音视频
tags: [音视频]
---
## 1、iOS直播技术的流程
&emsp;&emsp;直播技术的流程大致可以分为几个步骤：数据采集、图像处理（实时滤镜）、视频编码、封包、上传、云端（转码、录制、分发）、直播播放器。  
<!--more-->
* 数据采集：通过摄像头和麦克风获得实时的音视频数据；  
* 图像处理：将数据采集的输入流进行实时滤镜，得到我们美化之后的视频帧； 
* 视频编码：编码分为软编码和硬编码。现在一般的编码方式都是H.264，比较新的H.265据说压缩率比较高，但算法也相当要复杂一些，使用还不够广泛。软编码是利用CPU进行编码，硬编码就是使用GPU进行编码，软编码支持现在所有的系统版本，由于苹果在iOS8才开放硬编码的API，故硬编码只支持iOS8以上的系统；  
* 封包：现在直播推流中，一般采用的格式是FLV；  
* 上传：常用的协议是利用RTMP协议进行推流；  
* 云端：进行流的转码、分发和录制；  
* 直播播放器：负责拉流、解码、播放。
  
用一张腾讯云的图来说明上面的流程：  
![直播技术流程](http://chenhu1001.github.io/images/iOS直播技术分享-音视频采集（一）_1.png)
## 2、获取系统的授权
直播的第一步就是采集数据，包含视频和音频数据，由于iOS权限的要求，需要先获取访问摄像头和麦克风的权限：

请求获取访问摄像头权限

```
__weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            [_self.session setRunning:YES];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            break;
        default:
            break;
    }
```

请求获取访问麦克风权限

```
AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
 ```
 
 ## 3、配置采样参数
 
 音频：需要配置码率、采样率；
 视频：需要配置视频分辨率、视频的帧率、视频的码率。
 
 ## 4、音视频的录制   
 音频的录制
 
 ```
 self.taskQueue = dispatch_queue_create("com.1905.live.audioCapture.Queue", NULL);
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES withOptions:kAudioSessionSetActiveFlag_NotifyOthersOnDeactivation error:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleRouteChange:)
                                                     name: AVAudioSessionRouteChangeNotification
                                                   object: session];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleInterruption:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: session];
        
        NSError *error = nil;
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers error:nil];
        
        [session setMode:AVAudioSessionModeVideoRecording error:&error];
        
        if (![session setActive:YES error:&error]) {
            [self handleAudioComponentCreationFailure];
        }
        
        AudioComponentDescription acd;
        acd.componentType = kAudioUnitType_Output;
        acd.componentSubType = kAudioUnitSubType_RemoteIO;
        acd.componentManufacturer = kAudioUnitManufacturer_Apple;
        acd.componentFlags = 0;
        acd.componentFlagsMask = 0;
        
        self.component = AudioComponentFindNext(NULL, &acd);
        
        OSStatus status = noErr;
        status = AudioComponentInstanceNew(self.component, &_componetInstance);
        
        if (noErr != status) {
            [self handleAudioComponentCreationFailure];
        }
        
        UInt32 flagOne = 1;
        
        AudioUnitSetProperty(self.componetInstance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flagOne, sizeof(flagOne));
        
        AudioStreamBasicDescription desc = {0};
        desc.mSampleRate = _configuration.audioSampleRate;
        desc.mFormatID = kAudioFormatLinearPCM;
        desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
        desc.mChannelsPerFrame = (UInt32)_configuration.numberOfChannels;
        desc.mFramesPerPacket = 1;
        desc.mBitsPerChannel = 16;
        desc.mBytesPerFrame = desc.mBitsPerChannel / 8 * desc.mChannelsPerFrame;
        desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
        
        AURenderCallbackStruct cb;
        cb.inputProcRefCon = (__bridge void *)(self);
        cb.inputProc = handleInputBuffer;
        status = AudioUnitSetProperty(self.componetInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &desc, sizeof(desc));
        status = AudioUnitSetProperty(self.componetInstance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &cb, sizeof(cb));
        
        status = AudioUnitInitialize(self.componetInstance);
        
        if (noErr != status) {
            [self handleAudioComponentCreationFailure];
        }
        
        [session setPreferredSampleRate:_configuration.audioSampleRate error:nil];
        
        
        [session setActive:YES error:nil];
```

视频的录制：调用GPUImage中的GPUImageVideoCamera

```
_videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_configuration.avSessionPreset cameraPosition:AVCaptureDevicePositionFront];
_videoCamera.outputImageOrientation = _configuration.orientation;
_videoCamera.horizontallyMirrorFrontFacingCamera = NO;
_videoCamera.horizontallyMirrorRearFacingCamera = NO;
_videoCamera.frameRate = (int32_t)_configuration.videoFrameRate;
        
_gpuImageView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
[_gpuImageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
[_gpuImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_gpuImageView setInputRotation:kGPUImageFlipHorizonal atIndex:0];
```

转载请注明原地址，Clang的博客：https://chenhu1001.github.io 谢谢！
