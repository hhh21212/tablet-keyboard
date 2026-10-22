' 平板键盘 - 手动连接（无窗口）：插上平板 USB 后双击本文件一次，连上后注入按键，断开自动退出。
' 用脚本自身所在目录定位 autoconnect.py；pythonw 需在 PATH 中。
' 若在任务计划环境里找不到 pythonw，把下面这行的 "pythonw.exe " 改成绝对路径，例如
'   C:\Users\<你的用户名>\AppData\Local\Microsoft\WindowsApps\pythonw.exe
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = dir
sh.Run "pythonw.exe " & Chr(34) & dir & "\autoconnect.py" & Chr(34), 0, False
