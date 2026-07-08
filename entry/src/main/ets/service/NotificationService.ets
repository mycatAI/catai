import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { HealthReminder } from '../model/HealthReminder'

/**
 * 通知服务
 * 使用 reminderAgentManager 创建带铃声的定时提醒通知
 */
export class NotificationService {
  private static instance: NotificationService
  private reminderIdMap: Map<string, number> = new Map() // reminder.id -> system reminderId

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService()
    }
    return NotificationService.instance
  }

  /**
   * 为单个提醒创建定时通知（带铃声）
   */
  async scheduleReminderNotification(reminder: HealthReminder): Promise<void> {
    try {
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
          month: dateParts[1],   // 1-indexed
          day: dateParts[2],
          hour: timeParts[0],
          minute: timeParts[1],
          second: 0
        },
        title: `🐾 ${reminder.title}`,
        content: reminder.notes || '提醒时间到了，别忘了哦！',
        ringDuration: 10,        // 铃声持续10秒
        snoozeTimes: 2,          // 允许贪睡2次
        timeInterval: 5,         // 贪睡间隔5分钟
        notificationId: this.hashReminderId(reminder.id),
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
      }

      // 处理重复周期
      this.applyRepeatCycle(reminderReq, reminder, dateParts, timeParts)

      // 发布提醒
      const systemReminderId: number = await reminderAgentManager.publishReminder(reminderReq)
      this.reminderIdMap.set(reminder.id, systemReminderId)
      console.info(`[NotificationService] 提醒已创建: ${reminder.title}, 时间: ${reminder.date} ${reminder.time}, systemId: ${systemReminderId}`)
    } catch (err) {
      console.error(`[NotificationService] 创建提醒失败:`, JSON.stringify(err))
    }
  }

  /**
   * 根据重复周期配置提醒的重复规则
   */
  private applyRepeatCycle(
    req: reminderAgentManager.ReminderRequestCalendar,
    reminder: HealthReminder,
    dateParts: number[],
    timeParts: number[]
  ): void {
    const dayOfWeek = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]).getDay() // 0=周日

    switch (reminder.repeatCycle) {
      case 'daily':
        // 每天重复
        req.daysOfWeek = [0, 1, 2, 3, 4, 5, 6]
        break
      case 'weekly':
        // 每周同一天
        req.daysOfWeek = [dayOfWeek]
        break
      case 'monthly':
        // 每月同一天
        req.repeatMonths = [dateParts[1] - 1] // 0-indexed
        req.repeatDays = [dateParts[2]]
        break
      case 'yearly':
        // 每年同一个月和日期（不设置 daysOfWeek，按月+日重复）
        req.repeatMonths = [dateParts[1] - 1]
        req.repeatDays = [dateParts[2]]
        break
      case 'none':
      default:
        // 不重复，保持为空即可
        break
    }
  }

  /**
   * 取消某个提醒的所有通知
   */
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

  /**
   * 取消所有提醒
   */
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

  /**
   * 同步所有启用的提醒
   */
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
      return true
    } catch (err) {
      console.error('[NotificationService] 请求通知权限失败:', JSON.stringify(err))
      return false
    }
  }

  /**
   * 生成稳定的数字ID（用于 notificationId）
   */
  private hashReminderId(id: string): number {
    let hash = 0
    for (let i = 0; i < id.length; i++) {
      const char = id.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash // Convert to 32bit integer
    }
    return Math.abs(hash % 65535) + 1 // 1-65535
  }
}
