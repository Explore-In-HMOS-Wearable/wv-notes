import Recorder from '../service/Recorder';
import Records from '../service/Records';
import CircularWaveVM from '../viewmodel/CircularWaveVM';
import { CircularWaveAnimation } from './CircularWaveAnimation';

@Component
export default struct RecorderPage {
  @ObjectLink recorder: Recorder; // get recorder from parent
  @ObjectLink records: Records;
  @State waveWm: CircularWaveVM = new CircularWaveVM()
  private intervalId: number | undefined = undefined

  build() {
    Stack() {
      CircularWaveAnimation({
        waveVm: this.waveWm
      })

      Button() {
        Stack() {
          if (this.recorder.recording) {
            Rect({ width: '35%', height: '35%' })
              .fill(Color.Red)
          } else {
            Circle({ width: '90%', height: '90%' })
              .fill(Color.Red)
              .transition(
                TransitionEffect.asymmetric(
                  TransitionEffect.scale({ x: 0.5, y: 0.5 }).animation({ duration: 200 }),
                  TransitionEffect.scale({ x: 0.35, y: 0.35 }).animation({ duration: 200 }),
                )
              )
          }
        }
        .size({ width: '100%', height: '100%' })
        .align(Alignment.Center)
      }
      .type(ButtonType.Circle)
      .backgroundColor(Color.Transparent)
      .size({ width: '50%', height: '50%' })
      .border({ color: Color.White, width: 5 })
      .onClick(async () => {
        if (this.recorder.readyToRecord) { // start the recording
          await this.recorder.start(this.getUIContext().getHostContext()!)
          this.intervalId = setInterval(async () => {
            const db = await this.recorder.getDecibel()
            this.waveWm.addData(db)
          }, 50)
        } else if (this.recorder.recording) { // stop and save
          clearInterval(this.intervalId)
          this.waveWm.clear()
          const path = await this.recorder.stopAndSave()
          this.records.addNew(path)
        }
      })
    }
  }
}