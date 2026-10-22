/**
 * 主题系统：中式描金 + 玻璃拟态配色。
 * 配色值提炼自用户桌面项目（人际网 / 奇门遁甲 / 三清观求签）。
 */

export type ThemeKey = 'daqing' | 'zhuhong' | 'xuanzhi';
export type AccentKey = 'gold' | 'jade' | 'mist' | 'cinnabar';
export type KeySize = 'small' | 'medium' | 'large';

export interface Palette {
  bgTop: string;
  bgMid: string;
  bgBottom: string;
  titleText: string;
  titleGlow: string;
  statusText: string;
  connOn: string;
  connOff: string;
  keyTop: string;
  keyBottom: string;
  keyText: string;
  keyBorder: string;
  keyPressedTop: string;
  keyPressedBottom: string;
  modTop: string;
  modBottom: string;
  accent: string;
  accentBright: string;
  accentText: string;
  shadow: string;
}

interface ThemeBase {
  bgTop: string;
  bgMid: string;
  bgBottom: string;
  titleText: string;
  titleGlow: string;
  statusText: string;
  connOn: string;
  connOff: string;
  keyTop: string;
  keyBottom: string;
  keyText: string;
  keyBorder: string;
  keyPressedTop: string;
  keyPressedBottom: string;
  modTop: string;
  modBottom: string;
  shadow: string;
}

interface AccentSpec {
  accent: string;
  bright: string;
}

function themeBase(key: ThemeKey): ThemeBase {
  if (key === 'zhuhong') {
    return {
      bgTop: '#6b1212', bgMid: '#8c1a1a', bgBottom: '#3d0808',
      titleText: '#e8cd74', titleGlow: 'rgba(232,205,116,0.5)',
      statusText: '#e8d9c0',
      connOn: '#3f8f72', connOff: '#d8574a',
      keyTop: 'rgba(58,26,10,0.62)', keyBottom: 'rgba(24,10,4,0.74)',
      keyText: '#f6ecd2', keyBorder: 'rgba(201,162,39,0.2)',
      keyPressedTop: 'rgba(74,32,16,0.82)', keyPressedBottom: 'rgba(32,13,6,0.85)',
      modTop: 'rgba(74,32,16,0.7)', modBottom: 'rgba(42,17,8,0.8)',
      shadow: 'rgba(0,0,0,0.5)',
    };
  }
  if (key === 'xuanzhi') {
    return {
      bgTop: '#f6f0e0', bgMid: '#f2ecd9', bgBottom: '#ece4cd',
      titleText: '#a97e32', titleGlow: 'rgba(169,126,50,0.35)',
      statusText: '#5a4a30',
      connOn: '#3f8f72', connOff: '#b03a2e',
      keyTop: '#fbf3df', keyBottom: '#f3e6c8',
      keyText: '#3a2a12', keyBorder: 'rgba(169,126,50,0.35)',
      keyPressedTop: '#e6d9b8', keyPressedBottom: '#ded0ac',
      modTop: '#efe6cd', modBottom: '#e8dcc0',
      shadow: 'rgba(90,70,40,0.25)',
    };
  }
  return {
    bgTop: '#08111c', bgMid: '#0d1b2a', bgBottom: '#0a1624',
    titleText: '#f0d9a8', titleGlow: 'rgba(224,197,143,0.4)',
    statusText: '#9fb0c0',
    connOn: '#7fb0a8', connOff: '#d98b8b',
    keyTop: 'rgba(30,52,80,0.5)', keyBottom: 'rgba(13,27,42,0.62)',
    keyText: '#e8e0d0', keyBorder: 'rgba(201,169,106,0.16)',
    keyPressedTop: 'rgba(22,43,63,0.82)', keyPressedBottom: 'rgba(10,20,33,0.85)',
    modTop: 'rgba(42,66,88,0.6)', modBottom: 'rgba(18,36,63,0.72)',
    shadow: 'rgba(0,0,0,0.35)',
  };
}

function accentSpec(key: AccentKey): AccentSpec {
  if (key === 'jade') {
    return { accent: '#7fb0a8', bright: '#a8d8d0' };
  }
  if (key === 'mist') {
    return { accent: '#a89bd4', bright: '#cbc0ec' };
  }
  if (key === 'cinnabar') {
    return { accent: '#d98a6b', bright: '#e8b09a' };
  }
  return { accent: '#c9a96a', bright: '#f0d9a8' };
}

/** 取主题基础色 + 强调色，返回完整调色板。 */
export function resolvePalette(theme: ThemeKey, accentKey: AccentKey): Palette {
  let base = themeBase(theme);
  let acc = accentSpec(accentKey);
  if (accentKey === 'gold' && theme === 'zhuhong') {
    acc = { accent: '#c9a227', bright: '#e8cd74' };
  } else if (accentKey === 'gold' && theme === 'xuanzhi') {
    acc = { accent: '#a97e32', bright: '#c9a227' };
  }
  let p: Palette = {
    bgTop: base.bgTop,
    bgMid: base.bgMid,
    bgBottom: base.bgBottom,
    titleText: base.titleText,
    titleGlow: base.titleGlow,
    statusText: base.statusText,
    connOn: base.connOn,
    connOff: base.connOff,
    keyTop: base.keyTop,
    keyBottom: base.keyBottom,
    keyText: base.keyText,
    keyBorder: base.keyBorder,
    keyPressedTop: base.keyPressedTop,
    keyPressedBottom: base.keyPressedBottom,
    modTop: base.modTop,
    modBottom: base.modBottom,
    accent: acc.accent,
    accentBright: acc.bright,
    accentText: '#0b1020',
    shadow: base.shadow,
  };
  return p;
}
