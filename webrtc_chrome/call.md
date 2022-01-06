```plantuml
namespace webrtc {
    interface CallFactoryInterface
    class CallFactory
    CallFactory ..|> CallFactoryInterface
    class Call
    class PacketReceiver
    class RecoverdPacketReceiver
    namespace internal {
        class Call {
            ....
            这里是个工厂
        }
        Call --|> webrtc.Call
        Call --|> webrtc.PacketReceiver
        Call --|> webrtc.RecoverdPacketReceiver
    }
}
```
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