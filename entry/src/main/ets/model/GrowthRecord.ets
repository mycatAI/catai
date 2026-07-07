/**
 * 成长记录数据模型
 */
export class GrowthRecord {
  /** 记录唯一ID */
  id: string = ''
  /** 关联宠物ID */
  petId: string = ''
  /** 记录日期 */
  date: string = ''
  /** 体重(kg) */
  weight: number = 0
  /** 身高(cm) */
  height: number = 0
  /** 照片URI */
  photo: string = ''
  /** 备注 */
  notes: string = ''
  /** 记录类型 */
  type: GrowthRecordType = GrowthRecordType.WEIGHT
  /** 创建时间 */
  createTime: string = ''

  constructor(data?: Partial<GrowthRecord>) {
    if (data) {
      Object.assign(this, data)
    }
  }
}

/**
 * 成长记录类型枚举
 */
export enum GrowthRecordType {
  /** 体重 */
  WEIGHT = 'weight',
  /** 身高 */
  HEIGHT = 'height',
  /** 疫苗 */
  VACCINE = 'vaccine',
  /** 驱虫 */
  DEWORM = 'deworm',
  /** 体检 */
  CHECKUP = 'checkup',
  /** 美容 */
  GROOMING = 'grooming',
  /** 日常 */
  DAILY = 'daily',
  /** 其他 */
  OTHER = 'other'
}

/** 记录类型中文映射 */
export const GROWTH_TYPE_LABELS: Record<string, string> = {
  'weight': '体重记录',
  'height': '身高记录',
  'vaccine': '疫苗接种',
  'deworm': '驱虫记录',
  'checkup': '体检记录',
  'grooming': '美容护理',
  'daily': '日常记录',
  'other': '其他'
}

/** 记录类型图标映射 */
export const GROWTH_TYPE_ICONS: Record<string, string> = {
  'weight': '⚖️',
  'height': '📏',
  'vaccine': '💉',
  'deworm': '🐛',
  'checkup': '🏥',
  'grooming': '✂️',
  'daily': '📝',
  'other': '📌'
}
