# transport-cc
1. 以连接为单位进行控制。
1. 发送端控制
1. 
### packet chunk
-
-
-
#### run-lenght code
原理是将重复且连续出现多次的字符使用“连续出现次数+字符”来描述，例如：aaaabbcddddd通过Run length编码就可以压缩为4a2bc5d。Run length chunk中就使用了Run length编码表示多个相同状态的连续包.  
#### status vector chunk
### receive delat
以0.25ms为单位，表示本RTP包到达时间与上RTP包到达时间的差值。对于第一包而言，表示本包与 reference time 的差值。