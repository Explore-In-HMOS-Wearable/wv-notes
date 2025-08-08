import Records from '../service/Records';
import {
  ArcList,
  ArcListItem,
  ArcListAttribute,
  ArcListItemAttribute,
  ComponentContent,
  LengthMetrics
} from '@kit.ArkUI';
import PlayerBuilder from './PlayerPage';

@Builder
function titleBuilder() {
  Text('My Notes').fontSize(24)
}

@Component
export default struct Notes {
  @ObjectLink records: Records
  @State openSheet: boolean = false
  selectedRecord: string = ''

  build() {
    Stack() {
      ArcList({
        header: new ComponentContent(this.getUIContext(), wrapBuilder(titleBuilder))
      }) {
        ForEach(this.records.fileNames, (path: string, index: number) => {
          ArcListItem() {
            Button() {
              Row() {
                Text(new Date(Number.parseInt(path.split('.')[0])).toLocaleString())
                Blank().layoutWeight(1)
                SymbolGlyph($r('sys.symbol.arrow_right'))
              }.padding({ left: 16, right: 16 })
            }
            .width('100%')
            .height(40)
            .backgroundColor(Color.White)
            .foregroundColor(Color.Black)
            .onClick(async () => {
              // TODO: implement listen functionality
              this.selectedRecord = path
              this.openSheet = true
            })
          }.width('calc(100% - 32vp)')
        }, (path: string) => path)
      }.space(LengthMetrics.vp(8))
    }
    .bindSheet($$this.openSheet, PlayerBuilder(this.selectedRecord), {
      height: SheetSize.MEDIUM,
      backgroundColor: Color.Black,
    })
  }
}