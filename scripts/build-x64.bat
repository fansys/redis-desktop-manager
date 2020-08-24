@echo off
set VERSION=2020.2.0
set HOME=%cd%
set QT_HOME=C:\Qt\Qt5.13.2\5.13.2
set RDM_HOME=C:\Users\Win\Desktop\RedisDesktopManager
set PACKAGE_HOME=%RDM_HOME%\build\windows\installer
set BUILD_HOME=%PACKAGE_HOME%\resources
set PYTHON_HOME=C:\Python37-x64
set NSIS_HOME=c:\Program Files (x86)\NSIS
rmdir /s /q %BUILD_HOME%
mkdir %BUILD_HOME%
cd %BUILD_HOME%

echo 当前打包版本: %VERSION%

echo 复制主程序
copy %RDM_HOME%\bin\windows\release\rdm.exe .\

rem 执行依赖库引入
echo 执行依赖库引入
%QT_HOME%\msvc2017_64\bin\windeployqt --no-angle --no-opengl-sw --no-compiler-runtime --no-translations --release --force --qmldir %RDM_HOME%\src\qml rdm.exe

rem 删除一些不必要的文件
echo 删除一些不必要的文件
rmdir /S /Q .\qmltooling
rmdir /S /Q .\QtGraphicalEffects
del /Q  .\imageformats\qtiff.dll
del /Q  .\imageformats\qwebp.dll

rem 添加python依赖
echo 添加Python运行环境
copy %PYTHON_HOME%\embed\python37.zip .\
copy %PYTHON_HOME%\embed\python37.dll .\

echo 添加Python依赖
mkdir Lib\site-packages
xcopy %PYTHON_HOME%\Lib\site-packages\cbor .\Lib\site-packages\cbor\ /e /Y
xcopy %PYTHON_HOME%\Lib\site-packages\msgpack .\Lib\site-packages\msgpack\ /e /Y
xcopy %PYTHON_HOME%\Lib\site-packages\rdbtools .\Lib\site-packages\rdbtools\ /e /Y
xcopy %PYTHON_HOME%\Lib\site-packages\redis .\Lib\site-packages\redis\ /e /Y
copy %PYTHON_HOME%\Lib\site-packages\bitstring.py .\Lib\site-packages\  /Y
copy %PYTHON_HOME%\Lib\site-packages\lzf.cp37-win_amd64.pyd .\Lib\site-packages\  /Y

rem 添加rdm自带python依赖
echo 添加rdm自带Python依赖
xcopy %RDM_HOME%\src\py\* .\Lib\site-packages\ /e /Y

rem 编译.py
echo 编译.py
cd Lib/site-packages
%PYTHON_HOME%\python -m compileall -b .


rem del /s .\*.py
echo 删除编译完的py文件和缓存
del /s requirements.txt

for /r . %%a in (*.py) do (
	if exist %%a (
		echo delete %%a
	    del /a /f "%%a"
    )
)
 
for /r . %%a in (__pycache__) do (
	if exist %%a (
		echo delete %%a
        rd /s /q "%%a"
	)
)

cd %PACKAGE_HOME%

rem 打包
echo 打包exe安装包
"%NSIS_HOME%\makensis.exe" /V1 /DVERSION=%VERSION% ./installer.nsi
del /s %PACKAGE_HOME%\redis-desktop-manager-2020.2.0_x64.exe
rename %PACKAGE_HOME%\redis-desktop-manager-2020.2.0.exe redis-desktop-manager-2020.2.0_x64.exe
echo 打包完成，安装包可在 %PACKAGE_HOME% 下找到

cd %HOME%

pause .
