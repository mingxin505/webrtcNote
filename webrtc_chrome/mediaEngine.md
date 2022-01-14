# MediaEngine
**因为变化较大，这里没依据M70，2022-01-14**
```plantuml
package webrtc {
    interface AudioEncoderFactory
    interface AudioDecoderFactory
    interface VideoEncoderFactory
    interface VideoDecoderFactory
    class AudioProcessing {

    }
    class AudioMixer
    
    VideoEncoderFactory ..> VideoEncoder : << create>>
    VideoDecoderFactory ..> VideoDecoder : << create>>
}
package cricket {
    note  ”废弃了,\n 使用webrtc::VideoEncoderFactory“ as N1
    interface WebRtcVideoEncoderFactory
    interface WebRtcVideoDecoderFactory
    N1 .. WebRtcVideoDecoderFactory
    N1 .. WebRtcVideoEncoderFactory

    interface MediaEngineInterface {
        CreateChannel()
        CreateVideoChannel()
    }
    class ChannelManager
    class WebRtcMediaEngineFactory {
        {static} Create()
    }
    note left: "静态方法可以随便被调用 \n  
    
    ChannelManager ..> MediaEngineInterface : use
    CompositeMediaEngine ..|> MediaEngineInterface
    CompositeMediaEngine ..> WebRtcVoiceEngine : use
    CompositeMediaEngine ..> WebRtcVideoEngine : use
    WebRtcMediaEngineFactory ..> MediaEngineInterface : <<create>> 
    note on link: 接口间创建关系
    WebRtcMediaEngineFactory ..> CompositeMediaEngine : <<create>>


    WebRtcVideoEngine o-> VideoDecoderFactory
    WebRtcVideoEngine o-> VideoEncoderFactory

    WebRtcVoiceEngine o--> AudioDecoderFactory
    WebRtcVoiceEngine o--> AudioEncoderFactory
    WebRtcVoiceEngine o--> AudioMixer
    WebRtcVoiceEngine o--> AudioProcessing
} 
```
ChannelManager 被 PeerConnectionFactory 拥有,PeerConnection 持有 PerrConnectionFactory 实例，所以相关的创建活动由PeerConnection发起与操作。  
WebRtcAudio/VideoEngine 负责创建各自的 MediaChannel， 被 ChannelManager 使用。    
MediaEngineInterface 在 PeerConnectionFactoryDependience里，所以 PeerConnectionFactory 能访问到，PeerConnection 也能访问到。  
```plantuml
title "创建 VoiceChannel"
participant chm  as chm <<ChannelManager>>
participant ve  as ve <<MediaEngineInterface>>
participant WebRtcVoiceMediaChannel  as vmc <<VoiceMediaChannel>>
participant vc  as vc <<VoiceChannel>>

[-> chm : CreateVoiceChannel
chm -> ve : CreateChannel
create vmc
ve -> vmc : new
return 
create vc
chm -> vc : new(VoiceMediaChannel)
return 
```


