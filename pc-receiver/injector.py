"""Windows 输入注入：用 ctypes 调 SendInput 实现键盘 + 鼠标注入。

零第三方依赖、无需管理员权限。用于「平板当键盘」接收端把收到的按键/鼠标
报文注入成真键盘/鼠标输入。
"""
import ctypes
from ctypes import wintypes

# --- SendInput 相关常量 ---
INPUT_MOUSE = 0
INPUT_KEYBOARD = 1

KEYEVENTF_EXTENDEDKEY = 0x0001
KEYEVENTF_KEYUP = 0x0002
KEYEVENTF_UNICODE = 0x0004

MOUSEEVENTF_MOVE = 0x0001
MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_RIGHTDOWN = 0x0008
MOUSEEVENTF_RIGHTUP = 0x0010
MOUSEEVENTF_MIDDLEDOWN = 0x0020
MOUSEEVENTF_MIDDLEUP = 0x0040
MOUSEEVENTF_WHEEL = 0x0800
WHEEL_DELTA = 120


# --- 结构体定义 ---
class KEYBDINPUT(ctypes.Structure):
    _fields_ = [
        ("wVk", wintypes.WORD),
        ("wScan", wintypes.WORD),
        ("dwFlags", wintypes.DWORD),
        ("time", wintypes.DWORD),
        ("dwExtraInfo", ctypes.POINTER(ctypes.c_ulong)),
    ]


class MOUSEINPUT(ctypes.Structure):
    _fields_ = [
        ("dx", ctypes.c_long),
        ("dy", ctypes.c_long),
        ("mouseData", wintypes.DWORD),
        ("dwFlags", wintypes.DWORD),
        ("time", wintypes.DWORD),
        ("dwExtraInfo", ctypes.POINTER(ctypes.c_ulong)),
    ]


class HARDWAREINPUT(ctypes.Structure):
    _fields_ = [
        ("uMsg", wintypes.DWORD),
        ("wParamL", wintypes.WORD),
        ("wParamH", wintypes.WORD),
    ]


class _INPUTUNION(ctypes.Union):
    _fields_ = [
        ("ki", KEYBDINPUT),
        ("mi", MOUSEINPUT),
        ("hi", HARDWAREINPUT),
    ]


class INPUT(ctypes.Structure):
    _anonymous_ = ("u",)
    _fields_ = [
        ("type", wintypes.DWORD),
        ("u", _INPUTUNION),
    ]


user32 = ctypes.windll.user32

# 当前处于「按下」状态的键：vk -> 是否扩展键。用于去重与 release_all。
_pressed = {}


def _send(inputs):
    n = len(inputs)
    arr = (INPUT * n)(*inputs)
    return user32.SendInput(n, arr, ctypes.sizeof(INPUT))


def _key(vk, extended, up):
    flags = 0
    if extended:
        flags |= KEYEVENTF_EXTENDEDKEY
    if up:
        flags |= KEYEVENTF_KEYUP
    inp = INPUT()
    inp.type = INPUT_KEYBOARD
    inp.ki.wVk = vk
    inp.ki.dwFlags = flags
    return inp


def key_down(vk, extended=False):
    if vk not in _pressed:
        _send([_key(vk, extended, False)])
        _pressed[vk] = extended


def key_up(vk, extended=False):
    if vk in _pressed:
        ext = _pressed.pop(vk)
        _send([_key(vk, ext, True)])


def tap(vk, extended=False):
    key_down(vk, extended)
    key_up(vk, extended)


def release_all():
    """释放所有当前按下的键，避免断连后修饰键卡住。"""
    for vk in list(_pressed):
        key_up(vk, _pressed[vk])


def _unicode_char(unit, up):
    """构造一个 Unicode 字符注入事件（KEYEVENTF_UNICODE）。"""
    inp = INPUT()
    inp.type = INPUT_KEYBOARD
    inp.ki.wVk = 0
    inp.ki.wScan = unit
    inp.ki.dwFlags = KEYEVENTF_UNICODE | (KEYEVENTF_KEYUP if up else 0)
    return inp


def type_text(text):
    """把一段文字（含中文）逐字符注入到当前焦点处。

    用 KEYEVENTF_UNICODE 直接按键，绕过输入法，避免中文无法直接打出的问题。
    正确处理 UTF-16 代理对（emoji 等增补平面字符）。
    """
    units = []
    for ch in text:
        cp = ord(ch)
        if cp > 0xFFFF:
            cp -= 0x10000
            units.append(0xD800 + (cp >> 10))
            units.append(0xDC00 + (cp & 0x3FF))
        else:
            units.append(cp)
    for u in units:
        _send([_unicode_char(u, False)])
        _send([_unicode_char(u, True)])


# --- 鼠标 ---
_MOUSE_DOWN = {
    "left": MOUSEEVENTF_LEFTDOWN,
    "right": MOUSEEVENTF_RIGHTDOWN,
    "middle": MOUSEEVENTF_MIDDLEDOWN,
}
_MOUSE_UP = {
    "left": MOUSEEVENTF_LEFTUP,
    "right": MOUSEEVENTF_RIGHTUP,
    "middle": MOUSEEVENTF_MIDDLEUP,
}


def _mouse(dx, dy, flags, wheel=0):
    inp = INPUT()
    inp.type = INPUT_MOUSE
    inp.mi.dx = dx
    inp.mi.dy = dy
    inp.mi.mouseData = wheel
    inp.mi.dwFlags = flags
    _send([inp])


def mouse_move(dx, dy):
    _mouse(dx, dy, MOUSEEVENTF_MOVE)


def mouse_down(button="left"):
    _mouse(0, 0, _MOUSE_DOWN[button])


def mouse_up(button="left"):
    _mouse(0, 0, _MOUSE_UP[button])


def mouse_click(button="left"):
    mouse_down(button)
    mouse_up(button)


def mouse_scroll(dy):
    """滚轮，dy 为「格数」，正负方向由调用方决定。"""
    _mouse(0, 0, MOUSEEVENTF_WHEEL, wheel=dy * WHEEL_DELTA)
