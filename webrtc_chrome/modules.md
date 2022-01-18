# modules
模块是 webrtc 的一个组成部分，可以代指"活动对象"。 src/modules 目录下的都可以认为是模块的实现。  
```plantuml
@startuml
namespace webrtc {
interface Module
interface ModuleRtpRtcp
interface RtcpFeedbackSenderInterface
interface VideoCodingModule
interface RtpPacketSender
interface PacketSender
interface Pacer
interface SendSideCongestionControllerInterface
interface TransportFeedbackObserver
interface CallStatsObserver
namespace vcm {
    VideoReceiver ..|> webrtc.Module
}
RTCPReceiver +- ModuleRtpRtcp

ProcessThreadImpl +-- ModuleCallback
ModuleCallback o-> Module

ModuleRtpRtcpImpl ..|> RtpRtcp
note right: M97 中废除了。\n 派生类ModuleRtpRtcpImpl \n变成 ModuleRtpRtcpImpl2
ModuleRtpRtcpImpl ..|> ModuleRtpRtcp

RtpRtcp ..|> RtcpFeedbackSenderInterface
RtpRtcp ..|> Module


VideoCodingModuleImpl ..|> VideoCodingModule
VideoCodingModule ..|> Module

AudioCodingModule <|.. AudioCodingModuleImpl
PacedSender ..|> Pacer
Pacer ..|> Module
Pacer ..|> RtpPacketSender

PacerSender +-- PacketSender

SendSideCongestionController ..|> SendSideCongestionControllerInterface
note left: "M97 已废除”
SendSideCongestionControllerInterface ..|> Module
SendSideCongestionControllerInterface ..|> TransportFeedbackObserver
SendSideCongestionControllerInterface ..|> CallStatsObserver

}
package rtc {

}
package cricket {

}
@enduml
```
ModuleRtpRtcp 用于处理常规 RTCP 包。  
AudioCodingModule  不是 module 的派生类。  
```plantuml
@startuml
title "创建 SendSideCongestionController"  
participant RtpTransportControllserAdapter as adapter <<RtpTransportControllerInterface>>>>  

participant RtpTransportControllerSend as rtptcs <<RtpTransportControllerSendInterface>>  
participant SendSideCongestionController as ssccr <<SendSideCongestionControllerInterface>> 
participant internall.Call as call <<webrtc::Call>> 


-> adapter : init_w
activate adapter
create rtptcs
adapter -> rtptcs : new
activate rtptcs
create ssccr
rtptcs -> ssccr : new
return RtpTransportControllerSend
create call
adapter -> call : Create(RtpTransportControllerSend)

@enduml
```
最终被传递给了 Call ,所以同实例创建的流共享拥塞控制。
## congestion_controller
### transport cc
```plantuml
title M97
package webrtc {
    interface Module
    interface CallStatsObserver {
        OnRttUpdate()
    }
    interface RemoteBitrateEstimator {
        IncomingPacket()
    }
    interface RemoteBitrateObserver

    note "接收端用于创建 twcc 包。" as N1
    RemoteEstimatorProxy .. N1
    RemoteEstimatorProxy ..|> RemoteBitrateEstimator
    RemoteBitrateEstimator ..|> Module
    RemoteBitrateEstimator ..|> CallStatsObserver
    RemoteBitrateEstimator ..> RemoteBitrateObserver : <<depends>>
    ReceiveSideCongestionController +-- WrappingBitrateEstimator
    WrappingBitrateEstimator *- RemoteBitrateEstimatorSingleStream
    RemoteBitrateEstimatorSingleStream ..|> RemoteBitrateEstimator
    WrappingBitrateEstimator ..|> RemoteBitrateEstimator
    ReceiveSideCongestionController ..|> Module
    ReceiveSideCongestionController ..|> CallStatsObserver
}

```
RemoteBitrateEstimatorSingleStream 是实际做事的类。输入是 IncomingPacket(), 输出是 observer。  
### goog_cc
```plantuml
title ""
package webrtc {
    interface AcknowledgedBitrateEstimatorInterface
    class LossBasedBandwidthEstimation
    class DelayBasedBwe
    class SendSideBandwidthEstimation
    AcknowledgedBitrateEstimator ..|> AcknowledgedBitrateEstimatorInterface
}
```
### p_cc
[pcc Document](https://www.usenix.org/system/files/conference/nsdi15/nsdi15-paper-dong.pdf)

## pacing
```plantuml
package webrtc {
    interface Module
    interface RtpPacketSender
    interface RtpPacketPacer
    PacedSender ..|> Module
    PacedSender ..|> RtpPacketSender
    PacedSender ..|> RtpPacketPacer
}
```
PacedSender 用来平滑发送。 