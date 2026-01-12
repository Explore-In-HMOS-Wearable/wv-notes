import { fileIo as fs } from '@kit.CoreFileKit';

@Observed
export default class Records {
  fileNames: string[] = [];

  constructor(context: Context) {
    this.fileNames = this._getAll(context);
  }

  private _getAll(context: Context): string[] {
    try {
      const filesDir = context.filesDir;
      const files: string[] = fs.listFileSync(filesDir);
      files.sort((a, b) => a.localeCompare(b));
      return files;
    } catch (_) {
      console.error(_);
      return [];
    }
  }

  addNew(fileName: string) {
    const copy = Array.from(this.fileNames);
    copy.push(fileName);
    this.fileNames = copy;
  }
}