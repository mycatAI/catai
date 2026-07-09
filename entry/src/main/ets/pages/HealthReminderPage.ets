import { HealthReminder, ReminderType, RepeatCycle } from '../model/HealthReminder'
import { ReminderViewModel, TypeOption, CycleOption } from '../viewmodel/ReminderViewModel'
import { ReminderCard } from '../components/ReminderCard'
import { DateUtil } from '../common/Utils'
import { router } from '@kit.ArkUI'

/**
 * 健康提醒页面
 * 管理宠物的疫苗、驱虫、体检等健康提醒
 */
@Entry
@Component
struct HealthReminderPage {
  @State reminderVM: ReminderViewModel = new ReminderViewModel()
  @State petId: string = ''
  @State showAddDialog: boolean = false
  @State currentFilter: string = 'all' // all | today | upcoming

  // 编辑表单状态
  @State editTitle: string = ''
  @State editType: string = ReminderType.CUSTOM
  @State editDate: string = ''
  @State editTime: string = ''
  @State editCycle: string = 'none'
  @State editNotes: string = ''
  @State editEnabled: boolean = true

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params && params['petId']) {
      this.petId = params['petId'] as string
    }
    this.loadData()
  }

  async loadData(): Promise<void> {
    if (this.petId) {
      await this.reminderVM.loadReminders(this.petId)
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

        Text('健康提醒')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
          .margin({ left: 8 })

        Blank()

        Button('+ 添加')
          .fontSize(14)
          .fontColor('#FF6F00')
          .backgroundColor('#FFF8E1')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => { this.openAddDialog() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Divider().height(1).color('#F5F5F5')

      // 筛选条
      this.buildFilterTabs()

      // 提醒列表
      if (this.reminderVM.reminders.length === 0) {
        this.buildEmptyState()
      } else {
        Scroll() {
          Column() {
            ForEach(this.getFilteredReminders(), (reminder: HealthReminder) => {
              ReminderCard({
                reminder: reminder,
                onToggle: () => { this.reminderVM.toggleReminder(reminder) },
                onEdit: () => { this.openEditDialog(reminder) },
                onDelete: () => { this.reminderVM.deleteReminder(reminder.id) }
              })
            })
          }
          .padding({ left: 16, right: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 添加/编辑弹窗
      if (this.showAddDialog) {
        this.buildEditDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  private buildFilterTabs(): void {
    Row() {
      Text('全部')
        .fontSize(13)
        .fontColor(this.currentFilter === 'all' ? '#FF6F00' : '#757575')
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .backgroundColor(this.currentFilter === 'all' ? '#FFF8E1' : '#F5F5F5')
        .borderRadius(16)
        .onClick(() => { this.currentFilter = 'all' })

      Text('今日待办')
        .fontSize(13)
        .fontColor(this.currentFilter === 'today' ? '#FF6F00' : '#757575')
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .backgroundColor(this.currentFilter === 'today' ? '#FFF8E1' : '#F5F5F5')
        .borderRadius(16)
        .margin({ left: 8 })
        .onClick(() => { this.currentFilter = 'today' })

      Text('近期提醒')
        .fontSize(13)
        .fontColor(this.currentFilter === 'upcoming' ? '#FF6F00' : '#757575')
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .backgroundColor(this.currentFilter === 'upcoming' ? '#FFF8E1' : '#F5F5F5')
        .borderRadius(16)
        .margin({ left: 8 })
        .onClick(() => { this.currentFilter = 'upcoming' })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  private getFilteredReminders(): HealthReminder[] {
    switch (this.currentFilter) {
      case 'today':
        return this.reminderVM.getTodayReminders()
      case 'upcoming':
        return this.reminderVM.getUpcomingReminders()
      default:
        return this.reminderVM.reminders
    }
  }

  private openAddDialog(): void {
    this.editTitle = ''
    this.editType = ReminderType.CUSTOM
    this.editDate = DateUtil.today()
    this.editTime = '09:00'
    this.editCycle = 'none'
    this.editNotes = ''
    this.editEnabled = true
    this.reminderVM.editingReminder = new HealthReminder()
    this.showAddDialog = true
  }

  private openEditDialog(reminder: HealthReminder): void {
    this.editTitle = reminder.title
    this.editType = reminder.type
    this.editDate = reminder.date
    this.editTime = reminder.time
    this.editCycle = reminder.repeatCycle
    this.editNotes = reminder.notes
    this.editEnabled = reminder.enabled
    this.reminderVM.editingReminder = reminder
    this.showAddDialog = true
  }

  private async saveReminder(): Promise<void> {
    const isNew = !this.reminderVM.editingReminder.id
    const reminder = new HealthReminder()
    reminder.id = this.reminderVM.editingReminder.id // 新建时为空，由服务端分配
    reminder.petId = this.petId
    reminder.title = this.editTitle
    reminder.type = this.editType as ReminderType
    reminder.date = this.editDate
    reminder.time = this.editTime
    reminder.repeatCycle = this.editCycle as RepeatCycle
    reminder.enabled = this.editEnabled
    reminder.notes = this.editNotes
    reminder.createTime = isNew ? DateUtil.today() : this.reminderVM.editingReminder.createTime
    this.reminderVM.editingReminder = reminder

    // 请求通知权限（首次保存提醒时）
    await this.reminderVM.requestNotificationPermission()

    await this.reminderVM.saveReminder()
    this.showAddDialog = false
  }

  // 打开系统日期选择器
  private showDatePicker(): void {
    const parts = this.editDate.split('-').map(Number)
    const selectedDate = new Date(parts[0] || 2025, (parts[1] || 1) - 1, parts[2] || 1)

    DatePickerDialog.show({
      start: new Date('2020-1-1'),
      end: new Date('2100-12-31'),
      selected: selectedDate,
      lunar: false,
      onAccept: (value: DatePickerResult) => {
        const y = value.year ?? selectedDate.getFullYear()
        const m = (value.month ?? 0) + 1
        const d = value.day ?? 1
        this.editDate = `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`
      }
    })
  }

  // 打开系统时间选择器
  private showTimePicker(): void {
    const parts = this.editTime.split(':').map(Number)
    const selectedDate = new Date()
    selectedDate.setHours(parts[0] || 9, parts[1] || 0, 0, 0)

    TimePickerDialog.show({
      selected: selectedDate,
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        const h = value.hour ?? 9
        const m = value.minute ?? 0
        this.editTime = `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
      }
    })
  }

  @Builder
  private buildEditDialog(): void {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => { this.showAddDialog = false })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column() {
      Text(this.reminderVM.editingReminder.id ? '编辑提醒' : '添加提醒')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 20 })

      Scroll() {
        Column() {
          // 标题
          this.buildLabel('提醒标题')
          TextInput({ text: this.editTitle, placeholder: '如：打狂犬疫苗' })
            .fontSize(14)
            .width('100%')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 14 })
            .onChange((v: string) => { this.editTitle = v })

          // 提醒类型
          this.buildLabel('提醒类型')
          Grid() {
            ForEach(this.reminderVM.getTypeOptions(), (opt: TypeOption) => {
              GridItem() {
                Column() {
                  Text(opt.icon)
                    .fontSize(18)
                  Text(opt.label)
                    .fontSize(10)
                    .fontColor(this.editType === opt.key ? '#FF6F00' : '#757575')
                }
                .width('100%')
                .padding({ top: 6, bottom: 6 })
                .backgroundColor(this.editType === opt.key ? '#FFF8E1' : '#FAFAFA')
                .borderRadius(8)
                .border({ width: this.editType === opt.key ? 1.5 : 0, color: '#FFB300' })
                .onClick(() => { this.editType = opt.key })
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsGap(6)
          .columnsGap(6)
          .margin({ bottom: 14 })

          // 日期和时间（使用系统选择器）
          Row() {
            Column() {
              this.buildLabel('日期')
              Button() {
                Row() {
                  Text('📅')
                    .fontSize(14)
                    .margin({ right: 6 })
                  Text(this.editDate)
                    .fontSize(14)
                    .fontColor('#424242')
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
              .width('100%')
              .height(40)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onClick(() => { this.showDatePicker() })
            }
            .layoutWeight(1)

            Column() {
              this.buildLabel('时间')
              Button() {
                Row() {
                  Text('⏰')
                    .fontSize(14)
                    .margin({ right: 6 })
                  Text(this.editTime)
                    .fontSize(14)
                    .fontColor('#424242')
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
              .width('100%')
              .height(40)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => { this.showTimePicker() })
            }
            .layoutWeight(1)
            .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 14 })

          // 重复周期
          this.buildLabel('重复周期')
          Scroll() {
            Row() {
              ForEach(this.reminderVM.getRepeatCycleOptions(), (opt: CycleOption) => {
                Text(opt.label)
                  .fontSize(12)
                  .fontColor(this.editCycle === opt.key ? '#FF6F00' : '#757575')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.editCycle === opt.key ? '#FFF8E1' : '#F5F5F5')
                  .borderRadius(14)
                  .margin({ right: 6 })
                  .onClick(() => { this.editCycle = opt.key })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .height(36)
          .margin({ bottom: 14 })

          // 备注
          this.buildLabel('备注')
          TextArea({ text: this.editNotes, placeholder: '额外说明...' })
            .fontSize(14)
            .height(60)
            .width('100%')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .onChange((v: string) => { this.editNotes = v })
        }
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)

      Row() {
        Button('取消')
          .fontSize(15)
          .fontColor('#757575')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onClick(() => { this.showAddDialog = false })

        Button('保存')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FF6F00')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick(() => { this.saveReminder() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('92%')
    .height('85%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .position({ x: '4%', y: '8%' })
  }

  @Builder
  private buildLabel(text: string): void {
    Text(text)
      .fontSize(13)
      .fontColor('#757575')
      .margin({ bottom: 4 })
      .width('100%')
  }

  @Builder
  private buildEmptyState(): void {
    Column() {
      Text('💉')
        .fontSize(64)
        .opacity(0.3)
      Text('还没有健康提醒')
        .fontSize(15)
        .fontColor('#BDBDBD')
        .margin({ top: 12 })
      Text('添加疫苗、驱虫、体检等提醒\n守护宠物的健康')
        .fontSize(13)
        .fontColor('#E0E0E0')
        .textAlign(TextAlign.Center)
        .margin({ top: 4 })
      Button('添加提醒')
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF6F00')
        .borderRadius(24)
        .padding({ left: 24, right: 24 })
        .margin({ top: 16 })
        .onClick(() => { this.openAddDialog() })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
