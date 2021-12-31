```plantuml
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
interface VideoMediaChannel
interface AudioMediaChannel
RtpTransciever .|>RtpTranscieverInterface
RtpTransciever o--> RtpSenderInternal
RtpTransciever o-> RtpReceiverInternal
RtpTransciever o-> cricket.BaseChannel
RtpSenderInternal ..|> RtpSenderInterface
RtpReceiverInternal ..|> RtpReceiverInterface
AudioRtpSender ..|> RtpSenderInternal
VideoRtpSender ..|> RtpSenderInternal
AudioRtpSender ..|> ObserverInterface
AudioRtpSender ..|> DtmfProviderInterface
VideoRtpSender ..|> ObserverInterface
VideoRtpSender o-> VideoMediaChannel
AudioRtpSender o-> AudioMediaChannel
}
```
XXInternal 接口用于 PeerConnection。
VideoRtpSender/AudioRtpSender 派生自observerinterface,表明这是“发布-订阅”中的“订阅者”，OnChange 函数会被调用.
它通过控制Video/AudioMediaChannel进而实现自身价值。

而 MediaStreamTrackInterface 是 “主题”  

```plantuml
interface MediaStreamTrackInterface
interface VideoTrackInterface
interface videoSourceInterface
interface AudioTrackInterface
VideoTrackInterface ..|> MediaStreamTrackInterface
VideoTrackInterface ..|> videoSourceInterface
AudioTrackInterface ..|> MediaStreamTrackInterface
```
以上这些类不参与数据传递，只是控制功能。