# tablet-keyboard · 平板键盘

> 把 HarmonyOS 平板变成 Windows 电脑的无线键盘 + 鼠标。

平板装一个 HarmonyOS（ArkTS）键盘 App，电脑跑一个 Python 接收端，两者通过**有线（USB 经 hdc 端口转发）或蓝牙（SPP 串口）**相连。平板上敲键 / 划鼠标 → 换行分隔的 JSON 报文 → 电脑端用 `SendInput` 注入成真键盘 / 鼠标输入。

## ✨ 功能

- ⌨️ **完整 QWERTY 键盘**：数字行 + 主键盘，修饰键按住生效，长按自动重复
- 🖱️ **鼠标模式**：相对位移移动、左/右/中键点击、滚轮
- ⚡ **宏按键**：复制 / 粘贴 / 剪切 / 全选 / 撤销 / 重做 / 保存 / 截图 / 锁屏 / 任务管理器 / 中英切换
- 🔌 **双通道**：有线（USB 经 `hdc fport` 转发 TCP:5959）、蓝牙（SPP 串口 COM）
- 🚀 **USB 自动连接**：插上平板由 Windows 任务计划触发，连上即注入，断开自动退出，空闲零后台
- 🧪 **自测脚本**：`selftest.py` 一键验证注入是否生效

## 🧱 结构

```
tablet-keyboard/
├── harmonyos-app/        # 平板端（HarmonyOS / ArkTS / ArkUI）
│   └── entry/src/main/ets/
│       ├── keyboard/     # 键位定义 KeyDefs、键盘控制器（长按重复/宏展开）
│       ├── connection/   # TCP 服务端（5959 端口）+ 报文协议 Protocol
│       └── pages/        # 键盘页 Index
└── pc-receiver/          # 电脑端（Python）
    ├── injector.py       # ctypes 调 SendInput：键盘 + 鼠标注入（零依赖、免管理员）
    ├── keymap.py         # 键名 → Windows 虚拟键码(VK) 映射
    ├── receiver.py       # 读 TCP / 蓝牙串口，注入 + 宏展开
    ├── selftest.py       # 自测注入
    └── autoconnect.py    # USB 插入自动连接（hdc 拉起 App + 端口转发 + 连接）
```

## 📡 报文协议

换行分隔的 JSON，两端各维护一份同构实现（`Protocol.ets` ↔ `receiver.py`）：

| 类型 | 示例 | 说明 |
|------|------|------|
| 按键 | `{"t":"k","e":"down","k":"A"}` / `"up"` / `"tap"` | 键名见 `keymap.py` |
| 宏 | `{"t":"macro","m":"COPY"}` | 见 `receiver.py` 的 `MACROS` |
| 鼠标移动 | `{"t":"m","e":"move","dx":3,"dy":-2}` | 相对位移 |
| 鼠标点击 / 滚轮 | `{"t":"m","e":"click","b":"left"}` / `{"t":"m","e":"scroll","dy":-1}` | `left/right/middle` |

## 🚀 运行

电脑端：

```bash
# 有线（USB）：先在电脑执行一次端口转发
hdc fport tcp:5959 tcp:5959
python receiver.py --tcp 127.0.0.1:5959

# 蓝牙（平板与电脑配对后，电脑建「传入」COM 口）
python receiver.py --com COM5

# 自测注入是否正常
python selftest.py
```

平板端：用 DevEco Studio 打开 `harmonyos-app` 构建安装，打开 App 即开始监听 5959 端口。

> 蓝牙模式依赖 `pyserial`（`pip install pyserial`）；有线模式仅标准库。

## ⚠️ 配置与注意

- `pc-receiver/autoconnect.py` 从 `config.json` 读取 hdc 路径 / 设备序列号等环境相关配置；仓库只提交 `config.example.json`，真实 `config.json` 已被 `.gitignore` 排除。
- `harmonyos-app/build-profile.json5` 含签名密码，已被 `.gitignore` 排除；请按 `build-profile.json5.example` 自行填写。
- 仅作个人学习与自用，不含任何预置服务。

## 📄 License

[MIT](LICENSE)
