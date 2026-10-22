"""键名 → Windows 虚拟键码(VK) 映射，以及「是否为扩展键」标记。

平板端只用这套固定键名发报文，Windows 端在这里映射成 VK，方便以后
换目标平台（如 Mac）只改这一层。
"""

KEYMAP = {}

# 字母 A-Z
for i in range(26):
    KEYMAP[chr(ord("A") + i)] = (0x41 + i, False)

# 数字 0-9（主键盘数字行）
for i in range(10):
    KEYMAP[str(i)] = (0x30 + i, False)

# 功能键 F1-F24
for i in range(1, 25):
    KEYMAP["F%d" % i] = (0x6F + i, False)

# 其余按键：(vk, 是否扩展键)
_EXPLICIT = {
    # 常用控制键
    "ESC": (0x1B, False),
    "TAB": (0x09, False),
    "CAPS": (0x14, False),
    "ENTER": (0x0D, False),
    "BACKSPACE": (0x08, False),
    "SPACE": (0x20, False),
    # 导航/编辑区（扩展键）
    "INSERT": (0x2D, True),
    "DELETE": (0x2E, True),
    "HOME": (0x24, True),
    "END": (0x23, True),
    "PAGEUP": (0x21, True),
    "PAGEDOWN": (0x22, True),
    "LEFT": (0x25, True),
    "RIGHT": (0x27, True),
    "UP": (0x26, True),
    "DOWN": (0x28, True),
    # 修饰键（左右区分）
    "LSHIFT": (0xA0, False),
    "RSHIFT": (0xA1, False),
    "LCTRL": (0xA2, False),
    "RCTRL": (0xA3, True),
    "LALT": (0xA4, False),
    "RALT": (0xA5, True),
    "LWIN": (0x5B, True),
    "RWIN": (0x5C, True),
    # 其他系统键
    "PRINTSCREEN": (0x2C, False),
    "SCROLLLOCK": (0x91, False),
    "PAUSE": (0x13, False),
    "NUMLOCK": (0x90, False),
    # 符号（US 键位，由 Windows 当前输入法解释成具体字符）
    "MINUS": (0xBD, False),      # -
    "EQUAL": (0xBB, False),      # =
    "LBRACKET": (0xDB, False),   # [
    "RBRACKET": (0xDD, False),   # ]
    "BACKSLASH": (0xDC, False),  # \
    "SEMICOLON": (0xBA, False),  # ;
    "QUOTE": (0xDE, False),      # '
    "COMMA": (0xBC, False),      # ,
    "PERIOD": (0xBE, False),     # .
    "SLASH": (0xBF, False),      # /
    "GRAVE": (0xC0, False),      # `
    # 媒体键
    "VOLUME_UP": (0xAF, False),
    "VOLUME_DOWN": (0xAE, False),
    "VOLUME_MUTE": (0xAD, False),
    "MEDIA_NEXT": (0xB0, False),
    "MEDIA_PREV": (0xB1, False),
    "MEDIA_STOP": (0xB2, False),
    "MEDIA_PLAY_PAUSE": (0xB3, False),
}

KEYMAP.update(_EXPLICIT)


def lookup(name):
    """返回 (vk, extended)；未知键返回 None。"""
    if not name:
        return None
    return KEYMAP.get(name.upper())
