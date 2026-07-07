import { HealthReminder, REMINDER_TYPE_ICONS, REPEAT_CYCLE_LABELS } from '../model/HealthReminder'
import { DateUtil } from '../common/Utils'

/**
 * 提醒卡片组件
 * 展示健康提醒信息
 */
@Component
export struct ReminderCard {
  @Prop reminder: HealthReminder = new HealthReminder()
  @Prop showPetName: boolean = false
  @Prop petName: string = ''
  onToggle?: (reminder: HealthReminder) => void
  onEdit?: (reminder: HealthReminder) => void
  onDelete?: (reminder: HealthReminder) => void

  build() {
    Row() {
      // 类型图标
      Column() {
        Text(REMINDER_TYPE_ICONS[this.reminder.type] || '📌')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor('#FFF3E0')
      .justifyContent(FlexAlign.Center)

      // 信息区域
      Column() {
        Row() {
          Text(this.reminder.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#212121')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          // 启用开关
          Toggle({ type: ToggleType.Switch, isOn: this.reminder.enabled })
            .width(40)
            .selectedColor('#FF6F00')
            .onChange((isOn: boolean) => {
              if (this.onToggle) {
                this.onToggle(this.reminder)
              }
            })
        }
        .width('100%')

        Row() {
          Text(`📅 ${this.reminder.date} ${this.reminder.time}`)
            .fontSize(12)
            .fontColor('#757575')

          if (this.reminder.repeatCycle !== 'none') {
            Text(' · ')
              .fontSize(12)
              .fontColor('#BDBDBD')
            Text(`🔄 ${REPEAT_CYCLE_LABELS[this.reminder.repeatCycle] || ''}`)
              .fontSize(12)
              .fontColor('#FF6F00')
          }
        }
        .width('100%')
        .margin({ top: 4 })

        if (this.showPetName && this.petName) {
          Text(`🐾 ${this.petName}`)
            .fontSize(11)
            .fontColor('#9E9E9E')
            .margin({ top: 2 })
        }

        if (this.reminder.notes) {
          Text(this.reminder.notes)
            .fontSize(12)
            .fontColor('#BDBDBD')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      // 操作按钮
      Row() {
        Button() {
          Text('✏️')
            .fontSize(14)
        }
        .width(28)
        .height(28)
        .borderRadius(14)
        .backgroundColor('#F5F5F5')
        .onClick(() => {
          if (this.onEdit) this.onEdit(this.reminder)
        })

        Button() {
          Text('🗑️')
            .fontSize(14)
        }
        .width(28)
        .height(28)
        .borderRadius(14)
        .backgroundColor('#F5F5F5')
        .margin({ left: 6 })
        .onClick(() => {
          if (this.onDelete) this.onDelete(this.reminder)
        })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F5F5F5' })
    .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })
  }
}
