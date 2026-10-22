"""接收端注入自测：不依赖平板，直接在 Windows 上验证 SendInput 是否生效。

1. CapsLock 开关状态翻转（验证键盘注入）
2. 鼠标光标位置移动（验证鼠标注入）

运行：python selftest.py
注意：测试会短暂切换 CapsLock（随后自动还原）并轻微移动鼠标，属预期现象。
"""
import ctypes
import time
from ctypes import wintypes

import injector

VK_CAPITAL = 0x14


def caps_state():
    return ctypes.windll.user32.GetKeyState(VK_CAPITAL) & 0x0001


def cursor_pos():
    pt = wintypes.POINT()
    ctypes.windll.user32.GetCursorPos(ctypes.byref(pt))
    return pt.x, pt.y


def main():
    ok = True

    # 1) 键盘：CapsLock 翻转
    before = caps_state()
    injector.tap(VK_CAPITAL)
    time.sleep(0.2)
    after = caps_state()
    flipped = after != before
    print("CapsLock before=%d after=%d -> %s" % (before, after, "OK" if flipped else "FAIL"))
    injector.tap(VK_CAPITAL)  # 还原
    time.sleep(0.2)
    print("CapsLock restored=%d" % caps_state())
    ok = ok and flipped

    # 2) 鼠标：相对移动
    x0, y0 = cursor_pos()
    injector.mouse_move(60, 40)
    time.sleep(0.2)
    x1, y1 = cursor_pos()
    moved = (x1, y1) != (x0, y0)
    print("cursor %s -> %s -> %s" % ((x0, y0), (x1, y1), "OK" if moved else "FAIL"))
    ok = ok and moved

    print("SELFTEST %s" % ("PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
