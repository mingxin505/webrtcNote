# 未完
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
    ChannelManager ..> MediaEngineInterface : use
    CompositeMediaEngine ..|> MediaEngineInterface
    CompositeMediaEngine ..> WebRtcVoiceEngine : 模板化
    CompositeMediaEngine ..> WebRtcVideoEngine : 模板化
    ChannelManager ..> DataEngineInterface : use
    WebRtcMediaEngineFactory ..> MediaEngineInterface : <<create>>
    WebRtcVoiceEngine --> AudioMixer
    WebRtcVoiceEngine --> AudioProcessing
} 
```
ChannelManager 被 PeerConnectionFactory 拥有,PeerConnection 持有 PerrConnectionFactory 实例，所以相关的创建活动由PeerConnection发起与操作。  
WebRtcAudio/VideoEngine 负责创建各自的 MediaChannel.  
MediaEngineInterface 在 PeerConnectionFactoryDependience里，所以 PeerConnectionFactory 能访问到，PeerConnection 也能访问到。
