---
title: iOS直播技术分享-音频编码（二）
date: 2016-07-11 14:06:35
categories: 音视频
tags: [音视频]
---
## 音频基础知识
### PCM格式
pcm是经过话筒录音后直接得到的未经压缩的数据流
数据大小=采样频率*采样位数*声道*秒数/8
采样频率一般是44k，位数一般是8位或者16位，声道一般是单声道或者双声道
pcm属于编码格式，就是一串由多个样本值组成的数据流，本身没有任何头信息或者帧的概念。如果不是音频的录制者，光凭一段PCM数据，是没有办法知道它的采样率等信息的。
<!--more-->
### AAC格式
初步了解，AAC文件可以没有文件头，全部由帧序列组成，每个帧由帧头和数据部分组成。帧头包含采样率、声道数、帧长度等，有点类似MP3格式。
## AAC编码
### 初始化编码转换器

```
-(BOOL)createAudioConvert{ //根据输入样本初始化一个编码转换器
    if (m_converter != nil){
        return TRUE;
    }
    
    AudioStreamBasicDescription inputFormat = {0};
    inputFormat.mSampleRate = _configuration.audioSampleRate;
    inputFormat.mFormatID = kAudioFormatLinearPCM;
    inputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    inputFormat.mChannelsPerFrame = (UInt32)_configuration.numberOfChannels;
    inputFormat.mFramesPerPacket = 1;
    inputFormat.mBitsPerChannel = 16;
    inputFormat.mBytesPerFrame = inputFormat.mBitsPerChannel / 8 * inputFormat.mChannelsPerFrame;
    inputFormat.mBytesPerPacket = inputFormat.mBytesPerFrame * inputFormat.mFramesPerPacket;
    
    AudioStreamBasicDescription outputFormat; // 这里开始是输出音频格式
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mSampleRate       = inputFormat.mSampleRate; // 采样率保持一致
    outputFormat.mFormatID         = kAudioFormatMPEG4AAC;    // AAC编码 kAudioFormatMPEG4AAC kAudioFormatMPEG4AAC_HE_V2
    outputFormat.mChannelsPerFrame = (UInt32)_configuration.numberOfChannels;;
    outputFormat.mFramesPerPacket  = 1024;                    // AAC一帧是1024个字节
    
    const OSType subtype = kAudioFormatMPEG4AAC;
    AudioClassDescription requestedCodecs[2] = {
        {
            kAudioEncoderComponentType,
            subtype,
            kAppleSoftwareAudioCodecManufacturer
        },
        {
            kAudioEncoderComponentType,
            subtype,
            kAppleHardwareAudioCodecManufacturer
        }
    };
    OSStatus result = AudioConverterNewSpecific(&inputFormat, &outputFormat, 2, requestedCodecs, &m_converter);
    
    
    if(result != noErr) return NO;
    
    return YES;
}
```

### 编码转换

```
char *aacBuf;

if(!aacBuf){
        aacBuf = malloc(inBufferList.mBuffers[0].mDataByteSize);
    }
    
    // 初始化一个输出缓冲列表
    AudioBufferList outBufferList;
    outBufferList.mNumberBuffers              = 1;
    outBufferList.mBuffers[0].mNumberChannels = inBufferList.mBuffers[0].mNumberChannels;
    outBufferList.mBuffers[0].mDataByteSize   = inBufferList.mBuffers[0].mDataByteSize; // 设置缓冲区大小
    outBufferList.mBuffers[0].mData           = aacBuf; // 设置AAC缓冲区
    UInt32 outputDataPacketSize               = 1;
    if (AudioConverterFillComplexBuffer(m_converter, inputDataProc, &inBufferList, &outputDataPacketSize, &outBufferList, NULL) != noErr){
        return;
    }
    AudioFrame *audioFrame = [AudioFrame new];
    audioFrame.timestamp = timeStamp;
    audioFrame.data = [NSData dataWithBytes:aacBuf length:outBufferList.mBuffers[0].mDataByteSize];

    char exeData[2];
    exeData[0] = _configuration.asc[0];
    exeData[1] = _configuration.asc[1];
    audioFrame.audioInfo =[NSData dataWithBytes:exeData length:2];
```

转载请注明原地址，Clang的博客：https://chenhu1001.github.io 谢谢！