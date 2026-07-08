import { ChartDataPoint } from '../viewmodel/GrowthRecordViewModel'
import { drawing, common2D } from '@kit.ArkGraphics2D'

/** 解析十六进制颜色为 common2D.Color */
function parseColor(hex: string): common2D.Color {
  const r = parseInt(hex.substring(1, 3), 16)
  const g = parseInt(hex.substring(3, 5), 16)
  const b = parseInt(hex.substring(5, 7), 16)
  const color: common2D.Color = { alpha: 255, red: r, green: g, blue: b }
  return color
}

/**
 * 成长趋势图表组件
 * 使用 Canvas + Drawing API 自绘制，展示体重/身高曲线
 */
@Component
export struct GrowthChart {
  @Prop chartData: ChartDataPoint[] = []
  @Prop chartTitle: string = '成长趋势'
  @Prop lineColor: string = '#FF6F00'
  @Prop unit: string = 'kg'
  @Prop chartHeight: number = 200

  @State private canvasWidth: number = 360

  build() {
    Column() {
      // 标题
      Text(this.chartTitle)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#424242')
        .margin({ bottom: 12 })
        .width('100%')

      if (this.chartData.length === 0) {
        Column() {
          Text('📊')
            .fontSize(48)
            .opacity(0.4)
          Text('暂无数据')
            .fontSize(14)
            .fontColor('#BDBDBD')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(this.chartHeight)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
      } else {
        Column() {
          Canvas()
            .width('100%')
            .height(this.chartHeight)
            .onReady((ctx: DrawingRenderingContext) => {
              this.renderChart(ctx.canvas)
            })
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.canvasWidth = newValue.width as number
            })
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 4, right: 4 })
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
      }
    }
  }

  private renderChart(canvas: drawing.Canvas): void {
    const data = this.chartData
    if (data.length === 0) return

    const w = this.canvasWidth
    const h = this.chartHeight
    const padTop = 20
    const padRight = 16
    const padBottom = 40
    const padLeft = 40
    const chartW = w - padLeft - padRight
    const chartH = h - padTop - padBottom

    // 找到最大值和最小值
    const values: number[] = []
    for (let i = 0; i < data.length; i++) {
      values[i] = data[i].value
    }
    let minVal = values[0]
    let maxVal = values[0]
    for (let i = 1; i < values.length; i++) {
      if (values[i] < minVal) minVal = values[i]
      if (values[i] > maxVal) maxVal = values[i]
    }
    const range = maxVal - minVal || 1
    const yMin = minVal - range * 0.1
    const yMax = maxVal + range * 0.1

    // 比例尺
    const scaleX = (index: number): number => padLeft + (index / Math.max(data.length - 1, 1)) * chartW
    const scaleY = (val: number): number => padTop + chartH - ((val - yMin) / (yMax - yMin)) * chartH

    // 颜色
    const gridColor = parseColor('#E0E0E0')
    const textColor = parseColor('#9E9E9E')
    const lineColorVal = parseColor(this.lineColor)
    const whiteColor = parseColor('#FFFFFF')
    const darkTextColor = parseColor('#212121')

    // 绘制背景网格线
    const gridLines = 4
    const gridPen = new drawing.Pen()
    gridPen.setColor(gridColor)
    gridPen.setStrokeWidth(0.5)
    gridPen.setAntiAlias(true)

    for (let i = 0; i <= gridLines; i++) {
      const y = padTop + (chartH / gridLines) * i
      const gridPath = new drawing.Path()
      gridPath.moveTo(padLeft, y)
      gridPath.lineTo(w - padRight, y)
      canvas.attachPen(gridPen)
      canvas.drawPath(gridPath)
      canvas.detachPen()

      // Y轴标签
      const val = yMax - ((yMax - yMin) / gridLines) * i
      this.drawText(canvas, val.toFixed(1) + this.unit, padLeft - 4, y + 4, 10, textColor, 'right')
    }

    // 绘制X轴标签
    const labelStep = Math.max(1, Math.floor(data.length / 6))
    for (let i = 0; i < data.length; i += labelStep) {
      const x = scaleX(i)
      this.drawText(canvas, data[i].label, x, h - padBottom + 16, 9, textColor, 'center')
    }
    // 最后一个标签
    if (data.length > 1 && (data.length - 1) % labelStep !== 0) {
      const lastX = scaleX(data.length - 1)
      this.drawText(canvas, data[data.length - 1].label, lastX, h - padBottom + 16, 9, textColor, 'center')
    }

    // 绘制数据点和连线
    if (data.length === 1) {
      const x = scaleX(0)
      const y = scaleY(data[0].value)

      // 单个点
      const dotBrush = new drawing.Brush()
      dotBrush.setColor(lineColorVal)
      dotBrush.setAntiAlias(true)
      canvas.attachBrush(dotBrush)
      canvas.drawCircle(x, y, 6)
      canvas.detachBrush()

      this.drawText(canvas, data[0].value.toFixed(1) + this.unit, x, y - 14, 11, darkTextColor, 'center')
    } else {
      // 绘制连线
      const linePath = new drawing.Path()
      linePath.moveTo(scaleX(0), scaleY(data[0].value))
      for (let i = 1; i < data.length; i++) {
        linePath.lineTo(scaleX(i), scaleY(data[i].value))
      }

      const linePen = new drawing.Pen()
      linePen.setColor(lineColorVal)
      linePen.setStrokeWidth(2.5)
      linePen.setAntiAlias(true)
      canvas.attachPen(linePen)
      canvas.drawPath(linePath)
      canvas.detachPen()

      // 绘制数据点
      const whiteBrush = new drawing.Brush()
      whiteBrush.setColor(whiteColor)
      whiteBrush.setAntiAlias(true)
      const lineBrush = new drawing.Brush()
      lineBrush.setColor(lineColorVal)
      lineBrush.setAntiAlias(true)
      const pointPen = new drawing.Pen()
      pointPen.setColor(lineColorVal)
      pointPen.setStrokeWidth(2)
      pointPen.setAntiAlias(true)

      for (let i = 0; i < data.length; i++) {
        const x = scaleX(i)
        const y = scaleY(data[i].value)
        // 外圈（白底）
        canvas.attachBrush(whiteBrush)
        canvas.drawCircle(x, y, 5)
        canvas.detachBrush()
        // 外圈描边
        canvas.attachPen(pointPen)
        canvas.drawCircle(x, y, 5)
        canvas.detachPen()
        // 内点
        canvas.attachBrush(lineBrush)
        canvas.drawCircle(x, y, 3)
        canvas.detachBrush()
      }

      // 标注最新值
      const lastIdx = data.length - 1
      const lastX = scaleX(lastIdx)
      const lastY = scaleY(data[lastIdx].value)
      this.drawText(canvas, data[lastIdx].value.toFixed(1) + this.unit, lastX + 10, lastY - 4, 11, darkTextColor, 'left')
    }
  }

  /** 使用 Drawing API 绘制文本 */
  private drawText(canvas: drawing.Canvas, text: string, x: number, y: number,
    fontSize: number, color: common2D.Color, align: string): void {
    const font = new drawing.Font()
    font.setSize(fontSize)

    const textBlob = drawing.TextBlob.makeFromString(text, font)
    if (!textBlob) return

    // 处理文本对齐（简化：通过测量偏移实现）
    let drawX: number = x
    if (align === 'center') {
      const b = textBlob.bounds()
      const tw: number = b.right - b.left
      drawX = x - tw / 2
    } else if (align === 'right') {
      const b = textBlob.bounds()
      const tw: number = b.right - b.left
      drawX = x - tw
    }

    const brush = new drawing.Brush()
    brush.setColor(color)
    brush.setAntiAlias(true)
    canvas.attachBrush(brush)
    canvas.drawTextBlob(textBlob, drawX, y)
    canvas.detachBrush()
  }
}
