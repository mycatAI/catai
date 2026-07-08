import { PetInfo, SPECIES_OPTIONS, GENDER_OPTIONS } from '../model/PetInfo'
import { PetViewModel } from '../viewmodel/PetViewModel'
import { DateUtil } from '../common/Utils'
import { router } from '@kit.ArkUI'

/**
 * 宠物档案页面
 * 支持添加、编辑、删除宠物信息
 */
@Entry
@Component
struct PetProfilePage {
  @State viewModel: PetViewModel = new PetViewModel()
  @State showDeleteConfirm: boolean = false
  @State deleteTargetId: string = ''
  // 编辑表单状态
  @State formName: string = ''
  @State formSpecies: string = SPECIES_OPTIONS[0]
  @State formBreed: string = ''
  @State formGender: string = GENDER_OPTIONS[0]
  @State formBirthDate: string = ''
  @State formColor: string = ''
  @State formNotes: string = ''

  aboutToAppear(): void {
    this.viewModel.loadPets()
  }

  openAddDialogLocal(): void {
    this.viewModel.openAddPetDialog()
    this.formName = ''
    this.formSpecies = SPECIES_OPTIONS[0]
    this.formBreed = ''
    this.formGender = GENDER_OPTIONS[0]
    this.formBirthDate = DateUtil.today()
    this.formColor = ''
    this.formNotes = ''
  }

  openEditDialogLocal(pet: PetInfo): void {
    this.viewModel.openEditPetDialog(pet)
    this.formName = pet.name
    this.formSpecies = pet.species
    this.formBreed = pet.breed
    this.formGender = pet.gender
    this.formBirthDate = pet.birthDate
    this.formColor = pet.color
    this.formNotes = pet.notes
  }

  async savePetLocal(): Promise<void> {
    if (!this.formName.trim()) return
    const pet = this.viewModel.editingPet
    pet.name = this.formName
    pet.species = this.formSpecies
    pet.breed = this.formBreed
    pet.gender = this.formGender
    pet.birthDate = this.formBirthDate
    pet.color = this.formColor
    pet.notes = this.formNotes
    pet.updateTime = DateUtil.today()
    await this.viewModel.savePet()
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor('#424242')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => { router.back() })

        Text('宠物档案')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
          .margin({ left: 8 })

        Blank()

        Button('+ 添加')
          .fontSize(14)
          .fontColor('#FF6F00')
          .backgroundColor('#FFF8E1')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => { this.openAddDialogLocal() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Divider().height(1).color('#F5F5F5')

      if (this.viewModel.pets.length === 0) {
        this.buildEmptyState()
      } else {
        Scroll() {
          List() {
            ForEach(this.viewModel.pets, (pet: PetInfo, index: number) => {
              ListItem() {
                this.buildPetItem(pet)
              }
              .margin({ left: 16, right: 16, bottom: 10 })
            })
          }
          .padding({ top: 12, bottom: 24 })
          .listDirection(Axis.Vertical)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 编辑弹窗
      if (this.viewModel.showEditDialog) {
        this.buildEditDialog()
      }

      // 删除确认弹窗
      if (this.showDeleteConfirm) {
        this.buildDeleteConfirmDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  private buildPetItem(pet: PetInfo): void {
    Row() {
      // 头像
      Column() {
        Text(pet.species === '狗狗' ? '🐶' : pet.species === '猫咪' ? '🐱' : '🐾')
          .fontSize(36)
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor('#FFF3E0')
          .textAlign(TextAlign.Center)
      }

      // 信息
      Column() {
        Text(pet.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')

        Row() {
          Text(pet.species)
            .fontSize(12)
            .fontColor('#757575')
          if (pet.breed) {
            Text(' · ' + pet.breed)
              .fontSize(12)
              .fontColor('#757575')
          }
          if (pet.gender) {
            Text(' · ' + (pet.gender === '公' ? '♂️' : '♀️'))
              .fontSize(12)
              .fontColor(pet.gender === '公' ? '#42A5F5' : '#EC407A')
          }
        }
        .margin({ top: 2 })

        if (pet.birthDate) {
          Text(`🎂 ${pet.birthDate} (${DateUtil.calculateAge(pet.birthDate)})`)
            .fontSize(12)
            .fontColor('#9E9E9E')
            .margin({ top: 2 })
        }

        if (pet.notes) {
          Text(pet.notes)
            .fontSize(12)
            .fontColor('#BDBDBD')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      // 操作
      Column() {
        Button('编辑')
          .fontSize(12)
          .fontColor('#FF6F00')
          .backgroundColor('#FFF8E1')
          .borderRadius(12)
          .padding({ left: 10, right: 10 })
          .height(28)
          .onClick(() => { this.openEditDialogLocal(pet) })

        Button('删除')
          .fontSize(12)
          .fontColor('#FF5252')
          .backgroundColor('#FFEBEE')
          .borderRadius(12)
          .padding({ left: 10, right: 10 })
          .height(28)
          .margin({ top: 6 })
          .onClick(() => {
            this.deleteTargetId = pet.id
            this.showDeleteConfirm = true
          })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })
  }

  @Builder
  private buildEditDialog(): void {
    Column() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => { this.viewModel.closeEditDialog() })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column() {
      Text(this.formName ? '编辑宠物' : '添加宠物')
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
            TextInput({ text: this.formName, placeholder: '请输入宠物名称' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.formName = v })
          }
          .width('100%')
          .margin({ bottom: 12 })

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
                  .fontColor(this.formSpecies === opt ? '#FF6F00' : '#757575')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.formSpecies === opt ? '#FFF8E1' : '#FAFAFA')
                  .borderRadius(12)
                  .margin({ right: 6 })
                  .onClick(() => { this.formSpecies = opt })
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
            TextInput({ text: this.formBreed, placeholder: '请输入品种' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.formBreed = v })
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
                  .fontColor(this.formGender === opt ? '#FF6F00' : '#757575')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.formGender === opt ? '#FFF8E1' : '#FAFAFA')
                  .borderRadius(12)
                  .margin({ right: 6 })
                  .onClick(() => { this.formGender = opt })
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
            TextInput({ text: this.formBirthDate, placeholder: 'YYYY-MM-DD' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.formBirthDate = v })
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
            TextInput({ text: this.formColor, placeholder: '毛色/颜色' })
              .fontSize(14)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.formColor = v })
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
            TextArea({ text: this.formNotes, placeholder: '备注信息...' })
              .fontSize(14)
              .height(70)
              .width('100%')
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.formNotes = v })
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
          .onClick(() => { this.viewModel.closeEditDialog() })

        Button('保存')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FF6F00')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick(() => { this.savePetLocal() })
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

  @Builder
  private buildDeleteConfirmDialog(): void {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => { this.showDeleteConfirm = false })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column() {
      Text('确认删除')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 12 })

      Text('删除宠物将同时删除所有关联的成长记录和提醒数据，此操作不可恢复。')
        .fontSize(14)
        .fontColor('#757575')
        .textAlign(TextAlign.Center)
        .padding({ left: 20, right: 20 })
        .margin({ bottom: 20 })

      Row() {
        Button('取消')
          .fontSize(15)
          .fontColor('#757575')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onClick(() => { this.showDeleteConfirm = false })

        Button('确认删除')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FF5252')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick(() => {
            this.viewModel.deletePet(this.deleteTargetId)
            this.showDeleteConfirm = false
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('85%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .position({ x: '7.5%', y: '35%' })
  }

  @Builder
  private buildEmptyState(): void {
    Column() {
      Text('🐾')
        .fontSize(64)
        .opacity(0.3)
      Text('还没有宠物档案')
        .fontSize(15)
        .fontColor('#BDBDBD')
        .margin({ top: 12 })
      Button('添加第一只宠物')
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF6F00')
        .borderRadius(24)
        .padding({ left: 24, right: 24 })
        .margin({ top: 16 })
        .onClick(() => { this.openAddDialogLocal() })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
