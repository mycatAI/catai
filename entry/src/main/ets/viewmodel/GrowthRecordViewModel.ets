import { GrowthRecord, GrowthRecordType, GROWTH_TYPE_LABELS, GROWTH_TYPE_ICONS } from '../model/GrowthRecord'
import { DatabaseService } from '../service/DatabaseService'
import { DateUtil } from '../common/Utils'

/**
 * 成长记录图表数据点
 */
export interface ChartDataPoint {
  label: string
  value: number
  date: string
}

/**
 * 成长记录 ViewModel
 */
@Observed
export class GrowthRecordViewModel {
  /** 成长记录列表 */
  records: GrowthRecord[] = []
  /** 筛选类型 */
  filterType: string = 'all'
  /** 是否正在加载 */
  isLoading: boolean = false
  /** 当前操作的宠物ID */
  petId: string = ''

  private db: DatabaseService = DatabaseService.getInstance()

  /**
   * 加载成长记录
   */
  async loadRecords(petId: string): Promise<void> {
    this.petId = petId
    this.isLoading = true
    try {
      const allRecords = await this.db.queryGrowthRecordsByPetId(petId)
      if (this.filterType === 'all') {
        this.records = allRecords
      } else {
        this.records = allRecords.filter(r => r.type === this.filterType)
      }
    } finally {
      this.isLoading = false
    }
  }

  /**
   * 设置筛选类型并重新加载
   */
  async setFilterType(type: string): Promise<void> {
    this.filterType = type
    if (this.petId) {
      await this.loadRecords(this.petId)
    }
  }

  /**
   * 添加成长记录
   */
  async addRecord(record: GrowthRecord): Promise<boolean> {
    record.id = DateUtil.generateId()
    record.createTime = DateUtil.today()
    if (!record.date) {
      record.date = DateUtil.today()
    }
    const success = await this.db.insertGrowthRecord(record)
    if (success && this.petId) {
      await this.loadRecords(this.petId)
    }
    return success
  }

  /**
   * 删除成长记录
   */
  async deleteRecord(recordId: string): Promise<boolean> {
    const success = await this.db.deleteGrowthRecord(recordId)
    if (success && this.petId) {
      await this.loadRecords(this.petId)
    }
    return success
  }

  /**
   * 获取体重图表数据（按日期排序）
   */
  getWeightChartData(): ChartDataPoint[] {
    return this.records
      .filter(r => r.weight > 0)
      .sort((a, b) => DateUtil.compareDate(a.date, b.date))
      .map(r => ({
        label: r.date.substring(5), // MM-DD
        value: r.weight,
        date: r.date
      }))
  }

  /**
   * 获取身高图表数据（按日期排序）
   */
  getHeightChartData(): ChartDataPoint[] {
    return this.records
      .filter(r => r.height > 0)
      .sort((a, b) => DateUtil.compareDate(a.date, b.date))
      .map(r => ({
        label: r.date.substring(5),
        value: r.height,
        date: r.date
      }))
  }

  /**
   * 获取包含照片的记录（用于时间轴）
   */
  getPhotoRecords(): GrowthRecord[] {
    return this.records.filter(r => r.photo && r.photo.length > 0)
  }

  /**
   * 获取记录类型标签
   */
  getTypeLabel(type: string): string {
    return GROWTH_TYPE_LABELS[type] || type
  }

  /**
   * 获取记录类型图标
   */
  getTypeIcon(type: string): string {
    return GROWTH_TYPE_ICONS[type] || '📌'
  }

  /**
   * 获取最新的体重
   */
  getLatestWeight(): number {
    const weightRecords = this.records.filter(r => r.weight > 0)
    if (weightRecords.length === 0) return 0
    weightRecords.sort((a, b) => DateUtil.compareDate(b.date, a.date))
    return weightRecords[0].weight
  }

  /**
   * 获取最新的身高
   */
  getLatestHeight(): number {
    const heightRecords = this.records.filter(r => r.height > 0)
    if (heightRecords.length === 0) return 0
    heightRecords.sort((a, b) => DateUtil.compareDate(b.date, a.date))
    return heightRecords[0].height
  }
}
