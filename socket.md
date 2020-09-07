```
Socket依赖Thread
```

# Net I/O
异步socket需要线程驱动。因此，Thread::SocketServer::CreatewAsyncSocket可以把socket和线程关联起来。
## AsyncSocket
AsyncSocket--->Socket
它代表了socket,是各种socket实现的抽象。
## AsyncUdpSocket
AsyncUdpSocket--->AsyncPacketSocket--->sigslot::has_slots<>
表明几点
1. 它们是通过Slot的形式与其它对象(类)通信
1. slot至少要包括收发
1. 它依赖
