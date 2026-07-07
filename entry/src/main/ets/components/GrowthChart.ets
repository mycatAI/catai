import { ChartDataPoint } from '../viewmodel/GrowthRecordViewModel'

/**
 * 成长趋势图表组件
 * 使用 Canvas 自绘制，展示体重/身高曲线
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
        // 空状态
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
        // 图表区域
        Column() {
          Canvas(this.renderChart.bind(this))
            .width('100%')
            .height(this.chartHeight)
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

  private renderChart(context: CanvasRenderingContext2D): void {
    const data = this.chartData
    if (data.length === 0) return

    const w = this.canvasWidth
    const h = this.chartHeight
    const padding = { top: 20, right: 16, bottom: 40, left: 40 }
    const chartW = w - padding.left - padding.right
    const chartH = h - padding.top - padding.bottom

    // 找到最大值和最小值
    const values = data.map(d => d.value)
    const minVal = Math.min(...values)
    const maxVal = Math.max(...values)
    const range = maxVal - minVal || 1
    const yMin = minVal - range * 0.1
    const yMax = maxVal + range * 0.1

    // 比例尺
    const scaleX = (index: number): number => padding.left + (index / Math.max(data.length - 1, 1)) * chartW
    const scaleY = (val: number): number => padding.top + chartH - ((val - yMin) / (yMax - yMin)) * chartH

    // 绘制背景网格
    context.strokeStyle = '#E0E0E0'
    context.lineWidth = 0.5
    const gridLines = 4
    for (let i = 0; i <= gridLines; i++) {
      const y = padding.top + (chartH / gridLines) * i
      context.beginPath()
      context.moveTo(padding.left, y)
      context.lineTo(w - padding.right, y)
      context.stroke()
      // Y轴标签
      const val = yMax - ((yMax - yMin) / gridLines) * i
      context.fillStyle = '#9E9E9E'
      context.font = '10px sans-serif'
      context.textAlign = 'right'
      context.fillText(val.toFixed(1) + this.unit, padding.left - 4, y + 4)
    }

    // 绘制X轴标签
    context.textAlign = 'center'
    context.fillStyle = '#9E9E9E'
    context.font = '9px sans-serif'
    const labelStep = Math.max(1, Math.floor(data.length / 6))
    for (let i = 0; i < data.length; i += labelStep) {
      const x = scaleX(i)
      context.fillText(data[i].label, x, h - padding.bottom + 16)
    }
    // 最后一个标签
    if (data.length > 1 && (data.length - 1) % labelStep !== 0) {
      const lastX = scaleX(data.length - 1)
      context.fillText(data[data.length - 1].label, lastX, h - padding.bottom + 16)
    }

    // 绘制数据点和连线
    if (data.length === 1) {
      // 单个点
      const x = scaleX(0)
      const y = scaleY(data[0].value)
      context.fillStyle = this.lineColor
      context.beginPath()
      context.arc(x, y, 6, 0, 2 * Math.PI)
      context.fill()
      context.fillStyle = '#212121'
      context.font = '11px sans-serif'
      context.textAlign = 'center'
      context.fillText(data[0].value.toFixed(1) + this.unit, x, y - 14)
    } else {
      // 绘制连线
      context.strokeStyle = this.lineColor
      context.lineWidth = 2.5
      context.lineJoin = 'round'
      context.beginPath()
      context.moveTo(scaleX(0), scaleY(data[0].value))
      for (let i = 1; i < data.length; i++) {
        context.lineTo(scaleX(i), scaleY(data[i].value))
      }
      context.stroke()

      // 绘制数据点
      for (let i = 0; i < data.length; i++) {
        const x = scaleX(i)
        const y = scaleY(data[i].value)
        // 外圈
        context.fillStyle = '#FFFFFF'
        context.beginPath()
        context.arc(x, y, 5, 0, 2 * Math.PI)
        context.fill()
        context.strokeStyle = this.lineColor
        context.lineWidth = 2
        context.stroke()
        // 内点
        context.fillStyle = this.lineColor
        context.beginPath()
        context.arc(x, y, 3, 0, 2 * Math.PI)
        context.fill()
      }

      // 标注最新值
      const lastIdx = data.length - 1
      const lastX = scaleX(lastIdx)
      const lastY = scaleY(data[lastIdx].value)
      context.fillStyle = '#212121'
      context.font = 'bold 11px sans-serif'
      context.textAlign = 'left'
      context.fillText(data[lastIdx].value.toFixed(1) + this.unit, lastX + 10, lastY - 4)
    }
  }
}
