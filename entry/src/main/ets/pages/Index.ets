import { PetViewModel } from '../viewmodel/PetViewModel'
import { GrowthRecordViewModel } from '../viewmodel/GrowthRecordViewModel'
import { ReminderViewModel } from '../viewmodel/ReminderViewModel'
import { HealthReminder } from '../model/HealthReminder'
import { GrowthRecord } from '../model/GrowthRecord'
import { PetInfo, SPECIES_OPTIONS, GENDER_OPTIONS } from '../model/PetInfo'
import { PetSelector } from '../components/PetSelector'
import { PetCard } from '../components/PetCard'
import { ReminderCard } from '../components/ReminderCard'
import { DateUtil } from '../common/Utils'
import { router } from '@kit.ArkUI'
import { DatabaseService } from '../service/DatabaseService'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

@Entry
@Component
struct Index {
  @State petVM: PetViewModel = new PetViewModel()
  @State growthVM: GrowthRecordViewModel = new GrowthRecordViewModel()
  @State reminderVM: ReminderViewModel = new ReminderViewModel()
  @State showPetList: boolean = false
  // 添加宠物表单状态
  @State editPetName: string = ''
  @State editPetSpecies: string = SPECIES_OPTIONS[0]
  @State editPetBreed: string = ''
  @State editPetGender: string = GENDER_OPTIONS[0]
  @State editPetBirthDate: string = ''
  @State editPetColor: string = ''
  @State editPetNotes: string = ''
  @State editPetAvatar: string = ''

  aboutToAppear(): void {
    this.initData()
  }

  // 页面每次显示时刷新数据（从其他页面返回时头像等信息的更新能反映出来）
  onPageShow(): void {
    this.refreshPetData()
  }

  async initData(): Promise<void> {
    // 初始化数据库
    const db = DatabaseService.getInstance()
    const context = getContext(this)
    await db.init(context)

    // 加载数据
    await this.petVM.loadPets()
    if (this.petVM.selectedPetId) {
      await this.growthVM.loadRecords(this.petVM.selectedPetId)
      await this.reminderVM.loadReminders(this.petVM.selectedPetId)
    }
  }

  async refreshPetData(): Promise<void> {
    // 重新从数据库加载宠物数据，确保头像等信息是最新的
    await this.petVM.loadPets()
    if (this.petVM.selectedPetId) {
      await this.growthVM.loadRecords(this.petVM.selectedPetId)
      await this.reminderVM.loadReminders(this.petVM.selectedPetId)
    }
  }

  onPetSelected(petId: string): void {
    this.petVM.selectPet(petId)
    this.growthVM.loadRecords(petId)
    this.reminderVM.loadReminders(petId)
  }

  openAddDialog(): void {
    this.petVM.openAddPetDialog()
    this.editPetName = ''
    this.editPetSpecies = SPECIES_OPTIONS[0]
    this.editPetBreed = ''
    this.editPetGender = GENDER_OPTIONS[0]
    this.editPetBirthDate = DateUtil.today()
    this.editPetColor = ''
    this.editPetNotes = ''
  }

  async saveNewPet(): Promise<void> {
    if (!this.editPetName.trim()) return
    const pet = this.petVM.editingPet
    pet.name = this.editPetName
    pet.species = this.editPetSpecies
    pet.breed = this.editPetBreed
    pet.gender = this.editPetGender
    pet.birthDate = this.editPetBirthDate
    pet.color = this.editPetColor
    pet.notes = this.editPetNotes
    pet.avatar = this.editPetAvatar
    pet.updateTime = DateUtil.today()
    await this.petVM.savePet()
  }

  async selectPetAvatar(): Promise<void> {
    try {
      const context = getContext(this)
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)
      if (result && result.photoUris && result.photoUris.length > 0) {
        this.editPetAvatar = result.photoUris[0]
      }
    } catch (err) {
      console.error('[Index] 选择头像失败:', JSON.stringify(err))
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildTopBar()

      // 宠物切换器
      PetSelector({
        pets: this.petVM.pets,
        selectedPetId: this.petVM.selectedPetId,
        onSelect: (petId: string) => { this.onPetSelected(petId) },
        onAdd: () => { this.openAddDialog() }
      })

      Divider().height(1).color('#F5F5F5')

      // 添加/编辑宠物弹窗
      if (this.petVM.showEditDialog) {
        this.buildAddPetDialog()
      }

      if (this.petVM.pets.length === 0) {
        // 空状态：没有宠物
        this.buildEmptyState()
      } else {
        // 主内容区域
        Scroll() {
          Column() {
            // 当前宠物信息卡片
            this.buildCurrentPetSection()

            // 功能快捷入口
            this.buildQuickActions()

            // 今日待办提醒
            this.buildTodayReminders()

            // 最近成长记录
            this.buildRecentRecords()
          }
          .padding({ left: 16, right: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  private buildTopBar(): void {
    Row() {
      Text('🐾 宠物成长日记')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#212121')

      Blank()

      // 宠物列表切换按钮
      Button() {
        Text('🐾')
          .fontSize(20)
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor('#FFF8E1')
      .onClick(() => {
        this.showPetList = !this.showPetList
      })

      // 设置按钮
      Button() {
        Text('⚙️')
          .fontSize(18)
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor('#F5F5F5')
      .margin({ left: 8 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/SettingsPage' })
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 8 })
  }

  @Builder
  private buildCurrentPetSection(): void {
    if (this.petVM.selectedPetId) {
      if (this.petVM.getCurrentPet()) {
        Row() {
          // 头像
          Column() {
            if (this.petVM.getCurrentPet()!.avatar) {
              Image(this.petVM.getCurrentPet()!.avatar)
                .width(64)
                .height(64)
                .borderRadius(32)
                .objectFit(ImageFit.Cover)
            } else {
              Text(this.petVM.getCurrentPet()!.species === '狗狗' ? '🐶' :
                this.petVM.getCurrentPet()!.species === '猫咪' ? '🐱' : '🐾')
                .fontSize(40)
                .width(64)
                .height(64)
                .borderRadius(32)
                .backgroundColor('#FFF3E0')
                .textAlign(TextAlign.Center)
            }
          }

          Column() {
            Text(this.petVM.getCurrentPet()!.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#212121')
            Text(this.petVM.getCurrentPet()!.species +
              (this.petVM.getCurrentPet()!.breed ? ' · ' + this.petVM.getCurrentPet()!.breed : ''))
              .fontSize(13)
              .fontColor('#757575')
              .margin({ top: 2 })
            if (this.petVM.getCurrentPet()!.birthDate) {
              Text('🎂 ' + DateUtil.calculateAge(this.petVM.getCurrentPet()!.birthDate))
                .fontSize(12)
                .fontColor('#9E9E9E')
                .margin({ top: 2 })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          .layoutWeight(1)

          // 最新数据
          Column() {
            Text(this.growthVM.getLatestWeight() + 'kg')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6F00')
            Text(this.growthVM.getLatestHeight() + 'cm')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6F00')
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/PetProfilePage',
            params: { petId: this.petVM.getCurrentPet()!.id } })
        })
      }
    }
  }

  @Builder
  private buildQuickActions(): void {
    Column() {
      Text('快捷功能')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#424242')
        .width('100%')
        .margin({ top: 20, bottom: 12 })

      Grid() {
        GridItem() {
          this.buildActionItem('📝', '成长记录', '#E3F2FD', () => {
            router.pushUrl({ url: 'pages/GrowthRecordPage', params: { petId: this.petVM.selectedPetId } })
          })
        }
        GridItem() {
          this.buildActionItem('📸', '时间轴相册', '#E8F5E9', () => {
            router.pushUrl({ url: 'pages/TimelinePage', params: { petId: this.petVM.selectedPetId } })
          })
        }
        GridItem() {
          this.buildActionItem('💉', '健康提醒', '#FCE4EC', () => {
            router.pushUrl({ url: 'pages/HealthReminderPage', params: { petId: this.petVM.selectedPetId } })
          })
        }
        GridItem() {
          this.buildActionItem('📊', '成长趋势', '#F3E5F5', () => {
            router.pushUrl({ url: 'pages/GrowthRecordPage', params: { petId: this.petVM.selectedPetId, tab: 'chart' } })
          })
        }
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .height(80)
    }
  }

  @Builder
  private buildActionItem(icon: string, label: string, bgColor: string, onClick: () => void): void {
    Column() {
      Text(icon)
        .fontSize(24)
      Text(label)
        .fontSize(11)
        .fontColor('#616161')
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bgColor)
    .borderRadius(10)
    .onClick(onClick)
  }

  @Builder
  private buildTodayReminders(): void {
    Column() {
      Row() {
        Text('📋 今日待办')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#424242')
        Blank()
        Text(this.reminderVM.getTodayReminders().length + '项')
          .fontSize(12)
          .fontColor('#FF6F00')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .backgroundColor('#FFF8E1')
          .borderRadius(10)
      }
      .width('100%')
      .margin({ top: 20, bottom: 12 })

      if (this.reminderVM.getTodayReminders().length === 0) {
        Row() {
          Text('✅')
            .fontSize(16)
          Text('今天没有待办提醒')
            .fontSize(13)
            .fontColor('#BDBDBD')
            .margin({ left: 4 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
      } else {
        Column() {
          ForEach(this.reminderVM.getTodayReminders().slice(0, 3), (reminder: HealthReminder) => {
            ReminderCard({
              reminder: reminder,
              onToggle: () => { this.reminderVM.toggleReminder(reminder) },
              onEdit: () => { this.reminderVM.openEditReminderDialog(reminder) },
              onDelete: () => { this.reminderVM.deleteReminder(reminder.id) }
            })
          })
        }
      }
    }
  }

  @Builder
  private buildRecentRecords(): void {
    Column() {
      Row() {
        Text('📝 最近记录')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#424242')
        Blank()
        Text('查看全部 >')
          .fontSize(12)
          .fontColor('#FF6F00')
          .onClick(() => {
            router.pushUrl({ url: 'pages/GrowthRecordPage', params: { petId: this.petVM.selectedPetId } })
          })
      }
      .width('100%')
      .margin({ top: 20, bottom: 12 })

      if (this.growthVM.records.length === 0) {
        Row() {
          Text('📝')
            .fontSize(16)
          Text('还没有成长记录，点击添加第一条')
            .fontSize(13)
            .fontColor('#BDBDBD')
            .margin({ left: 4 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: 'pages/GrowthRecordPage', params: { petId: this.petVM.selectedPetId } })
        })
      } else {
        Column() {
          ForEach(this.growthVM.records.slice(0, 5), (record: GrowthRecord) => {
            Row() {
              Text(this.growthVM.getTypeIcon(record.type))
                .fontSize(18)
                .width(36)
                .height(36)
                .borderRadius(18)
                .backgroundColor('#FFF3E0')
                .textAlign(TextAlign.Center)

              Column() {
                Text(this.growthVM.getTypeLabel(record.type))
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#424242')
                if (record.notes) {
                  Text(record.notes)
                    .fontSize(12)
                    .fontColor('#BDBDBD')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .layoutWeight(1)
              .margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)

              Column() {
                Text(record.date)
                  .fontSize(11)
                  .fontColor('#9E9E9E')
                if (record.weight > 0) {
                  Text(`${record.weight}kg`)
                    .fontSize(12)
                    .fontColor('#FF6F00')
                    .fontWeight(FontWeight.Medium)
                }
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 6 })
          })
        }
      }
    }
  }

  @Builder
  private buildEmptyState(): void {
    Column() {
      Text('🐾')
        .fontSize(64)
        .opacity(0.3)
      Text('还没有添加宠物')
        .fontSize(16)
        .fontColor('#BDBDBD')
        .margin({ top: 12 })
      Text('点击下方按钮添加你的第一只宠物吧')
        .fontSize(13)
        .fontColor('#E0E0E0')
        .margin({ top: 4 })

      Button('添加宠物')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF6F00')
        .borderRadius(24)
        .padding({ left: 32, right: 32 })
        .margin({ top: 20 })
        .onClick(() => {
          this.openAddDialog()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private buildAddPetDialog(): void {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => { this.petVM.closeEditDialog() })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column() {
      Text('添加宠物')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 20 })

      Scroll() {
        Column() {
          // 名称
          Column() {
            Text('名称')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            TextInput({ text: this.editPetName, placeholder: '请输入宠物名称' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.editPetName = v })
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 头像
          Column() {
            Text('头像')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            Row() {
              if (this.editPetAvatar) {
                Image(this.editPetAvatar)
                  .width(64)
                  .height(64)
                  .borderRadius(32)
                  .objectFit(ImageFit.Cover)
                Button('更换')
                  .fontSize(12)
                  .fontColor('#FF6F00')
                  .backgroundColor('#FFF8E1')
                  .borderRadius(12)
                  .height(28)
                  .margin({ left: 10 })
                  .onClick(() => { this.selectPetAvatar() })
              } else {
                Button('选择照片')
                  .fontSize(13)
                  .fontColor('#FF6F00')
                  .backgroundColor('#FFF8E1')
                  .borderRadius(8)
                  .padding({ left: 12, right: 12 })
                  .height(36)
                  .onClick(() => { this.selectPetAvatar() })
              }
            }
          }

          // 物种
          Column() {
            Text('物种')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            Row() {
              ForEach(SPECIES_OPTIONS, (opt: string) => {
                Text(opt)
                  .fontSize(12)
                  .fontColor(this.editPetSpecies === opt ? '#FF6F00' : '#757575')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.editPetSpecies === opt ? '#FFF8E1' : '#FAFAFA')
                  .borderRadius(12)
                  .margin({ right: 6 })
                  .onClick(() => { this.editPetSpecies = opt })
              })
            }
          }

          // 品种
          Column() {
            Text('品种')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            TextInput({ text: this.editPetBreed, placeholder: '请输入品种' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.editPetBreed = v })
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 性别
          Column() {
            Text('性别')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            Row() {
              ForEach(GENDER_OPTIONS, (opt: string) => {
                Text(opt)
                  .fontSize(12)
                  .fontColor(this.editPetGender === opt ? '#FF6F00' : '#757575')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.editPetGender === opt ? '#FFF8E1' : '#FAFAFA')
                  .borderRadius(12)
                  .margin({ right: 6 })
                  .onClick(() => { this.editPetGender = opt })
              })
            }
          }

          // 出生日期
          Column() {
            Text('生日')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            TextInput({ text: this.editPetBirthDate, placeholder: 'YYYY-MM-DD' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.editPetBirthDate = v })
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 颜色
          Column() {
            Text('颜色')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            TextInput({ text: this.editPetColor, placeholder: '毛色/颜色' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.editPetColor = v })
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 备注
          Column() {
            Text('备注')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 4 })
              .width('100%')
            TextArea({ text: this.editPetNotes, placeholder: '备注信息...' })
              .fontSize(14)
              .height(70)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.editPetNotes = v })
          }
          .width('100%')
          .margin({ bottom: 12 })
        }
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)

      Row() {
        Button('取消')
          .fontSize(15)
          .fontColor('#757575')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onClick(() => { this.petVM.closeEditDialog() })

        Button('保存')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FF6F00')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick(() => { this.saveNewPet() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('90%')
    .constraintSize({ maxHeight: '80%' })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .position({ x: '5%', y: '10%' })
  }
}
