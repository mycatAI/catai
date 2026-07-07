import { GrowthRecord } from '../model/GrowthRecord'
import { GrowthRecordViewModel } from '../viewmodel/GrowthRecordViewModel'
import { TimelineItem } from '../components/TimelineItem'
import { DateUtil } from '../common/Utils'
import { router } from '@kit.ArkUI'

/**
 * 时间轴相册页面
 * 按日期排列宠物照片，形成成长时间轴
 */
@Entry
@Component
struct TimelinePage {
  @State growthVM: GrowthRecordViewModel = new GrowthRecordViewModel()
  @State petId: string = ''
  @State groupedRecords: Map<string, GrowthRecord[]> = new Map()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params && params['petId']) {
      this.petId = params['petId'] as string
    }
    this.loadData()
  }

  async loadData(): Promise<void> {
    if (this.petId) {
      await this.growthVM.loadRecords(this.petId)
      this.groupByDate()
    }
  }

  groupByDate(): void {
    const map = new Map<string, GrowthRecord[]>()
    for (const record of this.growthVM.records) {
      if (record.photo) {
        const key = record.date.substring(0, 7) // YYYY-MM
        const list = map.get(key) || []
        list.push(record)
        map.set(key, list)
      }
    }
    this.groupedRecords = map
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor('#424242')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => { router.back() })

        Text('时间轴相册')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
          .margin({ left: 8 })

        Blank()

        Text(`共${this.growthVM.getPhotoRecords().length}张`)
          .fontSize(13)
          .fontColor('#9E9E9E')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Divider().height(1).color('#F5F5F5')

      if (this.groupedRecords.size === 0) {
        Column() {
          Text('📸')
            .fontSize(64)
            .opacity(0.3)
          Text('还没有照片记录')
            .fontSize(15)
            .fontColor('#BDBDBD')
            .margin({ top: 12 })
          Text('在成长记录中添加照片\n它们会按时间排列在这里')
            .fontSize(13)
            .fontColor('#E0E0E0')
            .textAlign(TextAlign.Center)
            .margin({ top: 4 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 时间轴列表
        List() {
          ForEach(Array.from(this.groupedRecords.entries()).sort((a, b) => b[0].localeCompare(a[0])),
          (entry: [string, GrowthRecord[]], monthIndex: number) => {
            ListItem() {
              Column() {
                // 月份标题
                Row() {
                  Text(this.formatMonth(entry[0]))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FF6F00')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor('#FFF8E1')
                    .borderRadius(16)

                  Blank()

                  Text(`${entry[1].length}条记录`)
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                }
                .width('100%')
                .margin({ bottom: 12 })

                // 该月的照片网格
                Grid() {
                  ForEach(entry[1], (record: GrowthRecord, index: number) => {
                    GridItem() {
                      Stack() {
                        Image(record.photo)
                          .width('100%')
                          .height('100%')
                          .objectFit(ImageFit.Cover)
                          .borderRadius(8)

                        // 日期角标
                        Text(record.date.substring(8)) // DD
                          .fontSize(11)
                          .fontColor('#FFFFFF')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .backgroundColor('#00000060')
                          .borderRadius(8)
                          .position({ x: 6, y: 6 })
                      }
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsGap(4)
                .columnsGap(4)

                // 该月的记录列表
                Column() {
                  ForEach(entry[1].sort((a, b) => DateUtil.compareDate(b.date, a.date)),
                  (record: GrowthRecord, idx: number) => {
                    TimelineItem({
                      record: record,
                      isFirst: idx === 0,
                      isLast: idx === entry[1].length - 1
                    })
                  })
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
            }
            .margin({ bottom: 24 })
          })
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  private formatMonth(ymStr: string): string {
    const parts = ymStr.split('-')
    if (parts.length !== 2) return ymStr
    return `${parts[0]}年${parseInt(parts[1])}月`
  }
}
