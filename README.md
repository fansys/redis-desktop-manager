# Redis Desktop Manager 编译

如果电脑运行Redis Desktop Manager时提示: 由于找不到MSVCP140.dll,无法继续执行代码。

那么先安装所需环境(VC_redist 2015):

[https://www.microsoft.com/zh-CN/download/details.aspx?id=48145](https://www.microsoft.com/zh-CN/download/details.aspx?id=48145)

PS: 编译步骤还是比较多的, 还要下载很多国外网站的工具, 网速不好得下好久, 下完之后又是各种配置, 没几个小时搞完不完, 不过弄好一次之后下次新版本编译10分钟搞定, 我写这篇文章已经踩了一天的坑= =!, 希望后边的小伙伴少踩坑我已经是能写多详细写多详细了.

编译环境
----

OS：Windows 7 x64

Visual Studio 2017 Community Edition

QT 5.13.2

Python 3.7.9

OpenSSL  1.1.1.g

NSIS



软件安装
----

先看官方编译步骤: [http://docs.redisdesktop.com/en/latest/install/#build-from-source](http://docs.redisdesktop.com/en/latest/install/#build-from-source) 注意Qt和Python的需要版本

### Visual Studio 2017 Community

​    下载地址: [https://docs.microsoft.com/zh-cn/visualstudio/productinfo/vs2017-system-requirements-vs](https://docs.microsoft.com/zh-cn/visualstudio/productinfo/vs2017-system-requirements-vs)

​    使用 Community 版即可

​    安装时在工作负载界面勾选 `使用C++的桌面开发` 选项

### QT 5.13.x

​    QT有以下3中安装途径

​    [https://www.qt.io/download-qt-installer](https://www.qt.io/download-qt-installer) 在线安装工具(需要C盘临时空间有7G)

​    [http://download.qt.io/official_releases/qt/](http://download.qt.io/official_releases/qt/) 完整包下载(3.6G)

​    [https://mirrors.ustc.edu.cn/qtproject/archive/qt/](https://mirrors.ustc.edu.cn/qtproject/archive/qt/) 完整包下载(镜像网站)

​    QT安装时组件要勾选: `MSVC 2017 64-bit` 和 `Qt Charts`

​    如果需要编译x86版本，需要勾选  `MSVC 2017 32-bit`

### Python 3.7.x

​    下载地址: https://www.python.org/downloads/](https://www.python.org/downloads/)

​    需要下载以下两个版本

- executable installer: Python开发工具，需要安装
- embeddable zip: 提供rdm的运行库，打包时使用

​    安装时勾选: `Add Python to environment variables`  和 `Download debug bnaries (requires Vs 2015 or later)` 安装目录:`C:\Python37-x64` 

​    如果需要编译rdm32位版本，则下载 `Windows x86` 版本，并安装到`C:\Python37-x86` 

### OpenSSL

​    下载地址: [https://slproweb.com/products/Win32OpenSSL.html](https://slproweb.com/products/Win32OpenSSL.html)

​    安装目录:`C:\OpenSSL-Win64`     

​    如果需要编译rdm32位版本，则下载 `Win32` 版本，并安装到`C:\OpenSSL-Win32` 

### Nuget

​    下载地址: [https://www.nuget.org/downloads](https://www.nuget.org/downloads)

​    下载最新版本, 单独的exe程序, 用来下载一个依赖包

​    需要配置环境变量以便命令行可以访问

### NSIS 3.xx

​    下载地址: [http://nsis.sourceforge.net/Download](http://nsis.sourceforge.net/Download)

​    打包rdm安装包，如不需要打包可不装



源码下载
--------

源码下载有两种方式

### 1. git clone仓库

​    执行以下命令即可递归克隆主项目和依赖的项目源码

```bash
git clone --recursive https://github.com/uglide/RedisDesktopManager.git
```



### 2. 下载仓库zip包（适用于网络比较慢的情况）

​    RedisDesktopManager 的GitHub地址: [https://github.com/uglide/RedisDesktopManager](https://github.com/uglide/RedisDesktopManager) 查看 `3rdparty`目录，找到依赖的项目，这些项目是链接过去的

​    **本文下载时间2020-08-24, 后面这些依赖可能会变**

​    **主源码**: [https://github.com/uglide/RedisDesktopManager/releases/tag/2020.2](https://github.com/uglide/RedisDesktopManager/releases/tag/2020.2) 下载Source code (zip)

> - 主源码依赖 pyotherside: [https://github.com/uglide/pyotherside/tree/c1a8cc03266b3b620ba9195e365e8751a8e4c9ef](https://github.com/uglide/pyotherside/tree/c1a8cc03266b3b620ba9195e365e8751a8e4c9ef) Code下载ZIP包
>
> - 主源码依赖 qredisclient: [https://github.com/uglide/qredisclient/tree/9fe79f7c13b9811228db33abf75a83464a7cd2e2](https://github.com/uglide/qredisclient/tree/9fe79f7c13b9811228db33abf75a83464a7cd2e2) Code下载ZIP包
>
> - qredisclient 依赖 asyncfuture: [https://github.com/benlau/asyncfuture/tree/5ca03043bc54f310bae3097553c5a034f2032ec5](https://github.com/benlau/asyncfuture/tree/5ca03043bc54f310bae3097553c5a034f2032ec5) Code下载ZIP包
>
> - qredisclient 依赖 hiredis: [https://github.com/redis/hiredis/tree/685030652cd98c5414ce554ff5b356dfe8437870](https://github.com/redis/hiredis/tree/685030652cd98c5414ce554ff5b356dfe8437870) Code下载ZIP包

​    将下载的依赖包按照主源码仓库的目录结构解压到主源码 `3rdparty` 目录下



源码编译
---------

### 1. 应用 hiredis 补丁

​    3rdparty/qredisclient/3rdparty/hiredis目录，打开cmd窗口执行 `git apply ../hiredis-win.patch` 如果没有提示就是成功，有提示就是失败了，这是修复windows平台下代码格式的兼容性问题的，如果不执行，编译时就会报各种中语法错误少了；号之类的



### 2. 下载 zlib-msvc14

​    进入3rdparty目录打开cmd窗口执行: `nuget install zlib-msvc14-x64 -Version 1.2.11.7795` 会下载zlib依赖

​    确保nuget.exe已配置环境变量或拼写nuget.exe全路径，否则会找不到命令

​    如果需要编译rdm32位版本，则执行: `nuget install zlib-msvc14-x86 -Version 1.2.11.7795` 



### 3. 安装 Python 依赖包

​    进入 src/py 路径，打开cmd窗口执行: `pip install -r requirements.txt` 确保已经安装好了Python 3.7.x才能执行该命令

​    如果提示找不到 pip，需要配置 Python 安装路径下的Scripts文件夹到环境变量，或者使用pip.exe的全路径



### 4. 使用 Qt Creator 打开项目

​    进入 src 目录, 使用 Qt Creator 打开`rdm.pro`文件, 确保已经安装好了Qt才能打开该文件

​    代码结构如图所示:

​    尤其看依赖项目的结构是否配置正确

![](images\rdm_project.jpg)



### 5. 修改版本号

​    编辑视图中打开rdm/rdm.pro文件，修改版本号`VERSION=2020.2.0-dev` 改为 `VERSION=2020.2.0` 改完保存（必须改,否则编译时报版本号必须为数值型错误）



### 6. 检查编译依赖路径

​    检查以下几个文件，确认配置的依赖路径与实际路径一致

​    如果需要编译32位版本RDM，此时就需要将这三个依赖配置为32位的版本的路径

- 3rdparty/3rdparty.pri, `OPENSSL_LIB_PATH` 项配置的 OpenSSL 路径，和 `ZLIBDIR` 项配置的 Zlib 路径
- 3rdparty/pyotherside.pri , 开头 Python 下的 `QMAKE_LIBS` 和 `INCLUDEPATH` 项配置的 Python 路径
- 

### 7. 修改构建配置为Release

​    转到项目视图，左侧选择Build版本，然后设置Build的编译构建配置为Release

- 如果需要编译64位版本rdm，则选择Deskto Qt 5.13.2 MSVC2017 64bit

- 如果需要编译32位版本rdm，则选择Deskto Qt 5.13.2 MSVC2017 32bit

![](images\rdm_release.jpg)



### 8.更新语言文件

编译之前先更新语言文件

按照以下顺序执行：更新翻译(lupdate) -> 发布翻译(lrelease)，如果只用英文界面的话这步可忽略

![](images\rdm_language.jpg)



### 9. 构建

​    点Qt界面左下角图标是锤子的按钮进行构建, 右下角就会弹出构建的进度, 显示绿色为构建完成

![](images\rdm_build.jpg)



### 10. 生成发布文件

​    编译好后进入 bin/windows/release 目录如果能看到 `rdm.exe` 文件则没问题, 然后将 `rdm.exe` 文件复制到 build/windows/installer/resources 目录中

​    在 build/windows/installer/resources 目录中执行以下命令生成运行需要的依赖

```bash
# 注意: 命令中的windeployqt是一个exe程序, 该程序的目录需要按实际Qt的安装位置修改, src\qml目录也是按源码解压时所在位置的绝对路径修改
C:\Qt\Qt5.13.2\5.13.2\msvc2017_64\bin\windeployqt --no-angle --no-opengl-sw --no-compiler-runtime --no-translations --release --force --qmldir C:\project\rdm-2020.2\src\qml rdm.exe
# 删除不需要的文件
rmdir /S /Q .\QtGraphicalEffects
del /Q  .\imageformats\qtiff.dll
del /Q  .\imageformats\qwebp.dll
```



### 11. 验证 rdm.exe 可以运行

​    至此双击打开 `rdm.exe` 程序应该是可以看到界面的了

![](images\rdm.jpg)

### 12. 添加 Python 运行环境

​    如果没有安装Python工具，运行rdm是会提示找不到Python37.dll，因此需要将Python的运行环境打包到安装包中

​    使用到下载好的 `python-3.7.x-embed-amd64.zip` 包将里边的 `python37.dll` 和 `python37.zip` 复制到build/windows/installer/resources目录中

​    如果编译的是32位版本，这里使用的Python包也需要使用32位版本的



### 13. 添加 Python 依赖包

​    a. 进入Python的安装目录，进入Lib/site-packages下复制以下文件到 build/windows/installer/resources/Lib/site-packages 目录中

> cbor
> msgpack
> rdbtools
> redis
> bitstring.py
> lzf.cp37-win_amd64.pyd

​    b. 进入 src/py 目录复制所有文件到 build/windows/installer/resources/Lib/site-packages 目录中

​    c. 进入 src/phpserialize 目录复制 phpserialize.py 到 build/windows/installer/resources/Lib/site-packages 目录中

​    以上完成后，在 build/windows/installer/resources/Lib/site-packages 目录下，执行以下命令编译 .py 文件

```bash
# 编译 .py
python -m compileall -b .

# 编译完成后删除py源码文件, 保留pyc文件
del /s .\*.py
```



### 14. 制作安装包

​    这个时候其实已经是绿色版的rdm工具了，发给别人自己用都可以，但是想做成安装包，装完注册在系统上就需要用到NSIS工具.

​    项目根目录执行以下命令打包exe

```bash
set VERSION=2020.2.0
"c:\Program Files (x86)\NSIS\makensis.exe" /V1 /DVERSION=%VERSION% ./build/windows/installer/installer.nsi
```

​    编译完成后进入 build/windows/installer` 目录就能看到编译好的安装程序了

​    如果是编译32位版本，需要修改installer.nsi，删除以下代码

```bash
${IfNot} ${RunningX64}
    MessageBox MB_OK "Starting from version 2019.0.0, Redis Desktop Manager doesn't support 32-bit Windows"
    Quit
${EndIf}
```





## Q&A

### 1.  module 'formatters' has no attribute 'get.formatters_list'

​    启动后在日志中提示以下错误，这个错误是没有添加Python安装目录下Lib/site-packages中依赖包，重新执行 12.添加Python依赖包的 a步骤

```bash
Formatters: Function not found: 'formatters.get_formatters_list' (Traceback (most recent call last):
  File "<string>", line 1, in <module>
AttributeError: module 'formatters' has no attribute 'get.formatters_list'
)
```



### 2. 屏蔽RDM更新

​    屏蔽更新检查提示:

​    编辑 src/modules/updater/updater.cpp 文件注释以下代码:

```c++
// manager->get(QNetworkRequest(updateUrl));
```