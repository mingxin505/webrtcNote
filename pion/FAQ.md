1. 浏览器webrtc 断流有onmute事件，pion有没有？
2. renegotation会不会重新做ice？（不会
3. webrtc/api的peerconnection一样吗,
一样。前者是后者的封装与简化
4. ice-tcp 需要开监听端口，浏览器端居然是透明的！！！！
5. 当webrtc.newpeerconnection的时候，没指定iceserver,怎么做candate收集？

6. pion-pion如何确定candidate 收集完成,它与offer/answer是什么关系？记得它是有个优先级排序的
7. rtcp 的流控制是如何做的？
通过interceptor,通过sfu 的 buffer 和 rtcpreader 
8. pion的rtc/rtcp/data好像是复用的，验证一下，
由SDP决定
9. 何时开始监听UDP端口的，ice交互是什么样子的
创建offer的时候就开始做candidate 收集。host/sefRly/Relay 各不相同
10. DTLS的角色由sdp中的属性a=setup:active 决定
11. nack 默认实现了基于包的，基于负载的呢
由interceptor 的派生类实现
12. 网络层与上层的交互，数据如何缓存？
readwritecloser 类完成
13. libexec 是什么库
14. 怎么用API控制是否复制一个连接、然后复用AV和track?
15. Ice 的重新协商与连接保持是怎么实现的？
重发SDP
Stun binding request
16. Interceptor/chain/ RTP,RTCP的输入输出是怎么交互的？
Chain 是 interceptor 的组合，由interceptor的rtpread/rtpwrite拦截
17. Interceptor 分rtp/rtcp 由BindXX实现
Ion-sfu 逻辑理顺