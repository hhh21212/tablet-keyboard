# 平板键盘 · Windows 接收端

接收平板发来的按键/鼠标报文，注入成 Windows 真键盘/鼠标输入。

## 文件

- `injector.py` — ctypes 调 `SendInput`，键盘 + 鼠标注入（零依赖、无需管理员）
- `keymap.py` — 键名 → Windows 虚拟键码(VK) 映射
- `receiver.py` — 主程序，读蓝牙串口 / TCP 并注入
- `selftest.py` — 自测注入是否生效

## 运行

```bash
# 有线（配 hdc 端口转发走 USB）：先在电脑执行一次
hdc fport tcp:5959 tcp:5959
python receiver.py --tcp 127.0.0.1:5959

# 蓝牙（平板与电脑配对后，电脑建「传入」COM 口）
python receiver.py --com COM5

# 自测注入是否正常
python selftest.py
```

## 报文协议（换行分隔 JSON）

| 类型 | 示例 | 说明 |
|------|------|------|
| 按键按下/抬起/点按 | `{"t":"k","e":"down","k":"A"}` / `"up"` / `"tap"` | 键名见 `keymap.py` |
| 宏（组合键） | `{"t":"macro","m":"COPY"}` | 见 `receiver.py` 的 `MACROS` |
| 鼠标移动 | `{"t":"m","e":"move","dx":3,"dy":-2}` | 相对位移 |
| 鼠标点击/按下/抬起 | `{"t":"m","e":"click","b":"left"}` | `left/right/middle` |
| 滚轮 | `{"t":"m","e":"scroll","dy":-1}` | `dy` 为格数 |

## 依赖

- 蓝牙模式需要 `pyserial`：`pip install pyserial`
- 有线模式仅用标准库，无需额外依赖
