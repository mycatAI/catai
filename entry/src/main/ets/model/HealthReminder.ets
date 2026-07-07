/**
 * 健康提醒数据模型
 */
export class HealthReminder {
  /** 提醒唯一ID */
  id: string = ''
  /** 关联宠物ID */
  petId: string = ''
  /** 提醒类型 */
  type: ReminderType = ReminderType.VACCINE
  /** 提醒标题 */
  title: string = ''
  /** 提醒日期 */
  date: string = ''
  /** 提醒时间（HH:mm） */
  time: string = '09:00'
  /** 重复周期 */
  repeatCycle: RepeatCycle = RepeatCycle.NONE
  /** 是否启用 */
  enabled: boolean = true
  /** 备注 */
  notes: string = ''
  /** 创建时间 */
  createTime: string = ''

  constructor(data?: Partial<HealthReminder>) {
    if (data) {
      Object.assign(this, data)
    }
  }
}

/**
 * 提醒类型枚举
 */
export enum ReminderType {
  /** 疫苗 */
  VACCINE = 'vaccine',
  /** 驱虫 */
  DEWORM = 'deworm',
  /** 体检 */
  CHECKUP = 'checkup',
  /** 美容 */
  GROOMING = 'grooming',
  /** 洗澡 */
  BATH = 'bath',
  /** 剪指甲 */
  NAIL_TRIM = 'nail_trim',
  /** 喂药 */
  MEDICATION = 'medication',
  /** 自定义 */
  CUSTOM = 'custom'
}

/** 提醒类型中文映射 */
export const REMINDER_TYPE_LABELS: Record<string, string> = {
  'vaccine': '疫苗接种',
  'deworm': '驱虫',
  'checkup': '体检',
  'grooming': '美容',
  'bath': '洗澡',
  'nail_trim': '剪指甲',
  'medication': '喂药',
  'custom': '自定义'
}

/** 提醒类型图标 */
export const REMINDER_TYPE_ICONS: Record<string, string> = {
  'vaccine': '💉',
  'deworm': '🐛',
  'checkup': '🏥',
  'grooming': '✂️',
  'bath': '🛁',
  'nail_trim': '💅',
  'medication': '💊',
  'custom': '📌'
}

/**
 * 重复周期枚举
 */
export enum RepeatCycle {
  NONE = 'none',
  DAILY = 'daily',
  WEEKLY = 'weekly',
  BIWEEKLY = 'biweekly',
  MONTHLY = 'monthly',
  QUARTERLY = 'quarterly',
  HALF_YEARLY = 'half_yearly',
  YEARLY = 'yearly'
}

/** 重复周期中文映射 */
export const REPEAT_CYCLE_LABELS: Record<string, string> = {
  'none': '不重复',
  'daily': '每天',
  'weekly': '每周',
  'biweekly': '每两周',
  'monthly': '每月',
  'quarterly': '每季度',
  'half_yearly': '每半年',
  'yearly': '每年'
}
