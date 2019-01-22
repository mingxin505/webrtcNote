` 如果无名字空间限制,默认名字空间为:webrtc. `      
` XXInterface 表明这个功能部分的顶层类.`  
` XXFactory 表明这个功能部分的构造器`  
# 基本流程  
采集-->编码-->传输-->解码-->(特效)-->渲染  
## 传输
编码的数据->rtp/rtcp混合->dtls->udp->发送  
### rtp/rtcp   
从 third_party 目录中发现了libsrtp库.从这里开始.  
cricket::SrtpSession封装了libsrtp.libsrtp只是一个demux/mux,它的输入和输出都是SrtpTransport;  
SrtpTransport是RtpTransportInternal的子类,后者是RtpTransportInterface的子类.
问题来了,
1. 谁创建了它?
2. 谁是它的输入?
3. 谁是它的输出?
#### 关于创建  
RtpTransportInterface的类说明中说,是OrtcFactory创建了它.用于Rtp的收发.  
OrtcFactory是OrtcFactoryInterface的子类.在这里看到了XXInterface格式.接口总有创建者吧?谁创建了它呢?从OrtcFactoryInterface中看到了静态的创建方法.原来通过静态方法创建子类对象.那谁调用了它呢? <font color="#660000">没了?!!!</font>

## 
