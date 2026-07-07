import { GrowthRecord, GROWTH_TYPE_LABELS, GROWTH_TYPE_ICONS } from '../model/GrowthRecord'
import { DateUtil } from '../common/Utils'

/**
 * 时间轴条目组件
 * 用于展示带照片的成长记录时间线
 */
@Component
export struct TimelineItem {
  @Prop record: GrowthRecord = new GrowthRecord()
  @Prop isLast: boolean = false
  @Prop isFirst: boolean = false
  onItemClick?: () => void

  build() {
    Row() {
      // 时间轴线和点
      Column() {
        // 时间点
        Column() {
          Text(GROWTH_TYPE_ICONS[this.record.type] || '📌')
            .fontSize(18)
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor('#FFF3E0')
        .justifyContent(FlexAlign.Center)
        .border({ width: 2, color: '#FFB300' })

        // 连接线
        if (!this.isLast) {
          Divider()
            .vertical(false)
            .width(2)
            .height(40)
            .color('#FFCC80')
        }
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 12 })

      // 内容区域
      Column() {
        // 日期和类型
        Row() {
          Text(DateUtil.formatDateCN(this.record.date))
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#424242')
          Blank()
          Text(GROWTH_TYPE_LABELS[this.record.type] || '其他')
            .fontSize(11)
            .fontColor('#FF6F00')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#FFF8E1')
            .borderRadius(10)
        }
        .width('100%')

        // 数据展示
        Row() {
          if (this.record.weight > 0) {
            Row() {
              Text('⚖️')
                .fontSize(13)
              Text(`${this.record.weight}kg`)
                .fontSize(13)
                .fontColor('#616161')
            }
            .margin({ right: 16 })
          }
          if (this.record.height > 0) {
            Row() {
              Text('📏')
                .fontSize(13)
              Text(`${this.record.height}cm`)
                .fontSize(13)
                .fontColor('#616161')
            }
          }
        }
        .width('100%')
        .margin({ top: 4 })

        // 照片预览
        if (this.record.photo) {
          Image(this.record.photo)
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .margin({ top: 8 })
        }

        // 备注
        if (this.record.notes) {
          Text(this.record.notes)
            .fontSize(13)
            .fontColor('#757575')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 6 })
        }
      }
      .padding({ top: 8, bottom: 8, left: 12, right: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .layoutWeight(1)
      .border({ width: 1, color: '#F5F5F5' })
      .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })
      .onClick(() => {
        if (this.onItemClick) this.onItemClick()
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
