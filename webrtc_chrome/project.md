# 工程文件
[gclient](https://www.chromium.org/developers/how-tos/depottools)
它是一个代码库管理工具。
支持git/svn
支持linux/win/mac
.gclient/DEPS本质上是python脚本。熟悉python能增加理解。

# 编译/更新报错
## [CIPD](https://chromium.googlesource.com/chromium/src.git/+/master/docs/cipd.md) selfupdate failed. Trying to bootstrap the CIPD client from scratch...  
cipd(chrome infrastructure package deploymnet),简单说是管理依赖的。由DEPS文件配置。由gclient使用。功能是告诉gclient去哪儿下载哪个版本。
粗略搜索了一下，好多目录都有DEPS。
```
/src/stats/DEPS
./src/build/fuchsia/fidlgen_js/DEPS
./src/build/fuchsia/layout_test_proxy/DEPS
./src/audio/DEPS
./src/media/DEPS
./src/pc/test/DEPS
./src/pc/DEPS
...其它的略过。
```
它在 *gclient sync*执行过程中更新。报错原因是更新失败。国内嘛，大家都懂。
它使用http/https代理。因此,  
win
```
set http_proxy=http://yourProxy:port
set https_proxy=http://yourProxy:port
```
linux/macos
```
export http_proxy=http://yourProxy:port
export https_proxy=http://yourProxy:port
```
_yourProxy:port_ 记得换成你自己的代理。

## win更新报错
```
D:\webrtc_new\webrtc-win>gclient sync --nohooks
error: The following untracked working tree files would be overwritten by checkout:
        pylint.bat
Please move or remove them before you switch branches.
Aborting
fatal: Could not detach HEAD
Failed to update depot_tools.

```
解决的办法是去depot_tools目录下执行git pull.
## NOTICE: You have PROXY values set in your environment, but gsutilin depot_tools does not (yet) obey them.  
- 创建.boto
```
[Boto]
proxy = 100.100.100.100
proxy_port = 8080
ca_certificates_file = /path/to/certificate.crt
```  
- export NO_AUTH_BOTO_CONFIG=`pwd`/.boto

# runhooks
就是执行DEPS中hooks的部分。 

# *.gn/*.gni;ninja
它们是工程文件。类似vs的sln/vcproj,xcode的.xcode
工程文件几个元素
1. 宏定义
1. 库依赖
1. 头文件信赖
1. 工程文件间的包含/引用
## google 所有的项目都禁用了rtti/exceptions
- rtti 在 gn gen 时加 use_rtti=true即可
- exceptions 要修改 gn 文件,
  configs -= [ "//build/config/compiler:no_exceptions" ]
  configs += [ "//build/config/compiler:exceptions" ]
- 其它的编译参数，直接加cflags_cc/cflags_c里就行。

## 关于分支
```
git branch -r //查看已有分支
```
无论你怎么更新，版本好像停止在m79了。这并不是你更新的错误而是：  
**在2020-01-15的时候，M80，从该版本开始，代码中的分支名称从M80改成了分支号(80是Chromium版本, 分支号是一个单调递增的Chromium分支号码，例如M80对应3987)** 
如果想查mxx和chromium的对应关系，见[对应关系](https://chromiumdash.appspot.com/branches)