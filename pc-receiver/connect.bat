@echo off
chcp 65001 >nul
rem 备用·手动连接：插上平板 USB 后双击本文件一次，连上后无窗口，断开自动退出。
wscript.exe "%~dp0autoconnect.vbs"
