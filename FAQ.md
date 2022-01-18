## 多DataChannel的时候，是否需要额外心跳？
不需要，DataChannel 和 sctp 的 Stream 一一对应(可靠、有序通过 stream 里的缓冲决定)。  
使用的是同一 Association. 收到无主(不属于任何Stream)数据，则简单丢弃。
## 在正常情况下，如果收不到PLI会卡吗？
## wertc rtc cricket 这三个名字空间有什么意义吗？