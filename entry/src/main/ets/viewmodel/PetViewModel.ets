import { PetInfo, SPECIES_OPTIONS, GENDER_OPTIONS } from '../model/PetInfo'
import { DatabaseService } from '../service/DatabaseService'
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

  private db: DatabaseService = DatabaseService.getInstance()

  /**
   * 加载所有宠物
   */
  async loadPets(): Promise<void> {
    this.isLoading = true
    try {
      this.pets = await this.db.queryAllPets()
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
   * 打开添加宠物弹窗
   */
  openAddPetDialog(): void {
    this.editingPet = new PetInfo({
      id: DateUtil.generateId(),
      species: SPECIES_OPTIONS[0],
      gender: GENDER_OPTIONS[0],
      birthDate: DateUtil.today(),
      createTime: DateUtil.today(),
      updateTime: DateUtil.today()
    })
    this.showEditDialog = true
  }

  /**
   * 打开编辑宠物弹窗
   */
  openEditPetDialog(pet: PetInfo): void {
    this.editingPet = new PetInfo({ ...pet })
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
    const isNew = !this.pets.some(p => p.id === pet.id)
    const success = isNew ? await this.db.insertPet(pet) : await this.db.updatePet(pet)
    if (success) {
      await this.loadPets()
      if (isNew && this.pets.length > 0) {
        this.selectedPetId = this.pets[0].id
      }
      this.closeEditDialog()
    }
    return success
  }

  /**
   * 删除宠物
   */
  async deletePet(petId: string): Promise<boolean> {
    const success = await this.db.deletePet(petId)
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
