@Observed
export default class CircularWaveVM {
  context: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private waveData: number[] = [];
  // constants
  private canvasWidth = 0;
  private canvasHeight = 0;
  private maxNumPoints = 0;
  // You can modify these values for your case
  private minValue = 1; // used if the waveData is 0
  private maxValue = 100; // used to normalize waveData
  private radius = 0; // radius of the circle
  private numPoints = 180; // number of points on the circular wave

  start() {
    // set color
    this.context.strokeStyle = '#FFFF33';
    // set constants
    this.canvasWidth = this.context.width;
    this.canvasHeight = this.context.height;
    this.maxNumPoints = this.numPoints;
    this.radius = this.canvasWidth / 4
  }

  clear() {
    this.waveData = [];
    this.draw();
  }

  addData(num: number) {
    if (this.waveData.length === this.maxNumPoints) {
      this.waveData.shift();
    }
    this.waveData.push(num);

    this.draw();
  }

  draw() {
    // first clear
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    const centerX = this.canvasWidth / 2;
    const centerY = this.canvasHeight / 2;

    for (let i = 0; i < this.waveData.length; i++) {
      const angle = (i / this.maxNumPoints) * (2 * Math.PI);
      const radiusVariation = this.normalize(this.waveData[i]);
      const x = centerX + Math.cos(angle) * (this.radius + radiusVariation);
      const y = centerY + Math.sin(angle) * (this.radius + radiusVariation);

      // Draw wave bar
      this.context.beginPath();
      this.context.moveTo(centerX + Math.cos(angle) * this.radius, centerY + Math.sin(angle) * this.radius);
      this.context.lineTo(x, y);
      this.context.lineWidth = 2; // Width of the wave bars
      this.context.stroke();
    }
  }

  normalize(val: number): number {
    if (val === 0) {
      return this.minValue;
    }
    if (val >= this.maxValue) {
      return this.radius; // maximum distance from center
    }

    return (this.radius / this.maxValue) * val;
  }
}