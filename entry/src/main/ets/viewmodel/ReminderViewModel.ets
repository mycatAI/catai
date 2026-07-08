import { HealthReminder, ReminderType, REMINDER_TYPE_LABELS, REMINDER_TYPE_ICONS, RepeatCycle, REPEAT_CYCLE_LABELS } from '../model/HealthReminder'
import { DatabaseService } from '../service/DatabaseService'
import { NotificationService } from '../service/NotificationService'
import { DateUtil } from '../common/Utils'

/** 类型选项 */
export interface TypeOption {
  key: string
  label: string
  icon: string
}

/** 重复周期选项 */
export interface CycleOption {
  key: string
  label: string
}

/**
 * 健康提醒 ViewModel
 */
@Observed
export class ReminderViewModel {
  /** 提醒列表 */
  reminders: HealthReminder[] = []
  /** 是否正在加载 */
  isLoading: boolean = false
  /** 当前操作的宠物ID */
  petId: string = ''
  /** 是否显示编辑弹窗 */
  showEditDialog: boolean = false
  /** 编辑中的提醒 */
  editingReminder: HealthReminder = new HealthReminder()

  private db: DatabaseService = DatabaseService.getInstance()
  private notificationService: NotificationService = NotificationService.getInstance()

  /**
   * 加载提醒列表
   */
  async loadReminders(petId: string): Promise<void> {
    this.petId = petId
    this.isLoading = true
    try {
      this.reminders = await this.db.queryRemindersByPetId(petId)
    } finally {
      this.isLoading = false
    }
  }

  /**
   * 获取今日待办提醒
   */
  getTodayReminders(): HealthReminder[] {
    const today = DateUtil.today()
    return this.reminders.filter(r => r.enabled && r.date <= today)
  }

  /**
   * 获取即将到期的提醒（未来7天）
   */
  getUpcomingReminders(): HealthReminder[] {
    const today = DateUtil.today()
    const future = DateUtil.addDays(today, 7)
    return this.reminders.filter(r => r.enabled && r.date >= today && r.date <= future)
  }

  /**
   * 打开添加提醒弹窗
   */
  openAddReminderDialog(): void {
    const reminder = new HealthReminder()
    reminder.id = DateUtil.generateId()
    reminder.petId = this.petId
    reminder.type = ReminderType.CUSTOM
    reminder.title = ''
    reminder.date = DateUtil.today()
    reminder.time = '09:00'
    reminder.repeatCycle = RepeatCycle.NONE
    reminder.enabled = true
    reminder.notes = ''
    reminder.createTime = DateUtil.today()
    this.editingReminder = reminder
    this.showEditDialog = true
  }

  /**
   * 打开编辑提醒弹窗
   */
  openEditReminderDialog(reminder: HealthReminder): void {
    const newReminder = new HealthReminder()
    newReminder.id = reminder.id
    newReminder.petId = reminder.petId
    newReminder.type = reminder.type
    newReminder.title = reminder.title
    newReminder.date = reminder.date
    newReminder.time = reminder.time
    newReminder.repeatCycle = reminder.repeatCycle
    newReminder.enabled = reminder.enabled
    newReminder.notes = reminder.notes
    newReminder.createTime = reminder.createTime
    this.editingReminder = newReminder
    this.showEditDialog = true
  }

  /**
   * 关闭弹窗
   */
  closeEditDialog(): void {
    this.showEditDialog = false
    this.editingReminder = new HealthReminder()
  }

  /**
   * 保存提醒
   */
  async saveReminder(): Promise<boolean> {
    const reminder = this.editingReminder
    if (!reminder.title.trim()) {
      return false
    }
    const isNew = !this.reminders.some(r => r.id === reminder.id)
    const success = isNew ?
      await this.db.insertReminder(reminder) :
      await this.db.updateReminder(reminder)
    if (success) {
      await this.loadReminders(this.petId)
      // 同步通知
      if (reminder.enabled) {
        await this.notificationService.scheduleReminderNotification(reminder)
      }
      this.closeEditDialog()
    }
    return success
  }

  /**
   * 切换提醒启用状态
   */
  async toggleReminder(reminder: HealthReminder): Promise<void> {
    reminder.enabled = !reminder.enabled
    await this.db.updateReminder(reminder)
    if (reminder.enabled) {
      await this.notificationService.scheduleReminderNotification(reminder)
    } else {
      await this.notificationService.cancelReminderNotifications(reminder.id)
    }
    await this.loadReminders(this.petId)
  }

  /**
   * 删除提醒
   */
  async deleteReminder(reminderId: string): Promise<boolean> {
    const success = await this.db.deleteReminder(reminderId)
    if (success) {
      await this.notificationService.cancelReminderNotifications(reminderId)
      await this.loadReminders(this.petId)
    }
    return success
  }

  /**
   * 获取提醒类型选项
   */
  getTypeOptions(): TypeOption[] {
    const result: TypeOption[] = []
    const keys = Object.keys(REMINDER_TYPE_LABELS)
    for (let i = 0; i < keys.length; i++) {
      const k = keys[i]
      const opt: TypeOption = { key: k, label: REMINDER_TYPE_LABELS[k], icon: REMINDER_TYPE_ICONS[k] || '📌' }
      result.push(opt)
    }
    return result
  }

  /**
   * 获取重复周期选项
   */
  getRepeatCycleOptions(): CycleOption[] {
    const result: CycleOption[] = []
    const keys = Object.keys(REPEAT_CYCLE_LABELS)
    for (let i = 0; i < keys.length; i++) {
      const k = keys[i]
      const opt: CycleOption = { key: k, label: REPEAT_CYCLE_LABELS[k] }
      result.push(opt)
    }
    return result
  }

  /**
   * 获取提醒类型标签
   */
  getTypeLabel(type: string): string {
    return REMINDER_TYPE_LABELS[type] || type
  }

  /**
   * 获取提醒类型图标
   */
  getTypeIcon(type: string): string {
    return REMINDER_TYPE_ICONS[type] || '📌'
  }

  /**
   * 请求通知权限
   */
  async requestNotificationPermission(): Promise<boolean> {
    return await this.notificationService.requestNotificationPermission()
  }
}
