import { KeyDef } from './KeyDefs';
import { Palette } from '../theme/Theme';

/**
 * 单键组件：琉璃键帽 + 按下金色发光反馈。
 * 每键独立 @State pressed，多点触控时组合键（如 Shift+A）各自独立高亮。
 */
@Component
export struct KeyButton {
  @Prop keyDef: KeyDef;
  @Prop palette: Palette;
  @Prop keyHeight: number;
  @Prop fontSize: number;
  @Prop lineHeight: number;
  onDown: (k: KeyDef) => void = () => {
  };
  onUp: (k: KeyDef) => void = () => {
  };
  @State pressed: boolean = false;

  private isMacro(): boolean {
    return this.keyDef.kind === 'macro';
  }

  private isModifier(): boolean {
    return this.keyDef.kind === 'modifier';
  }

  private topColor(): string {
    if (this.isMacro()) {
      return this.pressed ? this.palette.accentBright : this.palette.accent;
    }
    if (this.isModifier()) {
      return this.pressed ? this.palette.accent : this.palette.modTop;
    }
    return this.pressed ? this.palette.keyPressedTop : this.palette.keyTop;
  }

  private bottomColor(): string {
    if (this.isMacro()) {
      return this.pressed ? this.palette.accentBright : this.palette.accent;
    }
    if (this.isModifier()) {
      return this.pressed ? this.palette.accent : this.palette.modBottom;
    }
    return this.pressed ? this.palette.keyPressedBottom : this.palette.keyBottom;
  }

  private curBorder(): string {
    if (this.pressed || this.isMacro()) {
      return this.palette.accentBright;
    }
    return this.palette.keyBorder;
  }

  private textColor(): string {
    if (this.isMacro()) {
      return this.palette.accentText;
    }
    if (this.isModifier() && this.pressed) {
      return this.palette.accentText;
    }
    return this.palette.keyText;
  }

  build() {
    Text(this.keyDef.label)
      .layoutWeight(this.keyDef.width)
      .height(this.keyHeight)
      .margin(2)
      .textAlign(TextAlign.Center)
      .fontSize(this.fontSize)
      .lineHeight(this.lineHeight)
      .fontColor(this.textColor())
      .linearGradient({
        angle: 180,
        colors: [[this.topColor(), 0.0], [this.bottomColor(), 1.0]],
      })
      .border({ width: 1, color: this.curBorder() })
      .borderRadius(9)
      .shadow(this.pressed
        ? { radius: 10, color: this.palette.accent, offsetX: 0, offsetY: 0 }
        : { radius: 4, color: this.palette.shadow, offsetX: 0, offsetY: 2 })
      .scale({ x: this.pressed ? 0.94 : 1, y: this.pressed ? 0.94 : 1 })
      .animation({ duration: 90 })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.pressed = true;
          this.onDown(this.keyDef);
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.pressed = false;
          this.onUp(this.keyDef);
        }
      })
  }
}
