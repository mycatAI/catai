import { ChartDataPoint } from '../viewmodel/GrowthRecordViewModel'

/**
 * 成长趋势图表组件
 * 使用简单 UI 组件展示数据，避免 Drawing API 兼容性问题
 */
@Component
export struct GrowthChart {
  @Prop chartData: ChartDataPoint[] = []
  @Prop chartTitle: string = '成长趋势'
  @Prop lineColor: string = '#FF6F00'
  @Prop unit: string = 'kg'

  build() {
    Column() {
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
        .height(200)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
      } else {
        Column() {
          ForEach(this.chartData, (point: ChartDataPoint) => {
            Row() {
              Text(point.label)
                .fontSize(12)
                .fontColor('#757575')
                .width(56)
                .textAlign(TextAlign.Center)

              Row() {
                Row()
                  .height(22)
                  .backgroundColor(this.lineColor)
                  .borderRadius(11)
                  .width(this.barPct(point.value))

                Text(this.formatNum(point.value) + ' ' + this.unit)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#424242')
                  .margin({ left: 8 })
              }
              .layoutWeight(1)
              .height(26)
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding({ top: 7, bottom: 7 })
          }, (point: ChartDataPoint) => point.date)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
      }
    }
  }

  private barPct(value: number): string {
    let max = 0
    for (let i = 0; i < this.chartData.length; i++) {
      if (this.chartData[i].value > max) max = this.chartData[i].value
    }
    if (max <= 0) return '5%'
    const pct = (value / max) * 100
    if (pct < 5) return '5%'
    return Math.floor(pct).toString() + '%'
  }

  private formatNum(value: number): string {
    const intPart = Math.floor(value)
    const decPart = Math.floor((value - intPart) * 10)
    return intPart.toString() + '.' + decPart.toString()
  }
}
