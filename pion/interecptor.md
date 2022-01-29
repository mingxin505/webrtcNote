```plantuml
@startuml
package cc {
    interface BandwidthEstimator
    InterceptorFactory -> BandwidthEstimator
}
package gcc {
 class lossBasedBandwidthEstimator {}
}
@enduml
```