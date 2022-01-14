```plantuml
package webrtc {
interface VideoTrackSourceInterface
interface MediaSourceInterface
interface MediaStreamTrack
interface VideoTrackInterface
interface ObserverInterface
class Notifier<T> 
Notifier o-> ObserverInterface
Notifier ..|> VideoTrackInterface 
MediaStreamTrack --|> Notifier
VideoTrack --|> MediaStreamTrack
VideoTrack o--> VideoTrackSourceInterface
VideoTrackSourceInterface ..|> rtc.VideoSourceInterface
}
package rtc {
    class VideoBroadcaster {
        它有 VideoSinkInterface 集合
    }
    interface VideoSinkInterface<T>
    interface VideoSourceInterface<T>
    AdapterVideoTrackSource --|> webrtc.Notifier
}
package cricket {
    interface VideoDeviceCaptureFatcory
    VideoCapture *-> rtc.VideoBroadcaster
    VideoCapture ..|> rtc.VideoSourceInterface
    CustomDevice ..|> VideoCapture
    WebRtcVideoDeviceCaptureFatcory ..|> VideoDeviceCaptureFatcory
    WebRtcVideoDeviceCaptureFatcory ..> VideoCapture : <<create>>
}
```
Notifier 模板类，根据参数而变化,暂定模板为 VideoTrackerInterface;它还是个”主题“，在合适的时机通知 ObserverInterface.
和 AudioTrack 类似， VideoTrack 也是作为协调者把 VideoSinkInterface 和 VideoTrackSourceInterface 的实例关联起来。
VideoTrack 从 ObserverInterface 派生，可作为”订阅者“而接收到变更。 
和 AudioTrack 类似， VideoTrack 由 PeerConnectionFactory 创建。  
CustomDevice 是由用户定义的视频源设备。
VideoCapture 持有 VideoSinkInterface 的集合，所以只要注册过的都能收到数据。
```plantuml
title "VideoSource"
participant buess as ul <<UserLayer>> 
participant mysrc as mysrc <<AdapterVideoTrackSource>> 
participant dev_fact as devf <<WebRtcVideoDeviceCaptureFatcory>> 
participant WebRtcVideoCapture as vc <<VideoCapture>> 
participant PeerConnectionFactory as pcf <<PeerConnectionFactoryInterface>> 
participant PeerConnection as pc <<PeerConnectionInterface>> 
-> ul : AddVideoTrack
alt Dev
ul -> devf : Create
create vc
devf -> vc : new
return VideoCapture
ul -> pcf : CreateVideoSource(VideoCapture)
return VideoTrackSourceInterface
else Custome
create mysrc
ul -> mysrc : Create
return VideoTrackSourceInterface
end
ul -> pcf : CreateVideoTrack(VideoTrackSourceInterface)
return VideoTrackInterface
ul -> pc :  AddVideoTrack(VideoTrackInterface)
```
FAQ:
1. 从VideoSourceBase派生，意欲何为？
1. rtc里的叫VideoSourceInterface 和 VideoTrackSourceInterface  有什么区别？
rtc 里的叫 VideoSourceInterface, webrtc 的叫 VideoTrackSourceInterface

以 windows 平台为例，讨论数据源相关内容。
整个来说这是个 Pipe&Filter 架构，DirectShow 就是该架构的实现。 恰巧，真正的捕获动作是由 DShow 完成的。
```plantuml
package webrtc {
    class VideoCaptureModule
    interface VideoCaptureExternal
package videoCaptureModule {
    VideoCaptureImpl ..|> VideoCaptureExternal
    VideoCaptureImpl ..|> VideoCaptureModule
    VideoCaptureImpl "1" o-> "*" rtc.VideoSinkInterface
    CaptureSinkFilter --|> CBaseFilter
    CaptureSinkFilter o-> VideoCaptureExternal
    CaptureInputPin *-> CaptureSinkFilter
}
}
package cricket {
    WebRtcVideoCapture ..|> VideoCapture
    WebRtcVideoCapture ..|> rtc.VideoSinkInterface
    WebRtcVideoCapture o--> webrtc.VideoCaptureModule

}
```
作为 capture 为什么要派生自 VideoSinkInterface 呢？原来它是通过 sink 接口从其它地方接收数据。
```plantuml
participant WebRtcVideoCapture as vc <<VideoCapture>> 
participant VideoCaptureImpl as vci <<VideoCaptureModule>> 
participant CaptureSinkFilter as csf <<CaptureSinkFilter>> 
participant CaptureInputPin as cip <<CaptureInputPin>> 
[-> vc : start
vc -> vci : RegisterCaptureDataCallback(this)
==数据流===
-> cip : Receive
cip -> csf : ProcessCapturedFrame
csf -> vci : InComingFrame
vci -> vci : DeliverCaptureFrame
vci -> vc : OnFrame
```
Receive 是采集到数据后的被调函数，数据今次传递到 VideoCapture 中。然后由 VideoCapture 进行分发。所以这是‘推-拉’模式中的推模式。