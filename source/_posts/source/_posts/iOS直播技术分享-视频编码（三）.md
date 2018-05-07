---
title: iOS直播技术分享-视频编码（三）
date: 2016-07-11 14:06:46
categories: 音视频
tags: [音视频]
---
&emsp;&emsp;x264是一种免费的、具有更优秀算法的符合H.264/MPEG-4 AVC视频压缩编码标准格式的编码库。它同xvid一样都是开源项目，但x264是采用H.264标准的，而xvid是采用MPEG-4早期标准的。由于H.264是2003年正式发布的最新的视频编码标准，因此，在通常情况下，x264压缩出的视频文件在相同质量下要比xvid压缩出的文件要小，或者也可以说，在相同体积下比xvid压缩出的文件质量要好。它符合GPL许可证。 
<!--more-->
&emsp;&emsp;iOS视频编码分为硬编码和软编码：硬编码就是利用手机专用的硬件进行编码，软编码是用CPU进行编码。由于苹果在iOS8开放的硬编码的API，故现在大多数的直播应用都是采用的硬编码。
## iOS硬编码

 &emsp;&emsp;从iOS8开始，苹果开放了硬解码和硬编码API，框架为 VideoToolbox.framework， 此框架需要在iOS8及以上的系统上才能使用。
       此框架中的硬解码API是几个纯C函数，在任何OC或者 C++代码里都可以使用。使用的时候，首先，要把VideoToolbox.framework 添加到工程里，并且在要使用该API的文件中包含头文件#include <VideoToolbox/VideoToolbox.h>，然后，就可以畅快的高效的对视频流进行硬编码了。

直接上代码来说明，首先是定义了编码所需的变量
```
@interface CLHardwareVideoEncoder (){
    VTCompressionSessionRef compressionSession;
    NSInteger frameCount;
    NSData *sps;
    NSData *pps;
    FILE *fp;
    BOOL enabledWriteVideoFile;
}

@property (nonatomic, strong) CLLiveVideoConfiguration *configuration;
@property (nonatomic,weak) id<CLVideoEncodingDelegate> h264Delegate;
@property (nonatomic) BOOL isBackGround;
@property (nonatomic) NSInteger currentVideoBitRate;

@end
```

初始化编码session
```
- (void)initCompressionSession{
    if(compressionSession){
        VTCompressionSessionCompleteFrames(compressionSession, kCMTimeInvalid);
        
        VTCompressionSessionInvalidate(compressionSession);
        CFRelease(compressionSession);
        compressionSession = NULL;
    }
    
    OSStatus status = VTCompressionSessionCreate(NULL, _configuration.videoSize.width, _configuration.videoSize.height, kCMVideoCodecType_H264, NULL, NULL, NULL, VideoCompressonOutputCallback, (__bridge void *)self, &compressionSession);
    if(status != noErr){
        return;
    }
    
    _currentVideoBitRate = _configuration.videoBitRate;
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval,(__bridge CFTypeRef)@(_configuration.videoMaxKeyframeInterval));
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration,(__bridge CFTypeRef)@(_configuration.videoMaxKeyframeInterval));
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(_configuration.videoFrameRate));
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(_configuration.videoBitRate));
    NSArray *limit = @[@(_configuration.videoBitRate * 1.5/8),@(1)];
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)limit);
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanFalse);
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_H264EntropyMode, kVTH264EntropyMode_CABAC);
    VTCompressionSessionPrepareToEncodeFrames(compressionSession);
}
```

编码输入
```
- (void)encodeVideoData:(CVImageBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp{
    if(_isBackGround) return;
    
    frameCount ++;
    CMTime presentationTimeStamp = CMTimeMake(frameCount, (int32_t)_configuration.videoFrameRate);
    VTEncodeInfoFlags flags;
    CMTime duration = CMTimeMake(1, (int32_t)_configuration.videoFrameRate);
    
    NSDictionary *properties = nil;
    if(frameCount % (int32_t)_configuration.videoMaxKeyframeInterval == 0){
        properties = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame: @YES};
    }
    NSNumber *timeNumber = @(timeStamp);
    
    VTCompressionSessionEncodeFrame(compressionSession, pixelBuffer, presentationTimeStamp, duration, (__bridge CFDictionaryRef)properties, (__bridge_retained void *)timeNumber, &flags);
}
```

回调
```
static void VideoCompressonOutputCallback(void *VTref, void *VTFrameRef, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer)
{
    if(!sampleBuffer) return;
    CFArrayRef array = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    if(!array) return;
    CFDictionaryRef dic = (CFDictionaryRef)CFArrayGetValueAtIndex(array, 0);
    if(!dic) return;
    
    BOOL keyframe = !CFDictionaryContainsKey(dic, kCMSampleAttachmentKey_NotSync);
    uint64_t timeStamp = [((__bridge_transfer NSNumber*)VTFrameRef) longLongValue];
    
    CLHardwareVideoEncoder *videoEncoder = (__bridge CLHardwareVideoEncoder *)VTref;
    if(status != noErr){
        return;
    }
    
    if (keyframe && !videoEncoder->sps)
    {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        if (statusCode == noErr)
        {
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
            if (statusCode == noErr)
            {
                videoEncoder->sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                videoEncoder->pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                
                if(videoEncoder->enabledWriteVideoFile){
                    NSMutableData *data = [[NSMutableData alloc] init];
                    uint8_t header[] = {0x00,0x00,0x00,0x01};
                    [data appendBytes:header length:4];
                    [data appendData:videoEncoder->sps];
                    [data appendBytes:header length:4];
                    [data appendData:videoEncoder->pps];
                    fwrite(data.bytes, 1,data.length,videoEncoder->fp);
                }
            }
        }
    }
    
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            // Read the NAL unit length
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);

            CLVideoFrame *videoFrame = [CLVideoFrame new];
            videoFrame.timestamp = timeStamp;
            videoFrame.data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            videoFrame.isKeyFrame = keyframe;
            videoFrame.sps = videoEncoder->sps;
            videoFrame.pps = videoEncoder->pps;
            
            if(videoEncoder.h264Delegate && [videoEncoder.h264Delegate respondsToSelector:@selector(videoEncoder:videoFrame:)]){
                [videoEncoder.h264Delegate videoEncoder:videoEncoder videoFrame:videoFrame];
            }
            
            if(videoEncoder->enabledWriteVideoFile){
                NSMutableData *data = [[NSMutableData alloc] init];
                if(keyframe){
                    uint8_t header[] = {0x00,0x00,0x00,0x01};
                    [data appendBytes:header length:4];
                }else{
                    uint8_t header[] = {0x00,0x00,0x01};
                    [data appendBytes:header length:3];
                }
                [data appendData:videoFrame.data];
                fwrite(data.bytes, 1,data.length,videoEncoder->fp);
            }
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
    }
}
```

## iOS软编码(待续)

转载请注明原地址，Clang的博客：https://chenhu1001.github.io 谢谢！