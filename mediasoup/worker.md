# worker 实现
```plantuml
@startuml
title "worker"
namespace Channel {
    interface Listener {
        OnChannelRequest()
        OnChannelClosed()
    }
    class ChannelRequest
    ChannelSocket +- Listener
    ChannelNotifier o-> ChannelSocket
    note "全静态方法，用于与 master 通信" as N1
    N1 . ChannelNotifier
    note "调度进程通信" as N2
    N2 .. Listener
    note "通信数据" as N3
    ChannelRequest . N3
}
namespace PayloadChannel {
    interface Listener{
        
    }
    PayloadChannelSocket +- Listener
}
namespace RTC {
    class Router
}
interface Listener {
    OnSignal()
}
SignalsHandler +-up- Listener

Worker ..|> Listener
Worker ...|> PayloadChannel.Listener
Worker ...|> Channel.Listener
Worker ..> Channel.ChannelRequest : <<depends>>
Worker "1" *--> "*" RTC.Router : <<create>>
Worker *--> SignalsHandler
Worker o--> Channel.ChannelSocket
Worker o-> PayloadChannel.PayloadChannelSocket
note "worker 是 SignalsHandler.Listener 的派生类，\n并持有 SignalsHandler\n 进程唯一 \n" as N1
N1 . Worker
note "用于通知退出(系统信号)" as N2
N2 . Listener 
@enduml
```
worker 是起点。代表一个进程。通过 channel 与外部通信，使用 router 完成内部功能.  
```plantuml
@startuml
title ""
participant Worker as worker <<Worker>>
participant Router as router <<rtc.Router>>
==创建 Router==
-> worker: OnChannelRequest(WORKER_CREATE_ROUTER)
create router
worker -> router : new
return
==通信==
-> worker: OnChannelRequest
worker -> worker : GetRouterFromInternal
worker -> router : HandleRequest
@enduml
```
由上可知， worker 的通信入口就是 OnChannelRequest 方法。
router 的通信入口就是 HandleRequest。
```plantuml
@startuml
namespace RTC {
    interface RtpObserver
    interface Transport
    interface Consumer
    interface Listener {
        Transport.Listener 负责通知Producer/Consumer/Stream相关
    }
    Transport +-- Listener
    ActiveSpeakerObserver ...|> RtpObserver
    AudioLevelObserver ...|> RtpObserver


    Router ..|> Listener
    Router "1" *-> "*" Transport
    Router "1" o-> "*" Producer
    Router "1" o-> "*" Consumer
    Router "1" o--> "*" RtpObserver
    note "producer/consumer 是外部传入\nObserver/Transport 由自己创建\n 派生自 Transport.Listener 可接收数据。" as N1 
    N1 .. Router
    note "它是所有内部类的派生类" as N2
    N2 .. WebRtcTransport
}
@enduml
```
```plantuml
@startuml
package RTC {
class Transport {
    HandleRequest()
    .....  
    }
    Router "1" o--> "*" Transport
    Router "1" *-> "*" Consumer
    Router "1" *-> "*" DataConsumer 

    SctpListener "1" *--> "*" DataProducer
    RtpListener "1" o-- "*" Producer

    Producer +--- Producer.Listener
	Consumer +--- Consumer.Listener
	DataProducer +--- DataProducer.Listener
	DataConsumer +--- DataConsumer.Listener
	SctpAssociation +--- SctpAssociation.Listener
	TransportCongestionControlClient +--- TransportCongestionControlClient.Listener
	TransportCongestionControlServer +--- TransportCongestionControlServer.Listener

    Transport *--> SctpListener
    Transport *--> RtpListener
	Transport ..|> Producer.Listener
	Transport ..|> Consumer.Listener
	Transport ..|> DataProducer.Listener
	Transport ..|> DataConsumer.Listener
	Transport ..|> SctpAssociation.Listener
	Transport ..|> TransportCongestionControlClient.Listener
	Transport ..|> TransportCongestionControlServer.Listener

    UdpSocket +--- UdpSocket.Listener
    TcpConnection +--- TcpConnection.Listener
    TcpServer +--- TcpServer.Listener
    IceServer +--- IceServer.Listener
    DtlsTransport +--- DtlsTransport.Listener
    WebRtcTransport ..|> Transport
	WebRtcTransport ..|> IceServer.Listener
	WebRtcTransport ..|> UdpSocket.Listener
	WebRtcTransport ..|> TcpServer.Listener
	WebRtcTransport ..|> TcpConnection.Listener
	WebRtcTransport ..|> DtlsTransport.Listener

}
@enduml
```
从 router 看起， 它持有 Transport,而Transport继承自N多 Listener; 它的子类 webrtcTransport 更甚，继承自更多 Listener. 可见Transport及其子类是信息处理中心。  
TcpServer.Listener/IceServer.Listener/DtlsTransport.Listener 用于状态监听；  
TcpConnection.Listener/UdpSocket.Listener 用于数据接收。  
```plantuml
@startuml
title " handle"
participant Router as router <<rtc.Router>>
participant WebRtcTransport as trans <<rtc.Transport>>
participant Producer as prod <<rtc.Producer>>
participant DataProducer as dprod <<rtc.DataProducer>>
participant Consumer as cons <<rtc.Consumer>>
participant DataConsumer as dcons <<rtc.DataConsumer>>

participant RtpListener as rtpl <<rtc.RtpListener>>

-> router: HandleRequest
router -> trans : HandleRequest()
note right: "webrtcTransport 处理不了的，交给父类"
alt TRANSPORT_PRODUCE
create prod
trans -> prod : new
return
trans -> rtpl : AddProducer
trans -> router : OnTransportNewProducer
else TRANSPORT_CONSUMER
create cons
trans -> cons : new
return 
trans -> router : OnTransportNewConsumer
else TRANSPORT_PRODUCE_DATA
create dprod
trans -> dprod : new
return
trans -> sctpl : AddDataProducer
trans -> router : OnTransportNewDataProducer
else TRANSPORT_DATACONSUMER
create dcons
trans -> dcons : new
return 
trans -> router : OnTransportNewDataConsumer
end
@enduml
```
由图可知，各类型对象最终汇总到了Router里。因此Router可以根据需要把数据交给指定对象处理。  
Router 的数据输入有两类，一类是由 HandlerRequest 主动调用，一种是由底层各种回调上来的。


```plantuml
@startuml
title " RTCP"
package webrtc {


rtc.WebRtcTransport *-> TransportCongestionControlClient
TransportCongestionControlClient *-> RtpTransportControllerSend
RtpTransportControllerSend *-> PacedSender
}
@enduml
```
上图主要表示RTCP相关的类。
```plantuml
@startuml
title " handle RTCP"
participant WebRtcTransport as trans <<rtc.Transport>>
participant TransportCongestionControlClient as ccc <<rtc.TransportCongestionControlClient>>
participant RtpTransportControllerSend as cs <<webrtc.RtpTransportControllerSend>>
participant PacedSender as pacer <<webrtc.PacedSender>>
-> trans : OnPacketReceived
activate trans
trans -> trans : OnRtcpDataReceived
activate trans
trans -> trans : ReceiveRtcpPacket
activate trans
trans -> trans : HandleRtcpPacket
alt twcc
trans -> ccc : ReceiveRtcpTransportFeedback
ccc -> cs: OnTransportFeedback
cs -> pacer : UpdateOutstandingData
note right: 更新码率
else rr
else sr
else bye
else xr
end
@enduml
```


```plantuml
@startuml
title "producer"
NackGenerator +-- NackGenerator.Listener
Producer "1" *-- "*" RtpStreamRecv
RtpStreamRecv ..|> RtpStream
RtpStreamRecv ..|> NackGenerator.Listener

@enduml
```
从 producer 看起，一个producer 属于一个连接， 一个 producer 拥有多个 RtpStreamRecv 。  
```plantuml
@startuml
title " handle producer"
participant WebRtcTransport as trans <<rtc.Transport>>
participant Producer as prod <<Producer>>
participant Router as l <<Transport.Listener>>
participant Consumer as c <<Consumer>>

-> trans : CreateRtpStream
==收数据==
-> trans : OnPacketReceived
activate trans
trans -> trans : OnRtpDataReceived
activate trans
trans -> trans : ReceiveRtpPacket
activate trans
trans -> prod : ReceiveRtpPacket
prod -> trans : OnProducerRtpPacketReceived
note right: "as listener"
trans -> l : OnTransportProducerRtpPacketReceived
alt loop
l -> c : SendRtpPacket
end
@enduml
```
先收到 WebrtcTransPort 中， 再回调到 router里，最终在 router 里实现数据分发。  
```plantuml
@startuml
title " consumer"
interface Consumer
interface RtpStream

RtpStream +- RtpStream.Listener

SimpleConsumer ..|> Consumer 
SvcConsumer ..|> Consumer 
SimulcastConsumer ..|> Consumer 
SimpleConsumer *-> RtpStreamSend
RtpStreamSend ..|> RtpStream
RtpStreamSend +- RtpStreamSend.Listener
RtpStreamSend.Listener ..|> RtpStream.Listener
@enduml
```
RtpStreamSend 的 Listener 是派生自己 RtpStream 的。这点要注意一下。
Consumer 共三类，分别处理不同的逻辑。  
```plantuml
@startuml
title " handle consumer"
participant SimpleConsumer as c <<rtc.Consumer>>
participant RtpStreamSend as ssend <<rtc.RtpStreamSend>>
participant WebRtcTransport as l <<rtc.Transport>>
participant IceServer as ices <<rtc.IceServer>>
-> c : SendRtpPacket
c -> ssend : ReceivePacket
c -> l : OnConsumerSendRtpPacket
activate l
l -> l : SendRtpPacket
l -> ices : send
@enduml
```
到了 iceServer 可以认为进入了网络层。