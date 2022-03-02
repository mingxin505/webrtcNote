## node/lib 目录
1. AudioLevelObserver.js  
          用于检测声音的大小， 通过C++检测音频声音返回应用层，通过Observer接收并展示音频大小
1. Channel.js
          主要用于与C++部分信令通讯，外部调用ts的命令，比如说创建router,最后通过channel把命令发送给worker并执行。
1. Consume.js
      消费媒体数据，音频或视频

1. EnhancedEventEmitter.js
      EventEmitter的封装，C++底层向上层发送事件

1. Logger.js

      用于写日志

1. PipeTransport.js
      Router之间的转发

1. PlainRtpTransport.js

      普通的rtp传输通道，如FFmpeg等不经过浏览器rtp协议的数据传输

1. Producer.js

     生产媒体数据，音频或视频

1. Routers.js
     代表一个房间或者一个路由器
1. RtpObserver.js

     Rtp数据的观察者 回调用的

1. Transport.js

     所有传输的的基类(父类)

1. WebRtcRtpTransport.js
webrtc 使用的传输

1. Worker.js
 一个节点或者一个进程，实际应该是进程，代码中根据CPU核数启动相对   应的Worker数量;一个房间只能在一个Worker里。

1. Errors.js

     错误信息的定义

1.. Index.js

     Mediasoup的库，上层引入Mediasoup最先导入的库，也为库的索引。

1. Ortc.js

     其与SDP相对应，以对象的形式标识SDP，如编解码参数，编解码器，帧   率等，以对象方式去存储。

1. ScalabilityModes.js

  一般不关心，略过

1. SupportedRtpCapabilities.js

  对通讯能力的支持，实际上是媒体协商相关的东西，如你支持的帧率， 码率，编解码器是什么等

1. Utils.js

       一些常见的工具函数