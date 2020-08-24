#  Redis Desktop Manager for Mac


## 下载源码
git clone --recursive https://github.com/uglide/RedisDesktopManager.git

## 安装XCode

## 安装Homebrew
由于编译rdm需要用到其他工具或三方库，因此系统最好安装有包管理器方便下载或更新其他软件包

## 拷贝plist文件
```bash
cd ./src
cp ./resources/Info.plist.sample ./resources/Info.plist
```
修改Info.plist
设置 `Bundle version`  `Bundle version string (short)` , 修改为当前编译的版本
修改最低系统要求  `Minimum system version` , 经测试可以设置为 10.13.0

## 安装依赖软件包
brew install openssl cmake
安装python 3.7.x installer
**使用Python官网上提供的安装包**，经测试如果使用brew安装，无法找到Python的依赖，该问题待解决


## 安装QT 5.13.x
下载QT 5.13.2版本
安装时选择 `OS X` 和 `Qt Charts`

## 编译语言文件
使用QT打开项目，编译语言文件
工具 -> 外部 -> QT语言家
按照以下顺序执行：更新翻译(lupdate) -> 发布翻译(lrelease)，如果只用英文界面的话这步可忽略

## 安装 Python 依赖
```bash
cd src
pip3 install -t ./bin/osx/release -r py/requirements.txt --upgrade
```

## 编译
```bash
# 生成 Makefile
~/Qt5.13.2/5.13.2/clang_64/bin/qmake CONFIG-=debug CONFIG+=sdk_no_version_check
# make
make -s -j 8
```


## QT Framework
```bash
cd bin/osx/release
~/Qt5.13.2/5.13.2/clang_64/bin/macdeployqt Redis\ Desktop\ Manager.app -qmldir=../../../src/qml
```

## 打包
创建一个文件夹，命名为 `Redis Desktop Manager`
将 `Redis Desktop Manager.app` 放到文件夹中，在用户应用程序目录右键制作替身，将生成的链接也访问文件夹中
打开磁盘管理工具，点击 文件 -> 新建映像 -> 来自文件夹的映像，选择上面的文件夹，选择保存dmg文件的位置，保存

至此安装包制作完成
