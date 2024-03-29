```plantuml
page 2x2
package webrtc {
    interface CallFactoryInterface

    interface PeerConnectionInterface
    interface VideoSourceInterface
    interface VideoTrackInterface
    interface AudioSourceInterface
    interface AudioTrackInterface
    interface DataChannelProviderInterface
    interface PeerConnectionInternal
    interface PeerConnectionInterface
    interface MediaEngineInterface
    interface NetworkControllerFactoryInterface
    interface CallFactoryInterface
    interface DataChannelInterface
    interface PeerConnectionObserver
    interface PeerConnectionFactoryInterface {
        CreatePeerConnection() : PeerConnectionInterface
        CreateAudioTrack() : AudioTrackInterface
        CreateAudioSource() : AudioSourceInterface
        CreateVideoTrack() : VideoTrackInterface
        CreateVideoSource() : VideoSourceInterface
    }
    class PeerConnectionFactory {

    }
    class PeerConnectionFactoryDependencies
    note left: "名字起的好随意"
    PeerConnectionFactoryDependencies "1" o--> "3" rtc.Thread
    PeerConnectionFactoryDependencies o--> CallFactoryInterface
    PeerConnectionFactoryDependencies o--> MediaEngineInterface
    PeerConnectionFactoryDependencies o--> NetworkControllerFactoryInterface
    PeerConnectionFactoryInterface ..> CallFactoryInterface : use
    PeerConnectionFactoryInterface ..> PeerConnectionInterface : <<create>>
    PeerConnectionFactory *-> cricket.ChannelManager : <<create and use>>
    PeerConnectionFactory ..left.|> PeerConnectionFactoryInterface
    PeerConnection ...|> rtc.MessageHandle
    PeerConnection *--> VideoTrackInterface
    PeerConnection *--> AudioTrackInterface
    PeerConnection .left..|> DataChannelProviderInterface
    PeerConnection .left..|> PeerConnectionInternal
    PeerConnection *--> cricket.SctpTransportInternalFactory
    PeerConnection ..> DataChannelInterface : <<create>>
    PeerConnection ..> PeerConnectionObserver : use
    PeerConnection "1" *--> "*" RtpTransceiver
    PeerConnectionInternal ..left.|>PeerConnectionInterface
    PeerConnection o-up-> PeerConnectionFactory
    VideoTrackInterface *--> VideoSourceInterface
    AudioTrackInterface *--> AudioSourceInterface
}
```
**工厂方法**设计模式，使系统可以在需要的时候创建具体的对象,也使外部决定创建什么类型的具体对象。

CreateBuildinAudioEncoderFactory  
CreateBuildinVideoEncoderFactory  
CreateBuildinAudioDecoderFactory  
CreateBuildinVideoDecoderFactory 都是全局函数，由webrtc提供的默认创建函数。  
CreatePeerConnectionFactory 也是个全局函数，它有network_thread, 
worker_thread, 
signaling_thread 三个线程做可选参数，外部不传就创建。

PeerConnectionFactory 负责创建 Audio/Video  的track/source,然后常见用法是把source设置给track,再把track添加到PeerConnection里。

PeerConnection 通过 RTPTransceiver 负责管理 MediaStreamTrackInterface. MediaStreamTrackInterface 代表一条流(音频、视频)
SctpTransportInternalFactory 用于创建 SctpTransportInternal, 用于 DataChannel。