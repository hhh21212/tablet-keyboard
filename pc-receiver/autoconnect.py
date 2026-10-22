"""平板键盘一次性连接器：插上 USB 后由 Windows 任务计划（USB 事件触发）调用一次。

流程：
  1) 若已有实例在连接（锁文件 + 存活 PID），直接退出，避免插别的 USB 设备触发重复连接；
  2) 短重试等平板 hdc 就绪（hdc list targets 出现序列号）；
  3) 拉起「平板键盘」App + 建立 tcp:5959 转发 + 连接收端注入按键（阻塞到断开）；
  4) 断开后退出，不重连、不常驻。下次插 USB 再由事件触发。

用 pythonw 运行；所有 hdc 调用带 CREATE_NO_WINDOW，全程无窗口、空闲零后台。
"""
import ctypes
import datetime
import json
import os
import subprocess
import sys
import time

DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(DIR)
if DIR not in sys.path:
    sys.path.insert(0, DIR)

import receiver  # 复用 run_tcp（连接 + 注入循环）

def _load_config():
    """读取环境相关配置（hdc 路径 / 设备序列号等）。

    真实 config.json 不进仓库（.gitignore 排除），仓库只提交 config.example.json。
    加载顺序：config.json > config.example.json > 内置默认值。
    """
    default = {
        "hdc": "",
        "serial": "",
        "bundle": "com.example.tabletkeyboard",
        "ability": "EntryAbility",
        "tcp": "127.0.0.1:5959",
    }
    for name in ("config.json", "config.example.json"):
        path = os.path.join(DIR, name)
        if os.path.exists(path):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    cfg = json.load(f)
                merged = dict(default)
                merged.update({k: v for k, v in cfg.items() if k in default})
                return merged
            except Exception:
                pass  # 配置损坏则继续尝试下一个 / 退回默认
    return default


_cfg = _load_config()
HDC = _cfg["hdc"]
SERIAL = _cfg["serial"]
BUNDLE = _cfg["bundle"]
ABILITY = _cfg["ability"]
TCP = _cfg["tcp"]
LOCK = os.path.join(DIR, "autoconnect.lock")
LOG = os.path.join(DIR, "autoconnect.log")
WAIT_READY = 10     # 最多等平板 hdc 就绪的秒数
CONNECT_TRIES = 8   # 连接重试次数（等 App 的 TCP 服务起来）


def _log(msg):
    try:
        with open(LOG, "a", encoding="utf-8") as f:
            f.write("%s %s\n" % (datetime.datetime.now().strftime("%H:%M:%S"), msg))
    except Exception:
        pass


def _hdc(*args):
    cmd = [HDC] + (["-t", SERIAL] if SERIAL else []) + list(args)
    try:
        subprocess.run(cmd, capture_output=True, timeout=15,
                       creationflags=subprocess.CREATE_NO_WINDOW)
    except Exception:
        pass


def device_ready():
    try:
        r = subprocess.run([HDC, "list", "targets"], capture_output=True, timeout=10,
                           creationflags=subprocess.CREATE_NO_WINDOW)
        out = r.stdout.decode("utf-8", errors="replace")
        return SERIAL in out
    except Exception:
        return False


def _pid_alive(pid):
    try:
        h = ctypes.windll.kernel32.OpenProcess(0x1000, False, pid)  # PROCESS_QUERY_LIMITED_INFORMATION
        if not h:
            return False
        ctypes.windll.kernel32.CloseHandle(h)
        return True
    except Exception:
        return True  # 不确定就当还在，避免误重连


def _locked_by_other():
    if not os.path.exists(LOCK):
        return False
    try:
        with open(LOCK, "r") as f:
            pid = int(f.read().strip())
    except Exception:
        return False
    if _pid_alive(pid):
        return True
    try:  # 锁是死的（残留），清掉
        os.remove(LOCK)
    except Exception:
        pass
    return False


def _acquire_lock():
    try:
        with open(LOCK, "w") as f:
            f.write(str(os.getpid()))
    except Exception:
        pass


def _release_lock():
    try:
        os.remove(LOCK)
    except Exception:
        pass


def main():
    if _locked_by_other():
        _log("已有实例在连接，跳过")
        return

    # 等平板 hdc 就绪（USB 事件触发时 hdc 可能还没枚举完设备）
    deadline = time.time() + WAIT_READY
    while time.time() < deadline and not device_ready():
        time.sleep(1)
    if not device_ready():
        _log("未检测到平板（非平板 USB 事件），退出")
        return

    _log("检测到平板，开始连接")
    _acquire_lock()
    try:
        _hdc("shell", "aa", "start", "-a", ABILITY, "-b", BUNDLE)
        for _ in range(CONNECT_TRIES):
            _hdc("fport", "tcp:5959", "tcp:5959")
            try:
                receiver.run_tcp(TCP)  # 阻塞到断开
                _log("连接已断开")
                break
            except Exception as e:
                _log("连接失败（重试中）：%s" % e)
                time.sleep(1)
    finally:
        _release_lock()


if __name__ == "__main__":
    main()
