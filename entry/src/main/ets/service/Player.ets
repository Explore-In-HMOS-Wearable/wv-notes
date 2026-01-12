import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { fileIo as fs } from '@kit.CoreFileKit';

@Observed
export default class Player {
  private player: media.AVPlayer | undefined = undefined;
  playerState: string = 'idle';
  lastAmp: number = 0;
  fileFd?: number;

  get playing() {
    return this.playerState === 'playing';
  }

  getDecibel() {
    const db = 20 * Math.log10(this.lastAmp);
    return db;
  }

  private async init(filePath: string) {
    try {
      this.player = await media.createAVPlayer();

      this.player.on('amplitudeUpdate', (amps: number[]) => {
        this.lastAmp = amps.pop() ?? 0;
      });

      this.player.on('error', (e) => {
        console.error('player on error:', e.code, e.message);
      });

      this.player.on('stateChange', async (state: string) => {
        this.playerState = state;

        switch (state) {
          case 'idle':
            console.info('state: idle');
            break;
          case 'initialized':
            console.info('state: initialized');
            this.player!.audioRendererInfo = {
              usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
              rendererFlags: 0
            };
            this.player!.prepare();
            break;
          case 'prepared':
            console.info('state: prepared');
            this.player!.play();
            break;
          case 'playing':
            console.info('state: playing');
            break;
          case 'paused':
            console.info('state: paused');
            break;
          case 'completed':
            console.info('state: completed');
            break;
          case 'stopped':
            console.info('state: stopped');
            break;
          case 'released':
            console.info('state: released');
            this.player = undefined;
            break;
          default:
            console.info('state: should not happen', state);
            break;
        }
      });

      const file = await fs.open(filePath);
      this.fileFd = file.fd;
      const fdPath = `fd://${file.fd.toString()}`;
      this.player!.url = fdPath;

    } catch (e) {
      console.error(`init err: ${e}`);
    } finally {
      fs.closeSync(this.fileFd);
    }
  }

  async start(filePath: string) {
    try {
      console.info('start');
      if (!this.player) {
        console.info('init');
        await this.init(filePath);
      } else {
        console.info('start');
        await this.player.play();
      }
    } catch (e) {
      console.error('start err:', e);
    }
  }

  async pause() {
    this.player?.pause();
  }

  async stop() {
    if (this.playerState === 'prepared' || this.playerState === 'playing' || this.playerState === 'paused' ||
      this.playerState === 'completed') {
      await this.player?.stop();
      await this.player?.reset();
      await this.player?.release();
      this.player = undefined;
    }
  }
}