import { GrowthRecord, GrowthRecordType, GROWTH_TYPE_LABELS, GROWTH_TYPE_ICONS } from '../model/GrowthRecord'
import { GrowthRecordViewModel } from '../viewmodel/GrowthRecordViewModel'
import { PetViewModel } from '../viewmodel/PetViewModel'
import { GrowthChart } from '../components/GrowthChart'
import { AddRecordDialog } from '../components/AddRecordDialog'
import { DateUtil } from '../common/Utils'
import { router, IDataSource, DataChangeListener } from '@kit.ArkUI'

/**
 * 成长记录页面
 * 包含记录列表、图表视图、添加记录功能
 */
@Entry
@Component
struct GrowthRecordPage {
  @State growthVM: GrowthRecordViewModel = new GrowthRecordViewModel()
  @State petVM: PetViewModel = new PetViewModel()
  @State petId: string = ''
  @State currentTab: string = 'list' // list | chart
  @State showAddDialog: boolean = false

  aboutToAppear(): void {
    // 从路由参数获取petId
    const params = router.getParams() as Record<string, Object>
    if (params && params['petId']) {
      this.petId = params['petId'] as string
    }
    if (params && params['tab']) {
      this.currentTab = params['tab'] as string
    }
    this.loadData()
  }

  async loadData(): Promise<void> {
    if (this.petId) {
      await this.growthVM.loadRecords(this.petId)
      await this.petVM.loadPets()
    }
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

        Text('成长记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
          .margin({ left: 8 })

        Blank()

        // 切换视图
        Row() {
          Text('列表')
            .fontSize(13)
            .fontColor(this.currentTab === 'list' ? '#FF6F00' : '#757575')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.currentTab === 'list' ? '#FFF8E1' : '#F5F5F5')
            .borderRadius(12)
            .onClick(() => { this.currentTab = 'list' })

          Text('图表')
            .fontSize(13)
            .fontColor(this.currentTab === 'chart' ? '#FF6F00' : '#757575')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.currentTab === 'chart' ? '#FFF8E1' : '#F5F5F5')
            .borderRadius(12)
            .margin({ left: 6 })
            .onClick(() => { this.currentTab = 'chart' })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Divider().height(1).color('#F5F5F5')

      // 筛选条件
      this.buildFilterBar()

      if (this.currentTab === 'list') {
        this.buildListView()
      } else {
        this.buildChartView()
      }

      // 添加按钮
      Button() {
        Text('+ 添加记录')
          .fontSize(16)
          .fontColor('#FFFFFF')
      }
      .width('90%')
      .height(44)
      .backgroundColor('#FF6F00')
      .borderRadius(22)
      .margin({ bottom: 16 })
      .onClick(() => { this.showAddDialog = true })

      // 添加记录弹窗
      if (this.showAddDialog) {
        AddRecordDialog({
          showDialog: this.showAddDialog,
          petId: this.petId,
          onConfirm: (record: GrowthRecord) => {
            this.growthVM.addRecord(record)
            // 同步更新宠物最新体重身高
            this.updatePetStats(record)
            this.showAddDialog = false
          },
          onCancel: () => { this.showAddDialog = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  private buildFilterBar(): void {
    Scroll() {
      Row() {
        Text('全部')
          .fontSize(13)
          .fontColor(this.growthVM.filterType === 'all' ? '#FF6F00' : '#757575')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor(this.growthVM.filterType === 'all' ? '#FFF8E1' : '#F5F5F5')
          .borderRadius(16)
          .onClick(() => { this.growthVM.setFilterType('all') })

        ForEach(Object.keys(GROWTH_TYPE_LABELS), (key: string) => {
          Text(GROWTH_TYPE_ICONS[key] + ' ' + GROWTH_TYPE_LABELS[key])
            .fontSize(12)
            .fontColor(this.growthVM.filterType === key ? '#FF6F00' : '#757575')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.growthVM.filterType === key ? '#FFF8E1' : '#F5F5F5')
            .borderRadius(16)
            .margin({ left: 6 })
            .onClick(() => { this.growthVM.setFilterType(key) })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .height(44)
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  private buildListView(): void {
    if (this.growthVM.records.length === 0) {
      Column() {
        Text('📝')
          .fontSize(48)
          .opacity(0.3)
        Text('暂无成长记录')
          .fontSize(15)
          .fontColor('#BDBDBD')
          .margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      // 使用 LazyForEach 优化长列表渲染
      List() {
        LazyForEach(new RecordDataSource(this.growthVM.records), (record: GrowthRecord, index: number) => {
          ListItem() {
            this.buildRecordItem(record)
          }
          .margin({ left: 16, right: 16, bottom: 8 })
        }, (record: GrowthRecord) => record.id)
      }
      .layoutWeight(1)
      .padding({ top: 4 })
    }
  }

  @Builder
  private buildRecordItem(record: GrowthRecord): void {
    Row() {
      // 图标
      Column() {
        Text(GROWTH_TYPE_ICONS[record.type] || '📌')
          .fontSize(22)
          .width(42)
          .height(42)
          .borderRadius(21)
          .backgroundColor('#FFF3E0')
          .textAlign(TextAlign.Center)
      }

      Column() {
        Row() {
          Text(GROWTH_TYPE_LABELS[record.type] || '其他')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#424242')
          Blank()
          Text(record.date)
            .fontSize(11)
            .fontColor('#9E9E9E')
        }
        .width('100%')

        Row() {
          if (record.weight > 0) {
            Text(`⚖️ ${record.weight}kg`)
              .fontSize(12)
              .fontColor('#616161')
              .margin({ right: 12 })
          }
          if (record.height > 0) {
            Text(`📏 ${record.height}cm`)
              .fontSize(12)
              .fontColor('#616161')
          }
        }
        .width('100%')
        .margin({ top: 2 })

        if (record.notes) {
          Text(record.notes)
            .fontSize(12)
            .fontColor('#BDBDBD')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)

      Button() {
        Text('🗑️')
          .fontSize(14)
      }
      .width(30)
      .height(30)
      .borderRadius(15)
      .backgroundColor('#F5F5F5')
      .onClick(() => { this.growthVM.deleteRecord(record.id) })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: '#F5F5F5' })
  }

  @Builder
  private buildChartView(): void {
    Scroll() {
      Column() {
        // 体重图表
        GrowthChart({
          chartData: this.growthVM.getWeightChartData(),
          chartTitle: '⚖️ 体重变化趋势',
          lineColor: '#FF6F00',
          unit: 'kg'
        })
        .margin({ bottom: 24 })

        // 身高图表
        GrowthChart({
          chartData: this.growthVM.getHeightChartData(),
          chartTitle: '📏 身高变化趋势',
          lineColor: '#42A5F5',
          unit: 'cm'
        })
        .margin({ bottom: 24 })

        // 数据汇总
        this.buildStatsSummary()
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 80 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildStatsSummary(): void {
    Column() {
      Text('📊 数据汇总')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#424242')
        .width('100%')
        .margin({ bottom: 12 })

      Grid() {
        GridItem() {
          Column() {
            Text('⚖️')
              .fontSize(20)
            Text('最新体重')
              .fontSize(12)
              .fontColor('#757575')
            Text(`${this.growthVM.getLatestWeight()}kg`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6F00')
              .margin({ top: 2 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
        }
        GridItem() {
          Column() {
            Text('📏')
              .fontSize(20)
            Text('最新身高')
              .fontSize(12)
              .fontColor('#757575')
            Text(`${this.growthVM.getLatestHeight()}cm`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#42A5F5')
              .margin({ top: 2 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
        }
        GridItem() {
          Column() {
            Text('📝')
              .fontSize(20)
            Text('总记录数')
              .fontSize(12)
              .fontColor('#757575')
            Text(`${this.growthVM.records.length}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#66BB6A')
              .margin({ top: 2 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
        }
        GridItem() {
          Column() {
            Text('📸')
              .fontSize(20)
            Text('照片记录')
              .fontSize(12)
              .fontColor('#757575')
            Text(`${this.growthVM.getPhotoRecords().length}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#AB47BC')
              .margin({ top: 2 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .height(220)
    }
  }

  private async updatePetStats(record: GrowthRecord): Promise<void> {
    // 如果有体重或身高更新，更新宠物档案
    if (record.weight > 0 || record.height > 0) {
      const pet = this.petVM.pets.find(p => p.id === record.petId)
      if (pet) {
        if (record.weight > 0) pet.weight = record.weight
        if (record.height > 0) pet.height = record.height
        await this.petVM.savePet()
      }
    }
  }
}

/**
 * 数据源适配器，用于 LazyForEach
 */
class RecordDataSource implements IDataSource {
  private records: GrowthRecord[]
  private listeners: DataChangeListener[] = []

  constructor(records: GrowthRecord[]) {
    this.records = records
  }

  totalCount(): number {
    return this.records.length
  }

  getData(index: number): GrowthRecord {
    return this.records[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }
}
