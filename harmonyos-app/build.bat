@echo off
rem 平板键盘 · HarmonyOS HAP 命令行构建脚本
rem 用法：build.bat [assembleHap]  （默认 assembleHap，也可传 clean / --stop-daemon 等）
rem 若 DevEco Studio 不在默认安装路径，先 set DEVECO_ROOT=你的路径 再运行。
setlocal

if not defined DEVECO_ROOT set "DEVECO_ROOT=C:\Program Files\Huawei\DevEco Studio"
set "NODE_HOME=%DEVECO_ROOT%\tools\node"
set "DEVECO_SDK_HOME=%DEVECO_ROOT%\sdk"
set "JAVA_HOME=%DEVECO_ROOT%\jbr"
set "PATH=%DEVECO_ROOT%\tools\node;%DEVECO_ROOT%\tools\ohpm\bin;%DEVECO_ROOT%\jbr\bin;%PATH%"

set "TASK=assembleHap"
if not "%~1"=="" set "TASK=%1"

node "%DEVECO_ROOT%\tools\hvigor\bin\hvigorw.js" %TASK%
exit /b %errorlevel%
