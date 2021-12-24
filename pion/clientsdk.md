```plantuml
package Stream {
    interface LocalStream
    interface makeRemote
    interface RemoteStream
}
package Signal {

}
package Ion {

}
package Client {
class Client {

}
Client *-- Signal
Client *-- RTCDataChannel
Client *-- Transport
Client *-- RTCPeerConnection
}
```