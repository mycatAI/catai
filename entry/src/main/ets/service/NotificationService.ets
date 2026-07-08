import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { HealthReminder } from '../model/HealthReminder'

const REMINDER_SLOT_TYPE: notificationManager.SlotType = notificationManager.SlotType.SOCIAL_COMMUNICATION

/**
 * 通知服务
 * 使用 reminderAgentManager 创建带铃声的定时提醒通知
 */
export class NotificationService {
  private static instance: NotificationService
  private reminderIdMap: Map<string, number> = new Map()
  private slotAdded: boolean = false

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService()
    }
    return NotificationService.instance
  }

  /**
   * 初始化通知槽位（必须在使用通知前调用）
   */
  async initNotificationSlot(): Promise<void> {
    if (this.slotAdded) return
    try {
      // 获取已存在的 slot，避免重复添加报错
      const existingSlot = await notificationManager.getSlot(REMINDER_SLOT_TYPE)
      if (existingSlot) {
        this.slotAdded = true
        console.info('[NotificationService] 通知槽位已存在，跳过创建')
        return
      }
    } catch (_err) {
      // slot 不存在，需要创建
    }

    try {
      // addSlot 在当前SDK中第二个参数是回调函数
      await notificationManager.addSlot(REMINDER_SLOT_TYPE, (err: Error) => {
        if (err) {
          console.error('[NotificationService] 通知槽位创建失败:', JSON.stringify(err))
        } else {
          this.slotAdded = true
          console.info('[NotificationService] 通知槽位创建成功（使用默认铃声+震动）')
        }
      })
      // 默认槽位已包含铃声和震动，无需额外配置
      this.slotAdded = true
    } catch (err) {
      console.error('[NotificationService] 通知槽位创建异常:', JSON.stringify(err))
    }
  }

  /**
   * 为单个提醒创建定时通知（带铃声）
   */
  async scheduleReminderNotification(reminder: HealthReminder): Promise<void> {
    try {
      // 确保槽位已创建
      await this.initNotificationSlot()

      // 先取消旧的提醒（如果存在）
      await this.cancelReminderNotifications(reminder.id)

      // 解析日期和时间
      const dateParts = reminder.date.split('-').map(Number)
      const timeParts = reminder.time.split(':').map(Number)
      if (dateParts.length !== 3 || timeParts.length < 2) {
        console.error('[NotificationService] 日期或时间格式无效:', reminder.date, reminder.time)
        return
      }

      const reminderReq: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: dateParts[0],
          month: dateParts[1],
          day: dateParts[2],
          hour: timeParts[0],
          minute: timeParts[1],
          second: 0
        },
        title: `🐾 ${reminder.title}`,
        content: reminder.notes || '提醒时间到了，别忘了哦！',
        ringDuration: 15,
        snoozeTimes: 2,
        timeInterval: 5,
        notificationId: this.hashReminderId(reminder.id),
        slotType: REMINDER_SLOT_TYPE
      }

      // 处理重复周期
      this.applyRepeatCycle(reminderReq, reminder, dateParts, timeParts)

      // 发布提醒
      const systemReminderId: number = await reminderAgentManager.publishReminder(reminderReq)
      this.reminderIdMap.set(reminder.id, systemReminderId)
      console.info(`[NotificationService] ✅ 提醒已创建: "${reminder.title}", 时间: ${reminder.date} ${reminder.time}, systemId: ${systemReminderId}`)
    } catch (err) {
      console.error(`[NotificationService] ❌ 创建提醒失败 "${reminder.title}":`, JSON.stringify(err))
    }
  }

  private applyRepeatCycle(
    req: reminderAgentManager.ReminderRequestCalendar,
    reminder: HealthReminder,
    dateParts: number[],
    _timeParts: number[]
  ): void {
    const dayOfWeek = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]).getDay()

    switch (reminder.repeatCycle) {
      case 'daily':
        req.daysOfWeek = [0, 1, 2, 3, 4, 5, 6]
        break
      case 'weekly':
        req.daysOfWeek = [dayOfWeek]
        break
      case 'monthly':
        req.repeatMonths = [dateParts[1] - 1]
        req.repeatDays = [dateParts[2]]
        break
      case 'yearly':
        req.repeatMonths = [dateParts[1] - 1]
        req.repeatDays = [dateParts[2]]
        break
    }
  }

  async cancelReminderNotifications(reminderId: string): Promise<void> {
    const systemId = this.reminderIdMap.get(reminderId)
    if (systemId !== undefined) {
      try {
        await reminderAgentManager.cancelReminder(systemId)
        this.reminderIdMap.delete(reminderId)
        console.info(`[NotificationService] 已取消提醒: ${reminderId}`)
      } catch (err) {
        console.error(`[NotificationService] 取消提醒失败:`, JSON.stringify(err))
      }
    }
  }

  async cancelAllReminders(): Promise<void> {
    try {
      const allReminders = await reminderAgentManager.getAllValidReminders()
      for (const r of allReminders) {
        await reminderAgentManager.cancelReminder(r.reminderId)
      }
      this.reminderIdMap.clear()
      console.info('[NotificationService] 已取消所有提醒')
    } catch (err) {
      console.error(`[NotificationService] 取消所有提醒失败:`, JSON.stringify(err))
    }
  }

  async syncAllReminders(reminders: HealthReminder[]): Promise<void> {
    for (const reminder of reminders) {
      if (reminder.enabled) {
        await this.scheduleReminderNotification(reminder)
      } else {
        await this.cancelReminderNotifications(reminder.id)
      }
    }
    console.info(`[NotificationService] 已同步 ${reminders.length} 条提醒`)
  }

  /**
   * 请求通知权限
   */
  async requestNotificationPermission(): Promise<boolean> {
    try {
      await notificationManager.requestEnableNotification()
      console.info('[NotificationService] 通知权限已开启')
      return true
    } catch (err) {
      console.error('[NotificationService] 通知权限请求失败:', JSON.stringify(err))
      return false
    }
  }

  private hashReminderId(id: string): number {
    let hash = 0
    for (let i = 0; i < id.length; i++) {
      hash = ((hash << 5) - hash) + id.charCodeAt(i)
    }
    return Math.abs(hash % 65535) + 1
  }
}
