import { PetInfo, SPECIES_OPTIONS, GENDER_OPTIONS } from '../model/PetInfo'
import { ApiService, PetBody } from '../service/ApiService'
import { DateUtil } from '../common/Utils'

/**
 * 宠物档案 ViewModel
 * 使用 @Observed 装饰器实现响应式数据
 */
@Observed
export class PetViewModel {
  /** 宠物列表 */
  pets: PetInfo[] = []
  /** 当前选中的宠物ID */
  selectedPetId: string = ''
  /** 是否正在加载 */
  isLoading: boolean = false
  /** 是否显示添加/编辑弹窗 */
  showEditDialog: boolean = false
  /** 编辑中的宠物信息 */
  editingPet: PetInfo = new PetInfo()

  private api: ApiService = ApiService.getInstance()

  /**
   * 加载当前用户的宠物列表
   */
  async loadPets(): Promise<void> {
    this.isLoading = true
    try {
      this.pets = await this.api.getPets()
      if (this.pets.length > 0 && !this.selectedPetId) {
        this.selectedPetId = this.pets[0].id
      }
    } finally {
      this.isLoading = false
    }
  }

  /**
   * 获取当前选中的宠物
   */
  getCurrentPet(): PetInfo | undefined {
    return this.pets.find(p => p.id === this.selectedPetId)
  }

  /**
   * 选择宠物
   */
  selectPet(petId: string): void {
    this.selectedPetId = petId
  }

  /**
   * 打开添加宠物弹窗（ID 由服务端分配）
   */
  openAddPetDialog(): void {
    const pet = new PetInfo()
    pet.id = '' // 服务端分配UUID
    pet.species = SPECIES_OPTIONS[0]
    pet.gender = GENDER_OPTIONS[0]
    pet.birthDate = DateUtil.today()
    pet.createTime = DateUtil.today()
    pet.updateTime = DateUtil.today()
    this.editingPet = pet
    this.showEditDialog = true
  }

  /**
   * 打开编辑宠物弹窗
   */
  openEditPetDialog(pet: PetInfo): void {
    const newPet = new PetInfo()
    newPet.id = pet.id
    newPet.name = pet.name
    newPet.species = pet.species
    newPet.breed = pet.breed
    newPet.birthDate = pet.birthDate
    newPet.gender = pet.gender
    newPet.avatar = pet.avatar
    newPet.weight = pet.weight
    newPet.height = pet.height
    newPet.color = pet.color
    newPet.notes = pet.notes
    newPet.createTime = pet.createTime
    newPet.updateTime = pet.updateTime
    this.editingPet = newPet
    this.showEditDialog = true
  }

  /**
   * 关闭弹窗
   */
  closeEditDialog(): void {
    this.showEditDialog = false
    this.editingPet = new PetInfo()
  }

  /**
   * 保存宠物（添加或更新）
   */
  async savePet(): Promise<boolean> {
    const pet = this.editingPet
    if (!pet.name.trim()) {
      return false
    }
    pet.updateTime = DateUtil.today()
    const isNew = !pet.id || !this.pets.some(p => p.id === pet.id)

    const req = new PetBody(pet.name, pet.species, pet.breed, pet.birthDate,
      pet.gender, pet.avatar, pet.weight, pet.height, pet.color, pet.notes)

    const result = isNew ?
      await this.api.createPet(req) :
      await this.api.updatePet(pet.id, req)

    if (result) {
      await this.loadPets()
      if (isNew && this.pets.length > 0) {
        this.selectedPetId = this.pets[0].id
      }
      this.closeEditDialog()
      return true
    }
    return false
  }

  /**
   * 删除宠物
   */
  async deletePet(petId: string): Promise<boolean> {
    const success = await this.api.deletePet(petId)
    if (success) {
      await this.loadPets()
      if (this.selectedPetId === petId) {
        this.selectedPetId = this.pets.length > 0 ? this.pets[0].id : ''
      }
    }
    return success
  }

  /**
   * 获取物种列表
   */
  getSpeciesOptions(): string[] {
    return SPECIES_OPTIONS
  }

  /**
   * 获取性别列表
   */
  getGenderOptions(): string[] {
    return GENDER_OPTIONS
  }
}
