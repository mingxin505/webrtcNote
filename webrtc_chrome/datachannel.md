datachannel 与 Audio/Video 不同，它通过 SCTP 收发。因此，SCTP 与 RTP/RTCP 属于同一层级。  
datachannel 的数据也可以通过 RTP 进行收发。(**M88中被删除**)  
```plantuml
package cricket {
    interface SctpTransportInternalFactory
    interface SctpTransportInternal
    interface DataMediaChannel
    note left: deltete
    class RtpDataMediaChannel 
    note right: delete \n
    class RtpDataChannel
    note left: delete
    interface MediaChannel


    SctpTransportInternalFactory .left.> SctpTransportInternal : <<create>> 
    SctpTransportFactory ..|> SctpTransportInternalFactory
    SctpTransportFactory ..> SctpTransport : <<create>>
    SctpTransport ..|>SctpTransportInternal
    SctpTransport o--> rtc.PacketTransportInternal

    RtpDataChannel --> webrtc.DataChannel : signal 
    RtpDataChannel --> DataMediaChannel : signal
    MediaChannel <|.. DataMediaChannel
    RtpDataMediaChannel .up.|> DataMediaChannel
}
package rtc {
    interface MessageHandler
    interface PacketTransportInternal
}
package webrtc {
interface DataChannelProviderInterface
interface DataChannelObserver
interface DataChannelInterface {
    RegisterObserver()
    UnregisterObserver()
} 
class DataChannel {
    {static} Create() : DataChannel
}
DataChannelInterface "1" o--> "*" DataChannelObserver

DataChannel ..|> rtc.MessageHandler
DataChannel ..|> DataChannelInterface
DataChannel o-> DataChannelProviderInterface
} 
```
DataChannel 由自身的静态函数创建。  
DataChannelProviderInterface 的派生类负责数据发送，PeerConnection实现了这个接口。  
DataChannel 实现了 MessageHandler, 表明可以被 Thread 回调,来自网络的数据包可以直接投递到DataChannel中； 派生自 sigslot::has_slots<> ，表明可以使用“信号-槽”机制接收数据，实际数据就是通过这种机制传输的。  
DataChannelInterface/DataChannelObserver 实现了“发布-订阅”设计模式；因为DataChannel也是个“主题”，业务层通过实现 DataChannelObserver 接收通道数据。  
SctpTransport 使用 rtc.PacketTransportInternal 进行数据接收, 而后者是个接口，意味着属于另一部分。这里不展开。
```plantuml
participant SctpTransport  as  sctp <<SctpTransportInternal>>
participant pc_ as pc <<PeerConnection>>
participant dc_ as dc <<DataChannel>>
participant dco_ as dco <<DataChannelObserver>>

[-> sctp : OnInboundPacketFromSctpToTransport
note left: 由 usrsctplib 第三方库调用出来。
sctp -> sctp : OnPacketFromSctpToTransport
sctp -> sctp : SignalDataReceived
note left: 信号
sctp -> pc : OnSctpTransportDataReceived_n 
note left: 槽
pc -> pc : OnSctpTransportDataReceived_s
note left: 信号
pc -> pc : SignalSctpDataReceived
pc -> dc : OnDataReceived 
note left: 槽
dc -> dco : OnMessage
```
usrsctplib 这个第三方库实现”可靠，有序列“功能，因此数据要先进 usrsctplib, 符合要求后数据通过“信号-槽” 的连接通知到 SctpTransport, SctpTransport 通过“信号-槽” 的连接通知到 pc_， pc_ 通过同样的机制通知到 dc, 再由 dc 决定数据是不是需要自己处理，若需要就调用 dco_ 的回调函数(即：交给上层）。

