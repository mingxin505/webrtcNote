```plantuml
note  "newDataChannel \n " as N1

package datachannel {
     DataChannel o-> sctp.Stream
}
package sctp {
    Stream *-> reassemblyQueue
    Association "1" *-> "*" Stream 
}
datachannel .. N1
```
各类关系如图所示。
```plantuml
participant ass_  as  assoc <<Association>>
participant dc_ as dc <<DataChannel>>
participant stream_ as str <<Stream>>
participant queue_ as queue <<reassemblyQueue>>
title "读写操作“

[-> assoc : handleData
assoc -> str : handleData
str -> queue : push
str -> queue : isReadable
return true/false
==读操作==
[-> dc : ReadDataChannel
dc -> str : ReadSCTP
str -> queue : Read
```