```plantuml
package cricket {
    interface VoiceMediaChannel
    interface MediaChannel
    VoiceMediaChannel ..|> MediaChannel
}
package webrtc {
interface RtpTranscieverInterface
interface RtpSenderInternal
interface RtpReceiverInternal
interface RtpSenderInterface
interface RtpReceiverInterface
interface ObserverInterface {
    OnChange()
}
interface DtmfProviderInterface
RtpTransciever .|>RtpTranscieverInterface
RtpTransciever o--> RtpSenderInternal
RtpTransciever o--> RtpReceiverInternal
RtpTransciever o--> cricket.BaseChannel
RtpSenderInternal ..|> RtpSenderInterface
RtpReceiverInternal ..|> RtpReceiverInterface
AudioRtpSender ..|> RtpSenderInternal
AudioRtpSender ..|> ObserverInterface
AudioRtpSender ..|> DtmfProviderInterface

AudioRtpSender o-> VoiceMediaChannel
AudioRtpSender o->  LocalAudioSinkAdapter

LocalAudioSinkAdapter ..|> AudioSinkInterface
LocalAudioSinkAdapter ..|> cricket.AudioSource
}
```
AudioRtpSender 如果要想收数据，它要么是 AudioSinkInterface 的子类，自己收数据，要么持有 AudioSinkInterface 的实例，从实例中取数据。webrtc 使用后者; 要想发数据，需要借助 AudioMediaChannel.
AudioMediaChannel。 AudioMediaChannel的网络接口是 VoiceChannel 实例。
cricket.AudioSource 是下层需要的接口。  
```plantuml
package webrtc {
    interface VideoMediaChannel
    interface VideoTrackInterface
    interface ObserverInterface {
        OnChange()
    }
    VideoRtpSender ..|> RtpSenderInternal
    VideoRtpSender ..|> ObserverInterface
    VideoRtpSender o-> VideoMediaChannel
    VideoRtpSender o-> VideoTrackInterface
    VideoTrack ..|> VideoTrackInterface
}
note  "Video" as N1
N1 .. webrtc
```
XXInternal 接口用于 PeerConnection。  

VideoRtpSender/AudioRtpSender 派生自observerinterface,表明这是“发布-订阅”中的“订阅者”，OnChange 函数会被调用， 而 MediaStreamTrackInterface 是 “主题”; 拥有 Video/AudioMediaChannel，对下通过控制进它们而实现自身价值。
  

```plantuml
package webrtc {
interface StreamCollectionInterface
interface MediaStreamTrackInterface
note left: 由标准定义
interface MediaStreamInterface
note left: 由标准定义
interface VideoTrackInterface
interface VideoSourceInterface
interface AudioSourceInterface

interface AudioTrackInterface
VideoTrackInterface ..|> MediaStreamTrackInterface
VideoTrackInterface ..|> VideoSourceInterface
AudioTrackInterface ..|> MediaStreamTrackInterface

MediaStreamInterface "1" o--> "*" AudioTrackInterface
MediaStreamInterface "1" o--> "*" VideoTrackInterface

AudioTrack ..|>  AudioTrackInterface
VideoTrack ..|> VideoTrackInterface

StreamCollectionInterface <|... StreamCollection
}
```
做为一路音频，必须需要源，因此持有 AudioSourceInterface, 必须要有去处， 因此持有 AudioSinkInterface. 这时候，有两个可能，
1. AudioTrack 做个‘中间人’，把数据从Source取出，放到Sink.
1. 把 sink 交给 source. 只做协调。
webrtc 使用了后者。 所以，在类图中没表明相关关系。这个关系要在下图中表达。  
那 AudioTrack 还有什么作用呢？ 它从 OberverInterface 派生，可以监听变化。

```plantuml
title "source-sink"
participant AudioTrack  as  at <<AudioTrackInterface>>
participant AudioSourceInterface  as  asrc <<AudioSourceInterface>>
[-> at : AddSink(sink)
at -> asrc : AddSink
return 
```
视频的情况和音频类似。  
以上这些类不参与数据传递，只是控制功能。它们就像老式电话的接线员，把线插来插去就行。不客线路中传递的内容。  
