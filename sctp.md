# [sctp](https://datatracker.ietf.org/doc/html/rfc4960)
是传输层协议。原本用于窄带SCN(7号)信令的可靠性传输引入到IP协议。但是其推广效果一般般。
其特点有如下：
1. multi homing
1. multi stream
1. message framing
1. graceful shutdown
在webrtc中，使用了它的改良和裁剪版。由 [WebRTC Data Channel Establishment Protocol](https://datatracker.ietf.org/doc/html/rfc8832)、[WebRTC Data Channels](https://datatracker.ietf.org/doc/html/rfc8831)说明。
地位从传输层变成了应用层（基于DTLS),并实现了可靠、部分可靠、不可靠三种工作方式。

