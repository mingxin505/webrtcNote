# 代码更新
## 原理
[gclient](https://www.chromium.org/developers/how-tos/depottools)
它是一个代码库管理工具。
支持git/svn
支持linux/win/mac
.gclient/DEPS本质上是python脚本。熟悉python能增加理解。
### DEPS
```
  'src/buildtools/linux64': {
    'packages': [
      {
        'package': 'gn/gn/linux-amd64',
        'version': 'git_revision:387b368dfe63fec317f8e609d90c634807f2764e',
      }
    ],
    'dep_type': 'cipd',
    'condition': 'checkout_linux',
  }
```
Key 表示本地位置, Value 表示远程内容。condition 表示特定平台的依赖。

## 更新报错
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
**协议前缀(http://)不可以省略**,否则会报 pip3 安装会失败。

```

________ running 'python3 src/build/mac_toolchain.py' in '/Users/mac/google/macos-ios'
Skipping Mac toolchain installation for mac
Running hooks:  95% (23/24) Generate component metadata for tests
________ running 'vpython3 src/testing/generate_location_tags.py --out src/testing/location_tags.json' in '/Users/mac/google/macos-ios'
```
这个不影响编译，可以跳过。
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

## runhooks
就是执行DEPS中hooks的部分。 
## 关于分支
```
git branch -r //查看已有分支
```
无论怎么更新，版本好像停止在m79了。这并不是更新的错误而是：  
**在2020-01-15的时候，M80，从该版本开始，代码中的分支名称从M80改成了分支号(80是Chromium版本, 分支号是一个单调递增的Chromium分支号码，例如M80对应3987)** 
如果想查mxx和chromium的对应关系，见[对应关系](https://chromiumdash.appspot.com/branches)
### mac/win 分支不全
```
gclient sync --with_branch_heads --with_tags
cd src
git pull
```
# 工程
## *.gn/*.gni;ninja
depot_tools_tutorial.html)
[gn quick_start ](https://chromium.googlesource.com/chromium/src/tools/gn/+/48062805e19b4697c5fbd926dc649c78b6aaa138/docs/quick_start.md)
[gn reference](https://gn.googlesource.com/gn/+/master/docs/reference.md)
[ninja-build](https://ninja-build.org)
[ninja-manual](https://ninja-build.org/manual.html)
[component_build](https://chromium.googlesource.com/chromium/src.git/+/refs/heads/main/docs/component_build.md)

它们是工程文件。类似vs的sln/vcproj,xcode的.xcode
工程文件有如下几个元素
1. 宏定义
1. 库依赖
1. 头文件信赖
1. 工程文件间的包含/引用

### Ninja 文件
Build.ninja 是默认的构建文件.
Build 命令描述了依赖关系.格式:
	Build outputs: rulename inputs
		Key = value
		keyN = valueN
Rule 命令描述如何执行动作.
	Rule ruleName
		Key = value
		keyN = valueN
var = value 定义变量,可通过$var或者${var}引用.变量定义后不可被更改.
rule命令的预定义变量variable
Build 块中定义的变量,会覆盖原变量.

Phony 可用于创建目录.

Default targets targets2
Ninja targetName 可编译特定目标. Target 就是一个build 
Ninja 默认并行.不需要指定-j参数.

.ninja_log存放了日志,其路径由builddir指定,不指定则是当前目录.


Subninja 包含其它.ninja文件,独立作用域,可用父模块的变量..
Include 引入其它.ninja文件到当前作用域

井号(#) 是注释,直到行结束,无多行注释.
$: 是分号,用于build语句,因为build语句中,:是分隔符.

### GN file

Config 是一种特殊的target，通过名称引入其它target

//tools/gn/tutorial:hello_world
1. //代表代码根目录。即:BUILD.gn所在位
2. 分号代表分隔
3. 最后代码一个target(exec,static_lib,dyn_lib)
4. Libs/lib_dirs 可以引用第三方库。

Component,表明使用GN的component模板。用于生成动、静态库。
## google 所有的项目都禁用了rtti/exceptions
- rtti 在 gn gen 时加 use_rtti=true即可
- exceptions 要修改 gn 文件,
  configs -= [ "//build/config/compiler:no_exceptions" ]
  configs += [ "//build/config/compiler:exceptions" ]
- 其它的编译参数，直接加cflags_cc/cflags_c里就行。

## 生成Visual Stdio 2019 工程
```
set DEPOT_TOOLS_UPDATE=0                                 #不更新depot_tools
set DEPOT_TOOLS_WIN_TOOLCHAIN=0                          #编译时使用本机VS工具链
set GYP_MSVS_VERSION=2019 
set GYP_GENERATORS=msvs-ninja,ninja                      #使用ninja编译
gn gen -ide=vs2019 --args="is_debug=true" out/vs2019  
```
其它版本除去更换版本号外，还要看gn 是不是支持。

# 编译
```
gn gen -C out/default
ninja -C out/default
```
# 输出