```plantuml
namespace webrtc {
    interface CallFactoryInterface
    class CallFactory
    CallFactory ..|> CallFactoryInterface
    interface Call {
        CreateAudioSendStream()
        CreateVideoSendStream()
        CreateAudioReceiveStream()
        CreateVideoReceiveStream()
        CreateFlexfecReceiveStream()
    }
    interface PacketReceiver
    interface RecoverdPacketReceiver {
        OnRecoverdPacket()
    }
    note left: for recv fec
    namespace internal {
        class Call {
            {static} Create()
            ..管理..
            1.  AV 流
            1. 收发 AV 数据
        }
        Call --|> webrtc.Call
        Call --|> webrtc.PacketReceiver
        Call --|> webrtc.RecoverdPacketReceiver
    }
}
```
internal::Call 派生自 webrtc::Call,实现”创建“； 派生自 PacketReceiver 实现数据接收；  
Call 被 WebRtcVideoEngine/WebRtcAudioEngine 使用，用于创建 Stram.  
它创建的对象在编解码功能的上层
```plantuml
title "创建ModuleProcessThread“
participant pcf_  as pcf <<PeerConnectionFactory>>
participant callFattory_  as cf <<CallFactory>>
participant call_  as call <<Call>>
participant icall_  as icall <<internal.Call>>
participant modPt_  as modPT <<ProcessThread>>
-> pcf : CreateCall_w
pcf -> cf : CreateCall
cf -> call : Create
create icall
call -> icall : new
create modPT
icall -> modPT : create
return pt
```
CallFactory 实例在创建 PeerConnectionFactory 前创建，
Call 组件的地位处于中游，上接 MediaEngine, 下接 Transport.  