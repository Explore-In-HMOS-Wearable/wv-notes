import Player from '../service/Player'

@Builder
export default function PlayerBuilder(fileName: string) {
  PlayerPage({
    fileName: fileName
  })
}

@Component
struct PlayerPage {
  @Require fileName: string
  private filesDir = this.getUIContext().getHostContext()?.filesDir!
  @State player: Player = new Player()

  async aboutToDisappear() {
    await this.player.stop()
  }

  build() {
    Stack() {
      Button() {
        if (this.player.playing) {
          SymbolGlyph($r('sys.symbol.pause'))
            .fontColor([Color.White])
            .fontSize(18)
        } else {
          SymbolGlyph($r('sys.symbol.play_fill'))
            .fontColor([Color.White])
            .fontSize(18)
        }
      }
      .type(ButtonType.Circle)
      .backgroundColor(Color.Transparent)
      .size({ width: '50%', height: '50%' })
      .border({ color: Color.White, width: 5 })
      .onClick(async () => {
        if (!this.player.playing) {
          this.player.start(this.filesDir + '/' + this.fileName)
        } else {
          this.player.pause()
        }
      })
    }
    .size({ width: '100%', height: '100%' })
    .onAppear(() => {
      this.player.start(this.filesDir + '/' + this.fileName)
    })
  }
}