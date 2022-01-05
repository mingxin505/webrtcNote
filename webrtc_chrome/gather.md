```plantuml
VideoTrack ...> VideoTrackSourceInterface : use
```
在推模式下，videoSource 会调用 VideoTrack 把自己的数据传输出去。因此它们需要互相知道。
VideoTrack 从 ObserverInterface 派生，因此它可以做为 VideoSourceTrackerInterface 的 订阅者而接收到数据。
FAQ:
1. 从VideoSourceBase派生，意欲何为？
