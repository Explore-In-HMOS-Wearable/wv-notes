import CircularWaveVM from '../viewmodel/CircularWaveVM';

@Component
export struct CircularWaveAnimation {
  @ObjectLink waveVm: CircularWaveVM;

  build() {
    Stack() {
      Canvas(this.waveVm.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.waveVm.start()
        })
    }.size({ width: '100%', height: '100%' })
  }
}