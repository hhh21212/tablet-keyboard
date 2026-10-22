import { KeyDef, MAIN_ROWS } from '../keyboard/KeyDefs';
import { ConnectionService, ConnState } from '../connection/ConnectionService';
import { KeyboardController } from '../keyboard/KeyboardController';
import { KeyButton } from '../keyboard/KeyButton';
import { Palette, ThemeKey, AccentKey, KeySize, resolvePalette } from '../theme/Theme';
import { preferences } from '@kit.ArkData';

@Entry
@Component
struct Index {
  private service: ConnectionService = new ConnectionService();
  private controller: KeyboardController | null = null;
  @State connState: ConnState = 'idle';
  @State theme: ThemeKey = 'daqing';
  @State accent: AccentKey = 'gold';
  @State keySize: KeySize = 'medium';
  @State showSettings: boolean = false;

  aboutToAppear(): void {
    this.controller = new KeyboardController(this.service);
    this.service.onStateChange = (s: ConnState) => {
      this.connState = s;
    };
    this.service.start();
    this.loadSettings();
  }

  aboutToDisappear(): void {
    if (this.controller !== null) {
      this.controller.releaseAll();
    }
    this.service.stop();
  }

  private palette(): Palette {
    return resolvePalette(this.theme, this.accent);
  }

  private keyHeight(): number {
    if (this.keySize === 'small') {
      return 44;
    }
    if (this.keySize === 'large') {
      return 58;
    }
    return 50;
  }

  private keyFont(): number {
    if (this.keySize === 'small') {
      return 12;
    }
    if (this.keySize === 'large') {
      return 15;
    }
    return 13;
  }

  private keyLine(): number {
    if (this.keySize === 'small') {
      return 14;
    }
    if (this.keySize === 'large') {
      return 18;
    }
    return 16;
  }

  async loadSettings(): Promise<void> {
    let prefs = await preferences.getPreferences(getContext(this), 'kbd_settings');
    let t = await prefs.get('theme', 'daqing') as string;
    let a = await prefs.get('accent', 'gold') as string;
    let s = await prefs.get('keySize', 'medium') as string;
    this.theme = t as ThemeKey;
    this.accent = a as AccentKey;
    this.keySize = s as KeySize;
  }

  async saveSettings(): Promise<void> {
    let prefs = await preferences.getPreferences(getContext(this), 'kbd_settings');
    await prefs.put('theme', this.theme);
    await prefs.put('accent', this.accent);
    await prefs.put('keySize', this.keySize);
    await prefs.flush();
  }

  private setTheme(t: ThemeKey): void {
    this.theme = t;
    this.saveSettings();
  }

  private setAccent(a: AccentKey): void {
    this.accent = a;
    this.saveSettings();
  }

  private setKeySize(s: KeySize): void {
    this.keySize = s;
    this.saveSettings();
  }

  build() {
    Column() {
      // 顶栏：描金标题 + 状态灯 + 设置
      Row() {
        Text('平板键盘')
          .fontFamily('Kaiti SC')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().titleText)
          .textShadow({ radius: 10, color: this.palette().titleGlow, offsetX: 0, offsetY: 0 })
          .letterSpacing(4)
        Row() {
          Column()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(this.connState === 'connected' ? this.palette().connOn : this.palette().connOff)
            .margin({ right: 5 })
          Text(this.statusText())
            .fontSize(12)
            .fontColor(this.palette().statusText)
        }
        .margin({ left: 14 })
        Blank()
        Button('设置')
          .fontSize(14)
          .height(30)
          .fontColor(this.palette().accentText)
          .backgroundColor(this.palette().accent)
          .borderRadius(8)
          .onClick(() => {
            this.showSettings = true;
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })

      // 键盘区域
      Column() {
        ForEach(MAIN_ROWS, (row: KeyDef[]) => {
          Row() {
            ForEach(row, (key: KeyDef) => {
              KeyButton({
                keyDef: key,
                palette: this.palette(),
                keyHeight: this.keyHeight(),
                fontSize: this.keyFont(),
                lineHeight: this.keyLine(),
                onDown: (k: KeyDef) => {
                  this.handleKeyDown(k);
                },
                onUp: (k: KeyDef) => {
                  this.handleKeyUp(k);
                },
              })
            }, (key: KeyDef) => key.name)
          }
          .width('100%')
        }, (row: KeyDef[]) => row[0].name)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [
        [this.palette().bgTop, 0.0],
        [this.palette().bgMid, 0.42],
        [this.palette().bgBottom, 1.0],
      ],
    })
    .bindSheet($$this.showSettings, this.settingsSheet(), { height: 400 })
  }

  // 设置面板：配色主题 / 强调色 / 键帽大小
  @Builder
  settingsSheet() {
    Column() {
      Text('外观设置')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.palette().keyText)
        .margin({ top: 20, bottom: 16 })

      Text('配色主题')
        .fontSize(13)
        .fontColor(this.palette().statusText)
        .margin({ bottom: 10 })
      Row({ space: 14 }) {
        this.themeSwatch('daqing', '黛青描金', '#0d1b2a')
        this.themeSwatch('zhuhong', '朱红描金', '#8c1a1a')
        this.themeSwatch('xuanzhi', '宣纸素笺', '#f2ecd9')
      }

      Text('强调色')
        .fontSize(13)
        .fontColor(this.palette().statusText)
        .margin({ top: 18, bottom: 10 })
      Row({ space: 14 }) {
        this.accentSwatch('gold', '#c9a96a')
        this.accentSwatch('jade', '#7fb0a8')
        this.accentSwatch('mist', '#a89bd4')
        this.accentSwatch('cinnabar', '#d98a6b')
      }

      Text('键帽大小')
        .fontSize(13)
        .fontColor(this.palette().statusText)
        .margin({ top: 18, bottom: 10 })
      Row({ space: 14 }) {
        this.sizeChip('small', '小')
        this.sizeChip('medium', '中')
        this.sizeChip('large', '大')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 22, right: 22 })
    .linearGradient({
      angle: 180,
      colors: [
        [this.palette().bgTop, 0.0],
        [this.palette().bgBottom, 1.0],
      ],
    })
  }

  @Builder
  themeSwatch(key: ThemeKey, label: string, preview: string) {
    Column({ space: 6 }) {
      Column()
        .width(80)
        .height(46)
        .borderRadius(8)
        .backgroundColor(preview)
        .border({
          width: this.theme === key ? 2 : 1,
          color: this.theme === key ? this.palette().accentBright : this.palette().keyBorder,
        })
      Text(label)
        .fontSize(12)
        .fontColor(this.theme === key ? this.palette().accentBright : this.palette().keyText)
    }
    .onClick(() => {
      this.setTheme(key);
    })
  }

  @Builder
  accentSwatch(key: AccentKey, color: string) {
    Column()
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor(color)
      .border({
        width: this.accent === key ? 3 : 1,
        color: this.accent === key ? this.palette().accentBright : this.palette().keyBorder,
      })
      .onClick(() => {
        this.setAccent(key);
      })
  }

  @Builder
  sizeChip(key: KeySize, label: string) {
    Text(label)
      .fontSize(14)
      .width(64)
      .height(34)
      .textAlign(TextAlign.Center)
      .fontColor(this.keySize === key ? this.palette().accentText : this.palette().keyText)
      .backgroundColor(this.keySize === key ? this.palette().accent : Color.Transparent)
      .borderRadius(8)
      .border({
        width: 1,
        color: this.keySize === key ? this.palette().accent : this.palette().keyBorder,
      })
      .onClick(() => {
        this.setKeySize(key);
      })
  }

  handleKeyDown(key: KeyDef): void {
    if (this.controller !== null) {
      this.controller.keyDown(key);
    }
  }

  handleKeyUp(key: KeyDef): void {
    if (this.controller !== null) {
      this.controller.keyUp(key);
    }
  }

  statusText(): string {
    if (this.connState === 'connected') {
      return '已连接';
    }
    if (this.connState === 'listening') {
      return '监听中 (5959)';
    }
    if (this.connState === 'error') {
      return '启动失败';
    }
    return '未启动';
  }
}
