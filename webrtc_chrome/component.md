# 用户角度
```plantuml
@startuml
package webrtc {
    () PeerConnection
    () PeerConnectionFactoryInterface
    () AudioSourceInterface
    () VideoSourceInterface
    () AudioTrackInterface
    () VideoTrackInterface
}
package rtc {
    () AdaptedVideoTrackSource 
    note left: "this is note"
}
@enduml
```

实现自己的 VideoSource 可以从AdaptedVideoTrackSource 派生