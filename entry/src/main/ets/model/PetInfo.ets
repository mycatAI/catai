/**
 * 宠物信息数据模型
 */
export class PetInfo {
  /** 宠物唯一ID */
  id: string = ''
  /** 宠物名称 */
  name: string = ''
  /** 物种：狗/猫/其他 */
  species: string = ''
  /** 品种 */
  breed: string = ''
  /** 出生日期 */
  birthDate: string = ''
  /** 性别：公/母 */
  gender: string = ''
  /** 头像URI */
  avatar: string = ''
  /** 当前体重(kg) */
  weight: number = 0
  /** 当前身高(cm) */
  height: number = 0
  /** 颜色 */
  color: string = ''
  /** 备注 */
  notes: string = ''
  /** 创建时间 */
  createTime: string = ''
  /** 更新时间 */
  updateTime: string = ''

  constructor(data?: PetInfo) {
    if (data) {
      this.id = data.id ?? this.id
      this.name = data.name ?? this.name
      this.species = data.species ?? this.species
      this.breed = data.breed ?? this.breed
      this.birthDate = data.birthDate ?? this.birthDate
      this.gender = data.gender ?? this.gender
      this.avatar = data.avatar ?? this.avatar
      this.weight = data.weight ?? this.weight
      this.height = data.height ?? this.height
      this.color = data.color ?? this.color
      this.notes = data.notes ?? this.notes
      this.createTime = data.createTime ?? this.createTime
      this.updateTime = data.updateTime ?? this.updateTime
    }
  }
}

/** 宠物物种选项 */
export const SPECIES_OPTIONS: string[] = ['狗狗', '猫咪', '兔子', '仓鼠', '乌龟', '鹦鹉', '其他']

/** 宠物性别选项 */
export const GENDER_OPTIONS: string[] = ['公', '母']
