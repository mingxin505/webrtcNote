```plantuml
@startuml
title  来自调试,收到SDP之后的动作
participant work_thread_ as MQ <<MessageQueue>>
participant ConnMicManager as MH <<MessageHandler>>
participant base_client_ as BC <<BaseClient>>
participant peer_client_ as PCli <<PeerClient>>
participant pc_proxy_ as PCP <<PeerConnectionProxy>>
[->> MQ : Post
==业务操作==
[-> MQ : Dispatch
activate MQ
MQ -> MH : OnMessage
activate MH
MH -> MH : DoSetRemoteSdp
activate MH
MH -> BC : SetRemoteSdpAndCandiate
activate BC
BC -> PCli : SetRemoteSdpAndCandiate
activate PCli
PCli -> PCP : SetRemoteDescription
activate PCP
==以下为webrtc==
participant connection_ as PC <<PeerConnection>>
participant video_channel_ as VC <<cricket::VideoChannel>>
participant webrtc_video_channel_ as WRVC <<cricket::WebRtcVideoChannel>>
participant video_send_stream_ as WRVCSS <<cricket::WebRtcVideoChannel::VideoSendStram>>
participant call_ as CALL <<webrtc::internal::Call>>
participant wrivs as WRIVS <<webrtc::internal::VideoSendStram>>
participant impl as WRIVSI <<webrtc::internal::VideoSendStramImpl>>
PCP -> PC : SetRemoteDescription
activate PC
PC -> PC : ApplyRemoteDescription
activate PC
PC -> PC : UpdateSessionState
activate PC
PC -> PC : PushdownMediaDescription
activate PC
PC -> VC : SetRemoteContent
activate VC
note left: BaseChannel-async->invokeOnWorker
VC -> VC : SetRemoteContent
activate VC
VC -> WRVC : SetSendParameters
activate WRVC
WRVC -> WRVCSS : SetSendParameters
activate WRVCSS
WRVCSS -> WRVCSS : SetCodec
activate WRVCSS
WRVCSS -> WRVCSS : RecreateWebRtcStream
activate WRVCSS
WRVCSS -> CALL : CreateVideoSendStream
activate CALL
CALL -> CALL : CreateVideoSendStream
activate CALL
create WRIVS
CALL -> WRIVS : new
activate WRIVS
WRIVS -> WRIVS : CreateVideoStreamEncoder
activate WRIVS
create WRIVSI
WRIVS -->> WRIVSI : new
==华丽的分隔线==
participant transport_ as RTCS <<RtpTransportControllerSend>>
participant sender_ as RVS <<RtpVideoSender>>
participant rtp_rtcp_ as RTPCP <<RtpRtcp>>
participant module_ as MRI <<ModuleRtpRtcpImpl>>
participant rtcp_s as RTCPS <<RtcpSender>>
participant rtcp_r as RTCPR <<RtcpReceiver>>
participant rtp_s as RTPS <<RtpSender>>
WRIVSI -> RTCS : CreateRtpVideoSender
activate RTCS
create RVS
RTCS -> RVS : new
activate RVS
RVS -> RVS : CreateRtpRtcpModules
activate RVS
RVS -> RTPCP : CreateRtpRtcp
activate RTPCP
create MRI 
RTPCP -> MRI : new
activate MRI
create RTCPS
MRI -> RTCPS : new
create RTCPR 
MRI -> RTCPR : new
create RTPS
MRI -> RTPS : new

@enduml
```

```plantuml
@startuml
title encode Audio
participant work_thread_ as MQ <<MessageQueue>>
participant ConnMicManager as MH <<MessageHandler>>
participant cap as CAP <<COffcnAudioCapture>> 
participant adev as ADEV <<AudioDeviceModule>>
[-> MQ :post
====
[-> MQ : Dispatch
MQ -> MH : OnMessage
MH -> MH : DoStartAudioCapture
MH -> CAP : startRecord
CAP -> ADEV : RegisterAudioCallback
CAP -> ADEV : StartRecording 
@enduml
```

```plantuml
@startuml
title 
encode、render Video
end title
participant v_th as VTH <<CVideoCapture>>
participant cb as VCB <<CALLBACK_CAP_VIDEO_YUV>>
participant ConnMicManager as MH <<MessageHandler>>
participant PublishClient as BC <<PublishClient>>
participant PeerClient as PCli <<PeerClient>>
participant VideoTrackSourceInput as VTSI <<AdaptedVideoTrackSource>>
note left of VTSI: 外部实现
participant vse as VSE <<WebRtc::VideoStreamEncoder>>
[-> VTH : TH_VideoCapture
====
activate VTH
VTH -> VTH : VideoCaptureProcess
note left
死循环
end note
VTH -> CB : Call
note left: 函数指针
CB -> DLG : OnYuvFrameCallback
DLG -> UIM : InputVideoData
UIM -> FreeFN : InputVideoData
FreeFN -> MH : InputVideoData
MH -> BC : InputYUVData
BC -> PCli : InputYUVData
PCli -> VTSI : InputVideoFrame
activate VTSI
create VF
VTSI -> VF : create
VTSI -> VTSI : OnFrame
note left: 调用基类,后面都是observer
VTSI ->  BRD: OnFrame
BRD -> VSE : OnFrame
note left
1 VSE是个sink
1 1..*
end note
VSE ->> EnQ : Post
note left
VSE 与codec交互。它实现了OnFrame和OnEncodedImage两个接口
end note
@enduml
```

```plantuml
@startuml
title 
add track
tracker直接进入了编码与解码
end title
participant conn as PC <<PeerConnection>>
participant rtpri as RTPRI <<RtpReceiverInternal>>
participant rtpsi as RTPSI <<RtpSenderInternal>>
participant rtpt as RTPT <<RtpTransceiver>>
[-> PC : AddTrack(VideoTrackInterface)
activate PC
PC -> PC : CreateSender
create RTPSI
activate PC
PC -> RTPSI : new
deactivate
PC -> PC : CreateReceiver
create RTPRI
activate PC
PC -> RTPRI : new
deactivate 
PC -> PC : CreateAndAddTransceiver
create RTPT
activate PC
PC -> RTPT : new
deactivate
note left: PC 拥有多个RptTransceiver
@enduml
```

```plantuml
@startuml
title MSG_CREATE_SESSIONDESCRIPTION_SUCCESS
participant mq as MQ <<Mq>>
participant PeerClient as CSDO <<CreateSessionDescriptionOberver>>
participant pcp as PCP <<PeerConnectionProxy>>
participant connection_ as PC <<PeerConnection>>
participant VoiceChannel as VC <<BaseChannel>>
participant WebRtcVoidcMediaChannel as WRVMC <<MediaChannel>>
participant WebRtcAudioSendStream as WRASS <<WebRtcAudioSendStream>>
participant call_ as CALL <<webrtc::internal::Call>>

[-> MQ : dispatch
MQ -> CSDO : OnSuccess
CSDO -> PCP : SetLocalDescription
PCP -> PC : SetLocalDescription
activate PC
PC -> PC : ApplyLocalDescription
activate PC
PC -> PC : UpdateSessionState
activate PC
PC -> PC : PushdownMediaDescription
activate PC
PC -> VC : SetLocalContent
note left: invoke not display
activate VC
VC -> VC : SetLocalContent_w
activate VC
VC -> VC : UpdateLocalStream_w
activate VC
VC -> WRVMC : AddSendStream
activate WRVMC
create WRASS
WRVMC -> WRASS : new
WRASS -> CALL : CreateAudioSendStream
@enduml
```
```plantuml
participant brd as BRD <<VideoBroadcaster>>
participant sink as SINK <<CVideoRenderEx>>
SINK -> PCli : OnVideoFrame 
PCli -> BC : OnChannelVideoFrame
BC -> UIM : OnChannelVideoFrame
activate UIM
UIM -> UIM : WriteLocalBuffer
UIM ->> UIM : PostMessage
==怎么编码并发送的？==
```

```plantuml
@startuml
title
MediaEngine
1. 创建了一堆factory
1. 还顺带创建了MediaEngine，它就像个服务。服务于不同的tracker
1. 同一PeerConnectionFactory创建的PeerConnection共享。
end title
participant pcf as PCF <<PeerConnectionFactory>>
participant fn as FN <<GlobalFn>>
participant wrmef as WRMEF <<WebRTCMediaEngineFactory>>
participant cme as CME <<CompositeMediaEngine>>
participant wrve as WRVE <<WebRtcVoiceEngine>>
participant ve as VE <<VideoEngine>>
[-> FN : CreatePeerConnectionFactory
create WRMEF
FN -> WRMEF : create
activate WRMEF
create CME
WRMEF -> CME : new
activate CME
create WRVE
CME -> WRVE : new
note left: member
create VE 
CME -> VE : new
note left : member
return MediaEngineInterface
FN -> FN : CreateCallFactory
FN -> FN : CreateEventLogFactory
FN -> FN : CreateModularPeerConnectionFactory(MediaEngine,)
note left : x
@enduml
```

```plantuml
@startuml
title
Peerconnection
jsepTransportController
end title
participant connection_ as PC <<PeerConnection>>
participant trans_c as TC <<JsepTransportController>>
[->PC : Initialie
activate PC
create TC
PC -> TC : new(Config)
note left: config 包含参数\n由用户层一路传递
note right: "拥有Callback和Slot"
@enduml
```