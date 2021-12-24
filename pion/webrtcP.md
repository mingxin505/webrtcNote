# webrtc
[标准文档](https://www.w3.org/TR/webrtc/)
## CRC
```plantuml
@startuml
package net {
    () Conn
}
package io {
    () ReadWriteCloser
}
[webrtc]  --> ReadStreamSRTCP
[webrtc]  --> ReadStreamSRTP
[webrtc]  --> SessionSRTCP
[webrtc]  --> SessionSRTP
[webrtc] -up- PeerConnection

[srtp] -right--> Conn
[srtp] ---> ReadWriteCloser
[srtp] -up-- ReadStreamSRTCP
[srtp] -up- ReadStreamSRTP
[srtp] -up-- SessionSRTCP
[srtp] -up- SessionSRTP

[rtp] -up- Packetizer
[rtp] -down- rtp.Packet
[rtp] -left- Header
[rtp] -right- Extension
[rtcp] -- rtcp.Packet
[rtcp] -up- PictureLossIndication

[sdp] -up- ExtMap
[sdp] -down-  SessionDescription
[sdp] -left-  MediaDescription
[sdp] -right-  Attribute

[dtls] -- Conn
[ice] -- Conn

@enduml
```

```plantuml
@startuml
[dtls] -- Conn
[dtls] --> net.Conn

[ice] -- ice.Conn
[ice] -- Agent
@enduml
```
DTLS 依赖下层的连接对象(net.Conn),向上层提供封装后的连接对象(net.Conn)