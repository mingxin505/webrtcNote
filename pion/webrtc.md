# webrtc
[标准文档](https://www.w3.org/TR/webrtc/)
## CRC
```plantuml
@startuml
page 1X4
namespace webrtc {
    class RTPReceiver {
    ==职责(responsibility)==
    1. 管理远程 MediaStreamTrack 在本地的“存根”(trackStreams)
    1. 使用 DTLTransport 完成数据接收
    1. 被 RTPTransceiver 管理
    1. 消息泵
    ..问题(question)..
    1. track CURD 的时候，怎么处理的？(ok)
    1. 
    }

    class RTPTransceiver {
    ..Role..
    1. 组织 RTPReceiver/RTPSender 
    1. 代表 SDP 中的一行 media description
    }
    class API{
        ..职责..
        1. PeerConnection 工厂
    }
    class PeerConnection {
    ..wrapper..
    1. 创建并使用 RTPReceiver 完成接收
    1. 创建并使用 RTPSender 完成发送
    1. 创建 DataChannel
    }
    class TrackRemote {
    ==职责==
    1. 使用 RTPReceiver 收数据
    }
    class DataChannel {
        ..职责..
        1. 消息泵
    1.     
    }
    class TrackLocal {
        ...
        1. 发送的track
    }
    class TrackLocalStaticSample {
        ...
        1. 统计发出的
    }
    class trackStreams {
        纯虚构
        ..职责..
        1. 丰富了TrackRemote
    }

    class DTLSTransport {

    }
    class ICETransport {}
    class SettingEngine {
        ....
        1. 配置项
    }
    class MediaEngine {
        ....
        1. 各种参数最终要变成SDP
        ==Question==
        1. 如何变的呢？answer 的时候
    } 
    MediaEngine ...>sdp.MediaDescription : use
    API ...> PeerConnection : create
    PeerConnection o--> API
    PeerConnection o---> DTLSTransport
    PeerConnection o---> ICETransport
    PeerConnection *-- RTPTransceiver
    PeerConnection ...> DataChannel : create
    RTPReceiver --o RTPTransceiver

    trackStreams o-- TrackRemote
    trackStreams o-- interceptor.RTPReader  
    trackStreams o-- interceptor.RTCPReader 
    trackStreams o-- srtp.ReadStreamSRTCP  
    trackStreams o-- srtp.ReadStreamSRTP 
    RTPReceiver *-- DTLSTransport
    RTPReceiver *- trackStreams
    TrackRemote o-- RTPReceiver
    DTLSTransport *--> srtp.SessionSRTP
    DTLSTransport *--> srtp.SessionSRTCP
    DataChannel o--> datachannel.DataChannel
    TrackLocal <|--- TrackLocalStaticSample
    TrackLocalStaticSample  *-- rtp.Packetizer
    namespace mux {
        class Mux{
            ....
            1. dispatcher
            1. 消息泵
        }
        class EndPoint {
            ....
            1. net.Conn的子类
            1. 读写
        }
        Mux -- EndPoint
        webrtc.ICETransport *-->Mux
        webrtc.ICETransport ...> EndPoint : <<create>>
        webrtc.DTLSTransport *--> EndPoint
    }

}
namespace interceptor  {
    interface RTPReader
    interface RTCPReader
    interface RTPWriter
    interface RTCPWriter
    interface Interceptor {
        ..职责..
        1. 工厂，创建reader/writer
        1. 具体工厂创建具体reader/writer做事
    }

    class Chain{
        ..职责..
        1. 工厂链
    }
    Chain "1" o-> "*" Interceptor  

    RTPReader <|.. ConcreteRTPReader
    RTCPReader <|.. ConcreteRTCPReader
    RTPWriter <|.. ConcreteRTPWriter
    RTCPWriter <|.. ConcreteRTCPWriter
    Interceptor <|.. ConcreteInterceptor
    ConcreteInterceptor ...> ConcreteRTPReader : <<create>>
    ConcreteInterceptor ...> ConcreteRTCPReader : <<create>>
    ConcreteInterceptor ...> ConcreteRTPWriter : <<create>>
    ConcreteInterceptor ...> ConcreteRTCPWriter : <<create>>

}
namespace rtcp {
    
}
note "由于服务端不打/解包所以RTP功能不复杂" AS N1
namespace rtp {
    interface Packetizer
    class Packet
    class Header
    class Extension
    class packetizer {
        ...
        1. bytes -> struct
    }
    packetizer ..|> Packetizer
    Packet *-- Header
    Header *-- Extension
}
rtp .. N1
namespace srtp {
    class Config
    class Session {
        ....
        1. net.Conn 是 mux.EndPoint 实例
        1. 通过外部传入的bufferFactory 创建io.ReadWriteCloser实例
        1. 消息泵
    }
    class SessionSRTP{
        ....
        1. 读写共享同一实例
    }
    class SessionSRTCP{
        ....
        1. 读写共享同一实例
    }
    class WriteStreamSRTP{
        ....
        1. 加密
    }
    class WriteStreamSRTCP{
         ....
        1. 加密
    }
    class ReadStreamSRTP{
        ....
        1. 解密
    }
    class ReadStreamSRTCP{
        ....
        1. 解密
    }
    Config --> webrtc.SettingEngine : copy
    Session o---> bufferFactory
    bufferFactory ...> io.ReadWriteCloser : create
    
    Session ---o SessionSRTP
    Session ---o SessionSRTCP
    Session ...> io.ReadWriteCloser : use

    WriteStreamSRTCP --- SessionSRTCP
    WriteStreamSRTP --- SessionSRTP
    ReadStreamSRTCP o--- SessionSRTCP
    ReadStreamSRTP o--- SessionSRTP
}

namespace datachannel {
    class DataChannel {

    }
}

namespace sdp {
    class ExtMap{}
    class SessionDescription{
        ....
        1. string <--> struct
        1. 成员全公有
        1. 组织各个部分
    }
    class MediaDescription{
        ....
        1. 成员全公有
        1. candidate 是普通attribute
    }
    class Attribute
    SessionDescription  "1" o-- "*" MediaDescription
    MediaDescription "1" o-- "*" Attribute
    SessionDescription  "1" o-- "*" Attribute
    Attribute "1" o-- "*" ExtMap
}
package transport {
    package packetio{
        Buffer ...|> io.ReadWriteCloser
    }
}
@enduml
```