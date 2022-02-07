
# 前提
1. mediaSoup 分 C、S两端。  
1. 是SFU，只管选择-转发
1. 是库，C、S两端口都需要自己开发。
# 疑问
1. 新SDP交互的时候是如何的？
1. 多条流的是时候，是几个连接？
1. 如何控制offer/answer的生成？

## 架构图
![引用自官网](https://mediasoup.org/images/mediasoup-v3-architecture-01.svg)
如图所示， 推流端是“生产者”(webrtc的流也可以是rtp的流)， 拉流(录制)端是消费者，通过路由(router)连接。
1. [worker 实现](./worker.md)
1. [demo](./demo.md)
## API类图
```plantuml
@startuml
interface MediaSoup
interface Worker
interface Router
interface Transport {
}
interface WebrtcTransport
interface PlainTransport
interface PipeTransport
interface DirectTransport
interface Producer
interface Consumer
interface DataProducer
interface DataConsumer
interface RtpObserver
interface ObserverAPI {
    newworker()
    newrouter()
    close()
    newtransport()
    newproducer()
    newconsumer()
    newdataproducer()
    newdataconsumer()
}

ActiveSpeakerObserver ..|> RtpObserver
AudioLevelObserver ..|> RtpObserver


WebrtcTransport --|> Transport
PlainTransport --|> Transport
PipeTransport --|> Transport
DirectTransport --|> Transport


MediaSoup ..> Worker :<<create>>
Worker ..> Router :<<create>>
Router ..> WebrtcTransport : <<create>>
Router ..> PlainTransport : <<create>>
Router ..> PipeTransport : <<create>>
Router ..> DirectTransport : <<create>>
Router ..> ActiveSpeakerObserver : <<create>>
Router ..> AudioLevelObserver : <<create>>

Transport o--> DataConsumer
Transport o--> DataProducer
Transport o--> Producer
Transport o--> Consumer
note "用于通知应用层，应用层感兴趣就监听" as N1
N1 .. ObserverAPI

note "Consumer/Procuctor 的创建回调给Transport, \n **它是所有Transport的父类**" as N2
N2 .left. Transport
@enduml
```
```plantuml
@startuml
title ""
@enduml
```
