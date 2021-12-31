```plantuml
package webrtc {
    interface AudioEncoderFactory
    interface videoEncoderFactory
    interface AudioDecoderFactory
    interface videoDecoderFactory
    interface PeerConnectionInterface
    interface PeerConnectionFactoryInterface {
        CreatePeerConnection() : PeerConnectionInterface
    }
    PeerConnectionFactoryInterface ..> PeerConnectionInterface : <<create>>
    PeerConnectionFactory ..left.|> PeerConnectionFactoryInterface
    
}
```
**工厂方法设计模式**，使系统可以在需要的时候创建具体的对象,也使外部决定创建什么类型的具体对象。

CreateBuildinAudioEncoderFactory  
CreateBuildinVideoEncoderFactory  
CreateBuildinAudioDecoderFactory  
CreateBuildinVideoDecoderFactory 都是全局函数，由webrtc提供的默认创建函数。  
CreatePeerConnectionFactory 也是个全局函数，它有network_thread, 
worker_thread, 
signaling_thread 三个线程做可选参数，外部不传就创建。