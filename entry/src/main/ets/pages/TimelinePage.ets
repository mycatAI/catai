import { GrowthRecord } from '../model/GrowthRecord'
import { GrowthRecordViewModel } from '../viewmodel/GrowthRecordViewModel'
import { GROWTH_TYPE_LABELS, GROWTH_TYPE_ICONS } from '../model/GrowthRecord'
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
        const key = record.date.substring(0, 7)
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

        Text(this.growthVM.getPhotoRecords().length + '张')
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
        Scroll() {
          Column() {
            ForEach(Array.from(this.groupedRecords.entries()).sort((a, b) => b[0].localeCompare(a[0])),
            (entry: [string, GrowthRecord[]], monthIndex: number) => {
              Column() {
                // 月份标题
                Row() {
                  Column() {
                    Text(this.formatMonth(entry[0]))
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#212121')
                  }

                  Blank()

                  Column() {
                    Text(entry[1].length + '张')
                      .fontSize(12)
                      .fontColor('#FF6F00')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor('#FFF8E1')
                      .borderRadius(10)
                  }
                }
                .width('100%')
                .margin({ bottom: 12 })

                // 照片网格 - 3列
                Grid() {
                  ForEach(entry[1].sort((a, b) => DateUtil.compareDate(b.date, a.date)),
                  (record: GrowthRecord, idx: number) => {
                    GridItem() {
                      Column() {
                        // 照片
                        Image(record.photo)
                          .width('100%')
                          .aspectRatio(1)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(8)

                        // 底部信息栏
                        Row() {
                          Text(GROWTH_TYPE_ICONS[record.type] || '📌')
                            .fontSize(12)
                          Text(record.date.substring(5))
                            .fontSize(11)
                            .fontColor('#757575')
                            .margin({ left: 4 })
                          if (record.notes) {
                            Text(record.notes)
                              .fontSize(10)
                              .fontColor('#BDBDBD')
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                              .layoutWeight(1)
                              .margin({ left: 4 })
                          }
                        }
                        .width('100%')
                        .margin({ top: 4 })
                      }
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsGap(8)
                .columnsGap(8)
              }
              .width('100%')
              .margin({ bottom: 28 })
            })
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 32 })
        }
        .layoutWeight(1)
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
    return parts[0] + '年' + parseInt(parts[1]) + '月'
  }
}
