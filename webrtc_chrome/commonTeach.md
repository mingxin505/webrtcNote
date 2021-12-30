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
# messageQueue