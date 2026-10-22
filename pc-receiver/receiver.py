"""平板键盘接收端主程序。

从蓝牙串口（--com）或 TCP（--tcp，配 hdc 端口转发走 USB 有线）读取
换行分隔的 JSON 报文，注入成 Windows 真键盘/鼠标输入。

报文协议（示例）：
  {"t":"k","e":"down","k":"A"}   # 按键按下
  {"t":"k","e":"up","k":"A"}     # 按键抬起
  {"t":"k","e":"tap","k":"F5"}   # 点按（down+up）
  {"t":"macro","m":"COPY"}       # 宏（组合键）
  {"t":"m","e":"move","dx":3,"dy":-2}   # 鼠标相对移动
  {"t":"m","e":"click","b":"left"}      # 鼠标点击
  {"t":"m","e":"scroll","dy":-1}        # 滚轮
"""
import argparse
import json
import sys

import injector
from keymap import lookup

# 宏：名字 -> [(动作, 键名), ...]，动作 ∈ down/up/tap
MACROS = {
    "COPY": [("down", "LCTRL"), ("tap", "C"), ("up", "LCTRL")],
    "PASTE": [("down", "LCTRL"), ("tap", "V"), ("up", "LCTRL")],
    "CUT": [("down", "LCTRL"), ("tap", "X"), ("up", "LCTRL")],
    "SELECT_ALL": [("down", "LCTRL"), ("tap", "A"), ("up", "LCTRL")],
    "UNDO": [("down", "LCTRL"), ("tap", "Z"), ("up", "LCTRL")],
    "REDO": [("down", "LCTRL"), ("tap", "Y"), ("up", "LCTRL")],
    "SAVE": [("down", "LCTRL"), ("tap", "S"), ("up", "LCTRL")],
    "SCREENSHOT": [("down", "LWIN"), ("down", "LSHIFT"), ("tap", "S"), ("up", "LSHIFT"), ("up", "LWIN")],
    "LOCK": [("down", "LWIN"), ("tap", "L"), ("up", "LWIN")],
    "TASK_MANAGER": [("down", "LCTRL"), ("down", "LSHIFT"), ("tap", "ESC"), ("up", "LSHIFT"), ("up", "LCTRL")],
    "IME_TOGGLE": [("down", "LCTRL"), ("tap", "SPACE"), ("up", "LCTRL")],
}


VERBOSE = False


def _warn(msg):
    print("[warn] %s" % msg, file=sys.stderr, flush=True)


def _debug(msg):
    if VERBOSE:
        print("[recv] %s" % msg, file=sys.stderr, flush=True)


def run_macro(name):
    for action, arg in MACROS[name]:
        v = lookup(arg)
        if not v:
            _warn("macro %s references unknown key %s" % (name, arg))
            continue
        vk, ext = v
        if action == "down":
            injector.key_down(vk, ext)
        elif action == "up":
            injector.key_up(vk, ext)
        else:
            injector.tap(vk, ext)


def dispatch(msg):
    t = msg.get("t")
    if t == "k":
        v = lookup(msg.get("k", ""))
        if not v:
            _warn("unknown key: %r" % msg.get("k"))
            return
        vk, ext = v
        e = msg.get("e", "tap")
        if e == "down":
            injector.key_down(vk, ext)
        elif e == "up":
            injector.key_up(vk, ext)
        else:
            injector.tap(vk, ext)
    elif t == "macro":
        m = msg.get("m", "")
        if m in MACROS:
            run_macro(m)
        else:
            _warn("unknown macro: %r" % m)
    elif t == "text":
        injector.type_text(msg.get("text", ""))
    elif t == "m":
        e = msg.get("e", "")
        if e == "move":
            injector.mouse_move(int(msg.get("dx", 0)), int(msg.get("dy", 0)))
        elif e == "click":
            injector.mouse_click(msg.get("b", "left"))
        elif e == "down":
            injector.mouse_down(msg.get("b", "left"))
        elif e == "up":
            injector.mouse_up(msg.get("b", "left"))
        elif e == "scroll":
            injector.mouse_scroll(int(msg.get("dy", 0)))
        else:
            _warn("unknown mouse event: %r" % e)
    else:
        _warn("unknown message: %r" % msg)


def feed_line(line):
    line = line.strip()
    if not line:
        return
    _debug(line)
    try:
        dispatch(json.loads(line))
    except (json.JSONDecodeError, ValueError) as e:
        _warn("bad line %r: %s" % (line, e))


def _process_buffer(buf, data):
    buf += data
    while b"\n" in buf:
        line, buf = buf.split(b"\n", 1)
        feed_line(line.decode("utf-8", errors="replace"))
    return buf


def run_tcp(addr):
    import socket
    host, _, port = addr.rpartition(":")
    sock = socket.create_connection((host or "127.0.0.1", int(port)))
    print("[connected] tcp %s:%s" % (host or "127.0.0.1", port), flush=True)
    buf = b""
    while True:
        data = sock.recv(4096)
        if not data:
            break
        buf = _process_buffer(buf, data)


def run_com(port):
    import serial
    ser = serial.Serial(port, baudrate=115200, timeout=0.1)
    print("[connected] %s" % port, flush=True)
    buf = b""
    while True:
        n = ser.in_waiting
        data = ser.read(n if n > 0 else 1)
        if data:
            buf = _process_buffer(buf, data)


def run_stdin():
    for line in sys.stdin.buffer:
        feed_line(line.decode("utf-8", errors="replace"))


def main():
    ap = argparse.ArgumentParser(description="平板键盘接收端")
    ap.add_argument("--com", help="蓝牙串口 COM 口，如 COM5")
    ap.add_argument("--tcp", help="TCP 地址，如 127.0.0.1:5959")
    ap.add_argument("--stdin", action="store_true", help="从标准输入读（测试用）")
    ap.add_argument("--verbose", action="store_true", help="打印收到的每行报文（调试用）")
    args = ap.parse_args()

    global VERBOSE
    VERBOSE = args.verbose

    try:
        if args.stdin:
            run_stdin()
        elif args.tcp:
            run_tcp(args.tcp)
        elif args.com:
            run_com(args.com)
        else:
            ap.print_help()
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print("[连接失败] %s" % e, flush=True)
    finally:
        injector.release_all()
        print("[done] all keys released", flush=True)


if __name__ == "__main__":
    main()
