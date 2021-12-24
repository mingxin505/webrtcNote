# 基于浏览器的双向AV通信
## 目标
1. 适用弱网，以及各种网络
1. 安全
1. 易于使用
1. 易于扩展
1. 

## 传输、渲染

## 采集
数据采集一般有两种方式
1. 外部控制频率
系统提供输入API，由外部主动放数据进去
1. 内部控制频率
系统提供回调，由内部根据自己的逻辑调用回调获取数据。

在浏览器里，一个GetMedia就能搞定了。自用的复杂一些
WebRTC 采用前者。
```plantuml
title video
package webrtc {
    interface PeerConnectionObserver
    interface CreateSessionDescriptionObserver
    interface AudioTrackSinkInterface
}
package rtc {
    interface VideoSinkInterface
    class AdaptedVideoTrackSource {
        + OnFrame(VideoFrame & frm) // 自有
    }
    class VideoBroadcaster {

    }
    VideoSinkInterface <|.. VideoBroadcaster
    VideoSourceInterface <|.. VideoSourceBase 
    VideoSourceBase <|.. VideoBroadcaster
    VideoBroadcaster "1" *--> "*" VideoSinkInterface 
    AdaptedVideoTrackSource ..> VideoBroadcaster
}
App --|> AdaptedVideoTrackSource
```
APP 类是外部输入的入口点。
VideoBroadcaster 是个组合模式。加入到它的VideoSinkInterface都能收到输出。
FAQ: 
1. VideoSourceBase 作用是什么？
```plantuml
title audio
package webrtc {
    class AudioProcessingImpl {
        + ProcessStream(AudioFrame* frm)
    }
}
```
## 编码
编码由于比较慢，所以一般是异步。
输入队列 --> 编码过程 --> 输出回调
```plantuml
title video
package webrtc {
    interface VideoEncoder {
        Encode()
        RegisterEncodeCompleteCallback()

    }
    interface EncodedImageCallback {}
    interface VideoStreamInterface
    interface EncoderSink {
        它比EncodedImageCallback 增加了编码配置变更功能
    }
    class VideoSender {
        AddVideoFrame() 
    }
    class VideoStreamEncoder {

    }
    VideoStreamInterface +-- EncoderSink
    EncodedImageCallback <|... VideoStreamEncoder
    EncodedImageCallback <|... EncoderSink
    VideoStreamEncoder *--> rtc.TaskQueue
    VideoStreamEncoder .right.> VideoSender :use
    VideoSender .right.> VideoEncoder : use
    VideoEncoder .right.> EncodedImageCallback : use
}
```

```plantuml
title video
participant VideoStreamEncoder as VSE
participant VideoSender as VS
participant VideoEncoder as VE
participant EncodedImageCallback as CB
participant VideoStreamEncoderInterface.EncoderSink AS ES
->> VSE : OnFrame
activate VSE
VSE --> VS : AddVideoFrame
activate VS
VS --> VE : Encode
activate VE
VE --> VSE : OnEncodeImage
activate VSE
VSE --> ES : OnEncodedImage
```
缓冲区在VideoStreamEncoder那儿。它接收原始数据，输出编码数据流。那它是如何接收原始数据呢？它肯定要从一个接口派生来接收数据。
```plantuml
interface rtc.VideoSinkInterface {
    OnFrame
}
package webrtc {
interface VideoStreamEncoderInterface
rtc.VideoSinkInterface <|.. VideoStreamEncoderInterface
VideoStreamEncoderInterface <|.. VideoStreamEncoder
}
```
所以，只要能向VideoSinkInterface数据，就能放数据到VideoStreamEncoder.
FAQ: 
1. VideoStreamEncoderInterface 的价值？
1. 如果想增加一种编码格式应该怎么做？
1. 如果想增加多分辨率输出应该怎么做？  

输出，由于VideoStreamEncoder 实现了EncodedImageCallback接口，所以回调又调回来了。由它继续向VideoStramEncoder::EncoderSink传递。
## 传输
```plantuml
package webrtc {
    package internal {
VideoSendStreamImpl ..|> VideoStreamEncoderInterface::EncoderSink
}
}
```
VideoSendStreamImpl 从VideoStreamEncoderInterface::EncoderSink派生，意在能接收编码阶段的输出，与编码阶段衔接。