```plantuml
namespace Stream {
    interface LocalStream
    interface makeRemote
    interface RemoteStream
    interface MediaStream
    LocalStream ..|> MediaStream
    RemoteStream ..|> MediaStream
}
namespace Signal {
    interface Signal
    IonSFUJSONRPCSignal ..|> Signal
    note "使用websocket通信" as N1
    N1 . IonSFUJSONRPCSignal
}
namespace Ion {
    class IonConnector
}
namespace Client {
    class Client {
    }
    Client *-- Signal.Signal
    Client *-- RTCDataChannel
    Client *-- Transport
    Client *-- RTCPeerConnection
}
```
echo_test 示例程序， 通过 join 创建一个 Peer(pub,sub) ,通过“收到 offer 则必是 pub; 收到 answer 则必是 sub ”的逻辑实现区分。 除了通过命令区分外，也可以通过 dataChannel 区分。 