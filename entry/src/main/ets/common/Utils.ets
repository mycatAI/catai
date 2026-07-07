/**
 * 日期工具类
 */
export class DateUtil {
  /**
   * 获取当前日期字符串 YYYY-MM-DD
   */
  static today(): string {
    const now = new Date()
    return this.formatDate(now)
  }

  /**
   * 获取当前时间字符串 HH:mm
   */
  static nowTime(): string {
    const now = new Date()
    const h = String(now.getHours()).padStart(2, '0')
    const m = String(now.getMinutes()).padStart(2, '0')
    return `${h}:${m}`
  }

  /**
   * 格式化日期为 YYYY-MM-DD
   */
  static formatDate(date: Date): string {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, '0')
    const d = String(date.getDate()).padStart(2, '0')
    return `${y}-${m}-${d}`
  }

  /**
   * 格式化日期为中文显示 2024年1月15日
   */
  static formatDateCN(dateStr: string): string {
    const parts = dateStr.split('-')
    if (parts.length !== 3) return dateStr
    return `${parts[0]}年${parseInt(parts[1])}月${parseInt(parts[2])}日`
  }

  /**
   * 计算年龄（从出生日期到现在）
   */
  static calculateAge(birthDateStr: string): string {
    const birth = new Date(birthDateStr)
    const now = new Date()
    const diffMs = now.getTime() - birth.getTime()
    const days = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    if (days < 30) return `${days}天`
    const months = Math.floor(days / 30)
    if (months < 12) return `${months}个月`
    const years = Math.floor(months / 12)
    const remainMonths = months % 12
    if (remainMonths === 0) return `${years}岁`
    return `${years}岁${remainMonths}个月`
  }

  /**
   * 生成唯一ID
   */
  static generateId(): string {
    return `${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  /**
   * 比较两个日期
   * @returns 0=相等, 1=date1>date2, -1=date1<date2
   */
  static compareDate(date1: string, date2: string): number {
    if (date1 === date2) return 0
    return date1 > date2 ? 1 : -1
  }

  /**
   * 获取月份中的日期数
   */
  static daysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate()
  }

  /**
   * 获取两个日期之间的天数
   */
  static daysBetween(date1: string, date2: string): number {
    const d1 = new Date(date1).getTime()
    const d2 = new Date(date2).getTime()
    return Math.abs(Math.floor((d2 - d1) / (1000 * 60 * 60 * 24)))
  }

  /**
   * 日期增加天数
   */
  static addDays(dateStr: string, days: number): string {
    const date = new Date(dateStr)
    date.setDate(date.getDate() + days)
    return this.formatDate(date)
  }

  /**
   * 日期增加月数
   */
  static addMonths(dateStr: string, months: number): string {
    const date = new Date(dateStr)
    date.setMonth(date.getMonth() + months)
    return this.formatDate(date)
  }

  /**
   * 日期增加年数
   */
  static addYears(dateStr: string, years: number): string {
    const date = new Date(dateStr)
    date.setFullYear(date.getFullYear() + years)
    return this.formatDate(date)
  }
}

/**
 * 图片工具类
 */
export class ImageUtil {
  /**
   * 获取默认头像
   */
  static getDefaultAvatar(species: string): string {
    const avatarMap: Record<string, string> = {
      '狗狗': '🐶',
      '猫咪': '🐱',
      '兔子': '🐰',
      '仓鼠': '🐹',
      '乌龟': '🐢',
      '鹦鹉': '🦜',
      '其他': '🐾'
    }
    return avatarMap[species] || '🐾'
  }

  /**
   * 获取物种图标
   */
  static getSpeciesIcon(species: string): string {
    return this.getDefaultAvatar(species)
  }
}
