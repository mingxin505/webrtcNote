# 简介
1. webrtc 服务端实现
# 常规
1. OnXX函数用于设置回调函数
1. 成员onXX用于指向回调函数
1. Bind函数作用不太明显

## 示例程序
1. 修改程序的stun 地址，换成自己的，能正常收集candidate
1. nodejs 的 http-server模块启动网站。(https最好使用认证过的证书)
1. 复制页面上的内容
1. 通过 echo 发送给程序
1. [SFU 设计图](./sfu.md)
## [模块依赖](./webrtcP.md)

## 常见服务端结构
### Mesh 方案
即多个终端之间两两进行连接，形成一个网状结构。基本没服务器什么事。
### MCU（Multipoint Conferencing Unit）方案
音视频混合器，大家看到的都是服务器处理过的数据。对服务器性能要求高。
### SFU（Selective Forwarding Unit）方案，
音视频路由分发器，服务器根据规则转换到对应的端。