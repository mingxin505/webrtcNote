# API
[WebRTC 1.0: Real-Time Communication Between Browsers](https://www.w3.org/TR/webrtc/)
```plantuml
interface RTCPeerConnectionTnerface
interface RTCRTPTransceiver
interface RTCRTPReceiver
interface RTCRTPSender

interface RTCIceTransport
interface RTCDtlsTransport
interface RTCSctpTransport
RTCPeerConnectionTnerface *--> RTCRTPTransceiver
RTCRTPTransceiver *--> RTCRTPSender
RTCRTPTransceiver *--> RTCRTPReceiver
```
[JavaScript Session Establishment Protocol](https://rtcweb-wg.github.io/jsep/#rfc.section.1)
[orW3C
Object RTC (ORTC) API for WebRTCtc](https://draft.ortc.org/)