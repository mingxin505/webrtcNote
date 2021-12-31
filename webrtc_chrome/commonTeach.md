# signal - slot
和QT中的“信号-槽”机制差不多。适当时机发送一个信号，然后就能调用到槽函数。
基本分三部分
## signal
```
class Sender {
public:
    sigslot::signal1<string> msg_sig;
}
```
## slot
```
class Slot : public sigslot::has_slots<> {
public:
    void Recv(std::string str) {}
}
```
## conn
```
void init() {
    sender = new Sender();
    slot = new Slot();
    sender.msg_sig.connect(&slot, &Slot::Recv);
}
```
# invoke
invoke调用是异步调用，它确保所有的调用在同一个线程内，以解决跨线程问题。
# messageQueue
messageQueue 和 Thread 协作。凡是派生自 MessageHandler 的类，都可以作为任务丢到messqgeQueue中，由 thread 执行。