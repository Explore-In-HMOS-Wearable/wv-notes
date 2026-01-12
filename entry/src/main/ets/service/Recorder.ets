import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Observed
export default class Recorder {
  private recorder: media.AVRecorder | undefined = undefined;
  private fileName: string = '';
  recorderState: media.AVRecorderState = 'idle';
  fileFd?: number;

  get readyToRecord(): boolean {
    return this.recorderState === 'idle' || this.recorderState === 'released';
  }

  get recording(): boolean {
    return this.recorderState === 'started';
  }

  async getDecibel(): Promise<number> {
    const amp = await this.recorder?.getAudioCapturerMaxAmplitude()!;
    const db = 20 * Math.log10(amp);
    return db;
  }

  async start(context: Context) {
    // initialize recorder
    try {
      this.recorder = await media.createAVRecorder();

      // Callback function for state changes.
      this.recorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        this.recorderState = state; // track state changes
      });

      // Callback function for errors.
      this.recorder.on('error', (err: BusinessError) => {
        console.error(`avRecorder failed, code is ${err.code}, message is ${err.message}`);
      });

      const avProfile: media.AVRecorderProfile = {
        audioBitrate: 100000, // Audio bit rate.
        audioChannels: 2, // Number of audio channels.
        audioCodec: media.CodecMimeType.AUDIO_AAC, // Audio encoding format.
        audioSampleRate: 48000, // Audio sampling rate.
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // Container format.
      };

      const filePath: string = context.filesDir + `/${Date.now()}.mp3`;
      this.fileName = filePath.split('/').pop() as string;
      const audioFile: fs.File = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      this.fileFd = audioFile.fd; // Obtain the file FD.

      const avConfig: media.AVRecorderConfig = {
        audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // Audio input source.
        profile: avProfile,
        url: `fd://${this.fileFd.toString()}`, // Obtain the file descriptor of the created audio file
      };

      await this.recorder.prepare(avConfig);
      await this.recorder.start();
    } catch (e) {
      console.error('start err:', e.code, e.message);
    } finally {
      fs.closeSync(this.fileFd);
    }
  }

  async stopAndSave() {
    try {
      await this.recorder?.stop();
      await this.recorder?.reset();
      await this.recorder?.release();
      this.recorder = undefined;

      return this.fileName;
    } catch (e) {
      console.error('stop err:', e.code, e.message);
      throw new Error(e.message);
    }
  }
}