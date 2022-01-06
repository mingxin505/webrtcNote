# MediaEngine
```plantuml
package webrtc {
    class AudioProcessing {

    }
    class AudioMixer
}
package cricket {
    interface MediaEngineInterface {
        CreateChannel()
        CreateVideoChannel()
    }
    interface DataEngineInterface
    class ChannelManager
    class WebRtcMediaEngineFactory {
        {static} Create()
    }
    note left: "静态方法可以随便被调用 \n  
    ChannelManager ..> MediaEngineInterface : use
    CompositeMediaEngine ..|> MediaEngineInterface
    CompositeMediaEngine ..> WebRtcVoiceEngine : use
    CompositeMediaEngine ..> WebRtcVideoEngine : use
    ChannelManager ..> DataEngineInterface : use
    WebRtcMediaEngineFactory ..> MediaEngineInterface : <<create>> 
    note on link: 接口间创建关系
    WebRtcMediaEngineFactory ..> CompositeMediaEngine : <<create>>

    WebRtcVoiceEngine --> AudioMixer
    WebRtcVoiceEngine --> AudioProcessing
} 
```
ChannelManager 被 PeerConnectionFactory 拥有,PeerConnection 持有 PerrConnectionFactory 实例，所以相关的创建活动由PeerConnection发起与操作。  
WebRtcAudio/VideoEngine 负责创建各自的 MediaChannel.  
MediaEngineInterface 在 PeerConnectionFactoryDependience里，所以 PeerConnectionFactory 能访问到，PeerConnection 也能访问到。
