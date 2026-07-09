import { GrowthRecord, GrowthRecordType, GROWTH_TYPE_LABELS, GROWTH_TYPE_ICONS } from '../model/GrowthRecord'
import { ApiService, RecordBody } from '../service/ApiService'
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
 * ChartDataPoint 实现类（ArkTS 要求使用类而非对象字面量）
 */
export class ChartDataPointImpl implements ChartDataPoint {
  label: string = ''
  value: number = 0
  date: string = ''
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

  private api: ApiService = ApiService.getInstance()

  /**
   * 加载成长记录（从后端获取，支持按类型筛选）
   */
  async loadRecords(petId: string): Promise<void> {
    this.petId = petId
    this.isLoading = true
    try {
      this.records = await this.api.getRecords(petId, this.filterType)
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
   * 添加成长记录（ID 由服务端分配）
   */
  async addRecord(record: GrowthRecord): Promise<boolean> {
    record.createTime = DateUtil.today()
    if (!record.date) {
      record.date = DateUtil.today()
    }
    const req = new RecordBody(record.date, record.weight, record.height,
      record.photo, record.notes, record.type)
    const result = await this.api.createRecord(this.petId, req)
    if (result) {
      await this.loadRecords(this.petId)
      return true
    }
    return false
  }

  /**
   * 删除成长记录
   */
  async deleteRecord(recordId: string): Promise<boolean> {
    const success = await this.api.deleteRecord(recordId)
    if (success && this.petId) {
      await this.loadRecords(this.petId)
    }
    return success
  }

  /**
   * 获取体重图表数据（按日期排序）
   */
  getWeightChartData(): ChartDataPoint[] {
    const result: ChartDataPoint[] = []
    const sorted = this.records
      .filter(r => r.weight > 0)
      .sort((a, b) => DateUtil.compareDate(a.date, b.date))
    for (let i = 0; i < sorted.length; i++) {
      const r = sorted[i]
      const point = new ChartDataPointImpl()
      point.label = r.date.substring(5)
      point.value = r.weight
      point.date = r.date
      result.push(point)
    }
    return result
  }

  /**
   * 获取身高图表数据（按日期排序）
   */
  getHeightChartData(): ChartDataPoint[] {
    const result: ChartDataPoint[] = []
    const sorted = this.records
      .filter(r => r.height > 0)
      .sort((a, b) => DateUtil.compareDate(a.date, b.date))
    for (let i = 0; i < sorted.length; i++) {
      const r = sorted[i]
      const point = new ChartDataPointImpl()
      point.label = r.date.substring(5)
      point.value = r.height
      point.date = r.date
      result.push(point)
    }
    return result
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
