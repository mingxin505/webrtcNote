
# Net I/O
异步socket需要线程驱动。因此，Thread::SocketServer::CreatewAsyncSocket可以把socket和线程关联起来。

```plantuml
package rtc {
    class AsyncPacketSocket {
        1. 有 slot 能力
    }
    class AsyncSocket {
        1. 提供 signal
    }
    AsyncUDPSocket *-- AsyncSocket
    AsyncUDPSocket --|> AsyncPacketSocket
    PhysicalSocket --|> AsyncSocket
    PhysicalSocket *-- SocketServer
    AsyncSocket --|> Socket

    interface SocketFactory
    interface SocketServer
    PhysicalSocketServer "1" o-- "*" Dispatcher
    PhysicalSocketServer ..|> SocketServer
    SocketServer ..|> SocketFactory

    interface Dispatcher {
        + OnEvent ()
        + OnPreEvent()
    }
    SocketDispatcher --|> Dispatcher
    SocketDispatcher --|> PhysicalSocket
     
}
```
### AsyncSocket
它代表了socket,是各种socket实现的抽象。
### AsyncUdpSocket
1. 它们是通过Slot的形式与其它对象(类)通信
1. slot至少要包括收发
1. 使用 AsyncSocket 完成收发
### PhysicalSocket
1. 使用SocketServer
### PhysicalSocketServer
1. 使用 dispatcher

## 线程相关
```plantuml
package rtc {
    interface NetworkManager
    interface DefaultLocalAddressProvider
    interface NetworkMonitorInterface {
        监听网络变更
    }
    BasicNetworkManager *--> NetworkMonitorInterface
    BasicNetworkManager ...|> MessageHandler
    BasicNetworkManager ...|> NetworkManagerBase
    NetworkManagerBase ..|> NetworkManager
    
}
```
BasicNetworkManager 由 PeerConnectionFactory 创建，由 PeerConnection 使用, 因此创建socket的任务就这么由 peerconnection 完成了。  
BasicNetworkManager 派生自 MessageHandler，故可以放到MessageQueue 中，进而由 Thread 驱动。
派生自 NetworkManagerBase 实现了“接口、实现”分离，方便使用。
```plantuml
title "创建“
participant netMgr_ as bnwmgr <<BasicNetworkManager>>
participant pss_ as pss <<PhysicalSocketServer>>
participant sdisp_ as sdisp <<SocketDispatcher>>

[-> bnwmgr : OnMessage
note left : "驱动它的线程由业务层创建"
bnwmgr -> bnwmgr : UpdateNetworksContinually
bnwmgr -> bnwmgr : UpdateNetworksOnce
bnwmgr -> bnwmgr : QueryDefaultLocalAddress
bnwmgr -> pss : CreateAsyncSocket
pss --> bnwmgr : <<return>> SocketDispatcher
bnwmgr -> sdisp : create 
```

```plantuml
title “循环”
participant netMgr_ as bnwmgr <<BasicNetworkManager>>
participant thr_ as thr <<Thread>>
[-> bnwmgr : StartUpdating
bnwmgr ->  thr : Post
thr -> bnwmgr : OnMessage
bnwmgr -> bnwmgr : UpdteNetworksContinually
```
如上图，StartUpdating 触发OnMessage后，UpdteNetworksContinually 会周期性的把自己放到线程队列中执行。它只管状态，那收发由谁处理呢？由Socket的派生类。

```plantuml
title "读写” 
participant thr_ as thr <<Thread>>
participant mq_ as mq <<MessageQueue>>
participant socksvr_ as pss <<PhysicalSocketServer>>
participant dispatchers_ as sdisp <<SocketDispatcher>>
participant sock_ as async_sock <<AsyncUDPSocket>>
participant phy_ as phySock <<PhysicalSocket>>
participant udp_ as udpP <<UDPPort>>
participant conn_ as conn <<Connection>>
[-> thr : ProcessMessage
thr -> mq : Dispatch
mq -> pss : wait
activate pss
pss -> sdisp : OnEvent
activate sdisp
sdisp -> async_sock : OnReadEvent
activate async_sock
note left: "通过 sig-slot 关联，\n AsyncUDPSocket 负责连接"
async_sock -> phySock : RecvFrom
async_sock -> udpP : OnReadEvent
note left: "通过 sig-slot 关联, \n UDPPort 负责连接"
activate udpP
udpP -> conn : OnReadPacket
```