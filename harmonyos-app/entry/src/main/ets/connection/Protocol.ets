/**
 * 报文协议：把按键 / 宏 / 鼠标动作编码成换行分隔的 JSON 字符串。
 * 与电脑端 pc-receiver/receiver.py 的协议保持一致。
 */

export interface KeyPayload {
  t: string;
  e: string;
  k: string;
}

export interface MacroPayload {
  t: string;
  m: string;
}

export interface MousePayload {
  t: string;
  e: string;
  dx?: number;
  dy?: number;
  b?: string;
}

/** 每条报文之间的分隔符（接收端按 '\n' 分行）。 */
export const DELIMITER: string = '\n';

export function keyMsg(e: string, k: string): string {
  let p: KeyPayload = { t: 'k', e: e, k: k };
  return JSON.stringify(p);
}

export function keyDown(k: string): string {
  return keyMsg('down', k);
}

export function keyUp(k: string): string {
  return keyMsg('up', k);
}

export function keyTap(k: string): string {
  return keyMsg('tap', k);
}

export function macroMsg(m: string): string {
  let p: MacroPayload = { t: 'macro', m: m };
  return JSON.stringify(p);
}

export function mouseMoveMsg(dx: number, dy: number): string {
  let p: MousePayload = { t: 'm', e: 'move', dx: dx, dy: dy };
  return JSON.stringify(p);
}

export function mouseClickMsg(b: string): string {
  let p: MousePayload = { t: 'm', e: 'click', b: b };
  return JSON.stringify(p);
}

export function mouseDownMsg(b: string): string {
  let p: MousePayload = { t: 'm', e: 'down', b: b };
  return JSON.stringify(p);
}

export function mouseUpMsg(b: string): string {
  let p: MousePayload = { t: 'm', e: 'up', b: b };
  return JSON.stringify(p);
}

export function mouseScrollMsg(dy: number): string {
  let p: MousePayload = { t: 'm', e: 'scroll', dy: dy };
  return JSON.stringify(p);
}

export interface TextPayload {
  t: string;
  text: string;
}

/** 一段文字（语音输入结果），由电脑端按 Unicode 逐字注入。 */
export function textMsg(text: string): string {
  let p: TextPayload = { t: 'text', text: text };
  return JSON.stringify(p);
}
