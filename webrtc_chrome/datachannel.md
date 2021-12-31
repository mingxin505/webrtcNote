```plantuml
package webrtc {
interface DataChannelProviderInterface
interface SctpTransportInternalFactory
interface SctpTransportInternal
interface DataChannelInterface {
    RegisterObserver()
    UnregisterObserver()
}
class DataChannel {
    {static} Create() : DataChannel
}
DataChannelInterface o-left-> DataChannelObserver
DataChannel ..|> rtc.MessageHandler
DataChannel ..|> DataChannelInterface
DataChannel o-> DataChannelProviderInterface
SctpTransportInternalFactory .left.> SctpTransportInternal : <<create>> 
SctpTransportFactory .up.|> SctpTransportInternalFactory
SctpTransport .up.|> SctpTransportInternal
SctpTransportFactory .left.> SctpTransport : <<create>>
} 
```
DataChannelProviderInterface 的派生类负责数据收发，PeerConnection实现了这个接口。  
DataChannel 实现了 MessageHandler, 表明可以被 Thread 回调,所以 来自网络的数据包可以直接投递到DataChannel中。  
DataChannelInterface/DataChannelObserver 实现了“发布-订阅”设计模式；因为DataChannel也是个“主题”  

