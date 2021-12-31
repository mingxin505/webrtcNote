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
    ChannelManager ..> DataEngineInterface : use
    WebRtcMediaEngineFactory ..> WebRtcVoiceEngine : 模板化
    WebRtcMediaEngineFactory ..> VideoEngine : 模板化
    WebRtcMediaEngineFactory ..> MediaEngineInterface : <<create>>
    WebRtcVoiceEngine --> AudioMixer
    WebRtcVoiceEngine --> AudioProcessing
}
```