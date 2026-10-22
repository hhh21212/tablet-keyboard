/**
 * 键盘键位定义：键名（发往电脑的报文键名） + 键帽显示文字 + 宽度 + 类型。
 *
 * 键名必须与 pc-receiver/keymap.py 的 lookup() 支持的名字一致。
 * 后续的 F 键层、数字小键盘层、符号层在 M3 再补充进这里。
 */

export type KeyKind = 'normal' | 'modifier' | 'repeat' | 'macro';

export interface KeyDef {
  /** 报文键名，如 'A'、'ENTER'、'LCTRL'、'IME_TOGGLE'（宏名）。 */
  name: string;
  /** 键帽显示文字；含上档符号时用 '\n' 分隔（上档在上、本键在下）。 */
  label: string;
  /** 相对宽度，1.0 为标准键宽。 */
  width: number;
  kind: KeyKind;
}

/** 主键盘布局（QWERTY）。 */
export const MAIN_ROWS: KeyDef[][] = [
  // 数字行 + Esc + 退格
  [
    { name: 'ESC', label: 'Esc', width: 1, kind: 'normal' },
    { name: 'GRAVE', label: '~\n`', width: 1, kind: 'normal' },
    { name: '1', label: '!\n1', width: 1, kind: 'normal' },
    { name: '2', label: '@\n2', width: 1, kind: 'normal' },
    { name: '3', label: '#\n3', width: 1, kind: 'normal' },
    { name: '4', label: '$\n4', width: 1, kind: 'normal' },
    { name: '5', label: '%\n5', width: 1, kind: 'normal' },
    { name: '6', label: '^\n6', width: 1, kind: 'normal' },
    { name: '7', label: '&\n7', width: 1, kind: 'normal' },
    { name: '8', label: '*\n8', width: 1, kind: 'normal' },
    { name: '9', label: '(\n9', width: 1, kind: 'normal' },
    { name: '0', label: ')\n0', width: 1, kind: 'normal' },
    { name: 'MINUS', label: '_\n-', width: 1, kind: 'normal' },
    { name: 'EQUAL', label: '+\n=', width: 1, kind: 'normal' },
    { name: 'BACKSPACE', label: 'Bksp', width: 2, kind: 'repeat' },
  ],
  // 字母第一行
  [
    { name: 'TAB', label: 'Tab', width: 1.5, kind: 'normal' },
    { name: 'Q', label: 'Q', width: 1, kind: 'normal' },
    { name: 'W', label: 'W', width: 1, kind: 'normal' },
    { name: 'E', label: 'E', width: 1, kind: 'normal' },
    { name: 'R', label: 'R', width: 1, kind: 'normal' },
    { name: 'T', label: 'T', width: 1, kind: 'normal' },
    { name: 'Y', label: 'Y', width: 1, kind: 'normal' },
    { name: 'U', label: 'U', width: 1, kind: 'normal' },
    { name: 'I', label: 'I', width: 1, kind: 'normal' },
    { name: 'O', label: 'O', width: 1, kind: 'normal' },
    { name: 'P', label: 'P', width: 1, kind: 'normal' },
    { name: 'LBRACKET', label: '{\n[', width: 1, kind: 'normal' },
    { name: 'RBRACKET', label: '}\n]', width: 1, kind: 'normal' },
    { name: 'BACKSLASH', label: '|\n\\', width: 1, kind: 'normal' },
  ],
  // 字母第二行
  [
    { name: 'CAPS', label: 'Caps', width: 1.75, kind: 'normal' },
    { name: 'A', label: 'A', width: 1, kind: 'normal' },
    { name: 'S', label: 'S', width: 1, kind: 'normal' },
    { name: 'D', label: 'D', width: 1, kind: 'normal' },
    { name: 'F', label: 'F', width: 1, kind: 'normal' },
    { name: 'G', label: 'G', width: 1, kind: 'normal' },
    { name: 'H', label: 'H', width: 1, kind: 'normal' },
    { name: 'J', label: 'J', width: 1, kind: 'normal' },
    { name: 'K', label: 'K', width: 1, kind: 'normal' },
    { name: 'L', label: 'L', width: 1, kind: 'normal' },
    { name: 'SEMICOLON', label: ':\n;', width: 1, kind: 'normal' },
    { name: 'QUOTE', label: '"\n\'', width: 1, kind: 'normal' },
    { name: 'ENTER', label: 'Enter', width: 2.25, kind: 'normal' },
  ],
  // 字母第三行
  [
    { name: 'LSHIFT', label: 'Shift', width: 2.25, kind: 'modifier' },
    { name: 'Z', label: 'Z', width: 1, kind: 'normal' },
    { name: 'X', label: 'X', width: 1, kind: 'normal' },
    { name: 'C', label: 'C', width: 1, kind: 'normal' },
    { name: 'V', label: 'V', width: 1, kind: 'normal' },
    { name: 'B', label: 'B', width: 1, kind: 'normal' },
    { name: 'N', label: 'N', width: 1, kind: 'normal' },
    { name: 'M', label: 'M', width: 1, kind: 'normal' },
    { name: 'COMMA', label: '<\n,', width: 1, kind: 'normal' },
    { name: 'PERIOD', label: '>\n.', width: 1, kind: 'normal' },
    { name: 'SLASH', label: '?\n/', width: 1, kind: 'normal' },
    { name: 'RSHIFT', label: 'Shift', width: 2.75, kind: 'modifier' },
  ],
  // 底部修饰键 + 空格 + 中英切换
  [
    { name: 'LCTRL', label: 'Ctrl', width: 1.5, kind: 'modifier' },
    { name: 'LWIN', label: 'Win', width: 1.5, kind: 'modifier' },
    { name: 'LALT', label: 'Alt', width: 1.5, kind: 'modifier' },
    { name: 'SPACE', label: 'Space', width: 5, kind: 'repeat' },
    { name: 'IME_TOGGLE', label: '中/英', width: 1.5, kind: 'macro' },
    { name: 'RALT', label: 'Alt', width: 1.5, kind: 'modifier' },
    { name: 'RWIN', label: 'Win', width: 1.5, kind: 'modifier' },
    { name: 'RCTRL', label: 'Ctrl', width: 1.5, kind: 'modifier' },
  ],
];
