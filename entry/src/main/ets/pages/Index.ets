import RecorderPage from '../components/RecorderPage';
import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Recorder from '../service/Recorder';
import Notes from '../components/Notes';
import Records from '../service/Records';

@Entry
@Component
struct Index {
  @State recorder: Recorder = new Recorder() // create the recorder object
  @State records: Records = new Records(this.getUIContext().getHostContext()!)

  onDidBuild(): void {
    this.requestMicPermission()
  }

  build() {
    Swiper() {
      RecorderPage({ recorder: this.recorder, records: this.records })
      Notes({ records: this.records })
    }
    .height('100%')
    .width('100%')
  }

  async requestMicPermission() {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const context = this.getUIContext().getHostContext()
    const permissions: Permissions[] = ['ohos.permission.MICROPHONE'];

    try {
      // request permission from user
      let granted =
        (await (atManager.requestPermissionsFromUser(context,
          permissions) as Promise<PermissionRequestResult>)).authResults[0] == 0
      while (!granted) {
        // request permission on settings
        granted = (await atManager.requestPermissionOnSetting(context, permissions))[0] ==
        abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
  }
}