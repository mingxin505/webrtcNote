# 工程文件
[gclient](https://www.chromium.org/developers/how-tos/depottools)

# 编译/更新报错
1. [CIPD](https://chromium.googlesource.com/chromium/src.git/+/master/docs/cipd.md) selfupdate failed. Trying to bootstrap the CIPD client from scratch...  
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

1. win更新报错
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