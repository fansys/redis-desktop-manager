## 前言
以下路径仅适用于我编译的环境

## 编译过程

### 安装工具

#### 安装 VSCode 2015

到 [http://blog.postcha.com/read/66](http://blog.postcha.com/read/66) 下载 Visual Studio 专业版，自定义安装，一定要勾选 VC ++，然后一直下一步，视机器配置而定，一般大约一个半小时装完。

#### 安装 Qt 5.9

到 [http://mirrors.ustc.edu.cn/qtproject/archive/qt/5.9/](http://mirrors.ustc.edu.cn/qtproject/archive/qt/5.9/) 下载最新到 Qt 5.9 版本，一直下一步就行，大约半个小时左右。

#### 安装 CMake

到 [https://cmake.org/download/](https://cmake.org/download/) 下载 32 位的版本，安装时注意勾选添加到 PATH

#### 安装 NSIS

安装打包工具 [http://nsis.sourceforge.net/Download](http://nsis.sourceforge.net/Download)

#### 安装 Python 2

到 https://www.python.org/downloads/ 下载安装 Python 2.7

#### 安装 OpenSSL

下载并安装 [Win 32 OpenSSL 1.0.x](https://slproweb.com/products/Win32OpenSSL.html) 版本

### 编译 Redis Desktop Manager

打开 “VS2015 x86 本机工具命令提示符”

#### 获取源码

```powershell
git clone --recursive https://github.com/uglide/RedisDesktopManager.git C:\Users\Win\Desktop\RedisDesktopManager
cd C:\Users\Win\Desktop\RedisDesktopManager
```

#### 编译 libssh2
```powershell
cd ./3rdparty/qredisclient/3rdparty/qsshclient/3rdparty/libssh2
cmake -G "Visual Studio 14 2015" -DCRYPTO_BACKEND=OpenSSL -DBUILD_EXAMPLES=off -DBUILD_TESTING=off -H. -Bbuild
cmake --build build --config "Release"
```

#### 设置版本号

版本号自己到 Github 找（0.9.8版本开始不需要）

```powershell
cd D:\redisdesktopmanager
set VERSION=0.9.4.1055
"C:\Python27\python.exe" ./build/utils/set_version.py %VERSION% > ./src/version.h
"C:\Python27\python.exe" ./build/utils/set_version.py %VERSION% > ./3rdparty/crashreporter/src/version.h
```

#### 编译 crashreporter

```powershell
cd ./3rdparty/crashreporter
# 如出错可手动替换字符串，原始文件为Makefile.Release
"C:\Qt\Qt5.9.7\5.9.7\msvc2015\bin\qmake.exe" CONFIG+=release DESTDIR=C:\Users\Win\Desktop\RedisDesktopManager\bin\windows\release
powershell -Command "(Get-Content Makefile.Release).replace('DEFINES       =','DEFINES       = -DAPP_NAME=\\\"RedisDesktopManager\\\" -DAPP_VERSION=\\\""%VERSION%"\\\" -DCRASH_SERVER_URL=\\\"https://oops.redisdesktop.com/crash-report\\\"')" > Makefile.Release2
nmake -f Makefile.Release2
```
编译crashrepoter需要一些依赖文件
```
修改INCPATH，新增以下内容 (根据实际路径配置)
INCPATH       = -I"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\include" -I"C:\Program Files (x86)\Windows Kits\10\Include\10.0.10240.0\ucrt"
修改LIBS，新增以下内容 (根据实际路径配置)
LIBS          = /LIBPATH:"C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Lib" /LIBPATH:"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib" -LIBPATH:"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.10240.0\ucrt\x86"
```

#### Qt 编译

打开 Qt Creator，打开 `./src/rdm.pro`

选择 “Deaktop Qt 5.9.6 MSVC2015 32bit”，构建选择 release，点击构建项目。

### 打包

```powershell
cd C:\Users\Win\Desktop\RedisDesktopManager
copy /y .\bin\windows\release\rdm.exe .\build\windows\installer\resources\rdm.exe
copy /y .\bin\windows\release\rdm.pdb .\build\windows\installer\resources\rdm.pdb
C:\Users\Win\Desktop\RedisDesktopManager\3rdparty\gbreakpad\src\tools\windows\binaries\dump_syms .\bin\windows\release\rdm.pdb  > .\build\windows\installer\resources\rdm.sym
cd build/windows/installer/resources/
C:\Qt\Qt5.9.7\5.9.7\msvc2015\bin\windeployqt --no-angle --no-opengl-sw --no-compiler-runtime --no-translations --release --force --qmldir C:\Users\Win\Desktop\RedisDesktopManager\src\qml rdm.exe
rmdir /S /Q .\platforminputcontexts
rmdir /S /Q .\qmltooling
rmdir /S /Q .\QtGraphicalEffects
del /Q  .\imageformats\qtiff.dll
del /Q  .\imageformats\qwebp.dll
cd C:\Users\Win\Desktop\RedisDesktopManager
call "C:\\Program Files (x86)\\NSIS\\makensis.exe" /V1 /DVERSION=%VERSION% ./build/windows/installer/installer.nsi
```

打包后的文件：`C:\Users\Win\Desktop\RedisDesktopManager\build\windows\installer\redis-desktop-manager-0.9.4.1055.exe`
