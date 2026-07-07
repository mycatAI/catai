import { notificationManager } from '@kit.NotificationKit'
import { HealthReminder } from '../model/HealthReminder'
import { DatabaseService } from './DatabaseService'

/**
 * 通知服务
 * 负责创建和管理健康提醒通知
 */
export class NotificationService {
  private static instance: NotificationService
  private requestIdCounter: number = 1000

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService()
    }
    return NotificationService.instance
  }

  /**
   * 为单个提醒创建通知
   */
  async scheduleReminderNotification(reminder: HealthReminder): Promise<void> {
    try {
      const request: notificationManager.NotificationRequest = {
        id: this.requestIdCounter++,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: `🐾 ${reminder.title}`,
            text: reminder.notes || `提醒时间到了，别忘了哦！`
          }
        },
        // 使用提醒服务的定时能力
        deliveryTime: this.parseDeliveryTime(reminder.date, reminder.time),
        showDeliveryTime: true,
        isFloatingIcon: true
      }

      // 如果有重复周期，设置循环提醒
      if (reminder.repeatCycle !== 'none') {
        request.slotType = notificationManager.SlotType.SOCIAL_COMMUNICATION
        // 设置通知的重复间隔
        request.notificationSlotType = notificationManager.SlotType.SOCIAL_COMMUNICATION
      }

      await notificationManager.publish(request)
      console.info(`[NotificationService] 通知已创建: ${reminder.title}`)
    } catch (err) {
      console.error(`[NotificationService] 创建通知失败:`, JSON.stringify(err))
    }
  }

  /**
   * 批量同步所有启用的提醒通知
   */
  async syncAllReminders(): Promise<void> {
    const db = DatabaseService.getInstance()
    const reminders = await db.queryAllEnabledReminders()
    for (const reminder of reminders) {
      await this.scheduleReminderNotification(reminder)
    }
    console.info(`[NotificationService] 已同步 ${reminders.length} 条提醒通知`)
  }

  /**
   * 取消某个提醒的所有通知
   */
  async cancelReminderNotifications(reminderId: string): Promise<void> {
    try {
      await notificationManager.cancelAll()
      // 重新同步其他提醒
      await this.syncAllReminders()
      console.info(`[NotificationService] 已取消提醒通知: ${reminderId}`)
    } catch (err) {
      console.error(`[NotificationService] 取消通知失败:`, JSON.stringify(err))
    }
  }

  /**
   * 请求通知权限
   */
  async requestPermission(): Promise<boolean> {
    try {
      const result = await notificationManager.requestEnableNotification()
      return result
    } catch (err) {
      console.error('[NotificationService] 请求通知权限失败:', JSON.stringify(err))
      return false
    }
  }

  /**
   * 解析日期和时间，返回时间戳（毫秒）
   */
  private parseDeliveryTime(date: string, time: string): number {
    const dateTimeStr = `${date}T${time}:00`
    const timestamp = Date.parse(dateTimeStr)
    // 如果时间已过，设为明天
    if (timestamp <= Date.now()) {
      return timestamp + 24 * 60 * 60 * 1000
    }
    return timestamp
  }
}
