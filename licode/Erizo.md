# API
`A Node.js addon wrapper for Erizo. It configures and manages all aspects of Erizo from your Node.js applications!`

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```
# controller
`It's the core of the service. It provides Rooms to users in order to make multiconference sessions. It also supplies enough security mechanisms and additional capabilities: data, user lists, events, and so on.`

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```
# Erizo
`It's the WebRTC Multipoint Control Unit (MCU). It's written in C++ and is 100% compatible with WebRTC standard and its protocols.`

## pipeline
## media
## rtp
## stats
## handler
[c++11,conditional](https://en.cppreference.com/w/cpp/types/conditional)

```plantuml
@startuml
title ""
package erizo {
interface PipelineManager
interface PipelineContext
class PipelineBase {
    有模板函数，这个如何表达？
}


class ContextImplBase<<H Context>>
interface OutboundHandlerContext
interface OutboundLink
interface InboundHandlerContext
interface InboundLink
class ContextImpl<<H>>
class OutboundContextImpl <<H>>
class InboundContextImpl <<H>>

PipelineBase *--- PipelineManager
PipelineBase "1" *-- "3" PipelineContext
PipelineBase "1" *-- "*" PipelineServiceContext
Pipeline ..|> PipelineBase

ContextImplBase ...|> PipelineContext

ContextImpl ...|> HandlerContext
ContextImpl ...|> OutboundLink
ContextImpl ...|> InboundLink
ContextImpl ...|> ContextImplBase


OutboundContextImpl ...|> OutboundHandlerContext
OutboundContextImpl ...|> OutboundLink
OutboundContextImpl ...|> ContextImplBase

InboundContextImpl ...|> InboundHandlerContext
InboundContextImpl ...|> InboundLink
InboundContextImpl ...|> ContextImplBase

InboundContextImpl o---> PipelineBase
ContextImpl o---> PipelineBase
OutboundContextImpl o---> PipelineBase

interface ServiceContext
interface PipelineServiceContext
ServiceContextImplBase<<s Context>>
ServiceContextImpl<<Service>>

ServiceContextImpl .up.|> ServiceContext
ServiceContextImpl .up.|> ServiceContextImplBase
ServiceContextImpl ...|> PipelineServiceContext
ServiceContextImpl o---> PipelineBase

ServiceBase<<ServiceContext>>
Service ..|> ServiceBase
Service o--> ServiceContext
note "**service 如何触发的，还没搞清楚**" as N1
N1 . Service
}
@enduml
```
PipelineBase 是中心。
InboundContextImpl/InboundContextImpl/ContextImpl 以 PipelineContext的角色加入到 PipleineBase 中;然后它们三个又都持有 PipleineBase 的指针。这是个双向指向。  
ServiceContextImpl 的情况和 ContextImpl 一样。  
Context 更像个容器。把 pipelineBase 和 具体的 service/handler 关联起来。  
Pipeline 的 read 方法，触发 inbound; write 方法,触发 outbound。  
```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```

```plantuml
@startuml
title ""
@enduml
```