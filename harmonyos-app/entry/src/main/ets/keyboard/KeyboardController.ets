import { KeyDef } from './KeyDefs';
import { ConnectionService } from '../connection/ConnectionService';

interface MacroStep {
  key: string;
  down: boolean;
}

/**
 * 宏：名称 -> 按键序列。在平板端展开成 down/up 事件，
 * 蓝牙 HID 与有线 TCP 两条通道都能直接消费。
 */
const MACROS: Map<string, MacroStep[]> = new Map<string, MacroStep[]>([
  // 中英切换：微软拼音默认用 Shift 切换中英，发一次 Shift 点按。
  ['IME_TOGGLE', [
    { key: 'LSHIFT', down: true },
    { key: 'LSHIFT', down: false },
  ]],
  ['COPY', [
    { key: 'LCTRL', down: true },
    { key: 'C', down: true },
    { key: 'C', down: false },
    { key: 'LCTRL', down: false },
  ]],
  ['PASTE', [
    { key: 'LCTRL', down: true },
    { key: 'V', down: true },
    { key: 'V', down: false },
    { key: 'LCTRL', down: false },
  ]],
  ['CUT', [
    { key: 'LCTRL', down: true },
    { key: 'X', down: true },
    { key: 'X', down: false },
    { key: 'LCTRL', down: false },
  ]],
  ['SELECT_ALL', [
    { key: 'LCTRL', down: true },
    { key: 'A', down: true },
    { key: 'A', down: false },
    { key: 'LCTRL', down: false },
  ]],
  ['UNDO', [
    { key: 'LCTRL', down: true },
    { key: 'Z', down: true },
    { key: 'Z', down: false },
    { key: 'LCTRL', down: false },
  ]],
  ['SAVE', [
    { key: 'LCTRL', down: true },
    { key: 'S', down: true },
    { key: 'S', down: false },
    { key: 'LCTRL', down: false },
  ]],
  ['TASK_MANAGER', [
    { key: 'LCTRL', down: true },
    { key: 'LSHIFT', down: true },
    { key: 'ESC', down: true },
    { key: 'ESC', down: false },
    { key: 'LSHIFT', down: false },
    { key: 'LCTRL', down: false },
  ]],
]);

/**
 * 键盘控制器：按键按下/抬起、长按重复、宏展开，最终通过 ConnectionService 发送。
 * 修饰键为「按住生效」——按下发 down、松手发 up，不做锁存。
 */
export class KeyboardController {
  private service: ConnectionService;
  private pressed: Set<string> = new Set();

  private repeatTimer: number = -1;
  private repeatInterval: number = -1;
  private repeatKey: string = '';

  constructor(service: ConnectionService) {
    this.service = service;
  }

  keyDown(key: KeyDef): void {
    if (key.kind === 'macro') {
      this.runMacro(key.name);
      return;
    }
    this.pressed.add(key.name);
    this.service.send(key.name, true);
    if (key.kind === 'repeat') {
      this.startRepeat(key.name);
    }
  }

  keyUp(key: KeyDef): void {
    if (key.kind === 'macro') {
      return;
    }
    this.stopRepeat();
    this.pressed.delete(key.name);
    this.service.send(key.name, false);
  }

  runMacro(name: string): void {
    let seq = MACROS.get(name);
    if (seq === undefined) {
      return;
    }
    for (let i = 0; i < seq.length; i++) {
      this.service.send(seq[i].key, seq[i].down);
    }
  }

  startRepeat(name: string): void {
    this.stopRepeat();
    this.repeatKey = name;
    this.repeatTimer = setTimeout(() => {
      this.repeatInterval = setInterval(() => {
        this.service.send(this.repeatKey, true);
        this.service.send(this.repeatKey, false);
      }, 50);
    }, 500);
  }

  stopRepeat(): void {
    if (this.repeatTimer >= 0) {
      clearTimeout(this.repeatTimer);
      this.repeatTimer = -1;
    }
    if (this.repeatInterval >= 0) {
      clearInterval(this.repeatInterval);
      this.repeatInterval = -1;
    }
    this.repeatKey = '';
  }

  releaseAll(): void {
    this.stopRepeat();
    this.pressed.forEach((name: string) => {
      this.service.send(name, false);
    });
    this.pressed.clear();
  }

  sendText(text: string): void {
    this.service.sendText(text);
  }
}
