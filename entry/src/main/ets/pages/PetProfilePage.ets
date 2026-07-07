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

  aboutToAppear(): void {
    this.viewModel.loadPets()
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
          .onClick(() => { this.viewModel.openAddPetDialog() })
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
          .onClick(() => { this.viewModel.openEditPetDialog(pet) })

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
      Text(this.viewModel.editingPet.name ? '编辑宠物' : '添加宠物')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 20 })

      Scroll() {
        Column() {
          // 名称
          this.buildFieldRow('名称', () => {
            TextInput({ text: this.viewModel.editingPet.name, placeholder: '请输入宠物名称' })
              .fontSize(14)
              .layoutWeight(1)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.viewModel.editingPet.name = v })
          })

          // 物种
          this.buildFieldRow('物种', () => {
            this.buildChipSelector(SPECIES_OPTIONS,
              (v: string) => { this.viewModel.editingPet.species = v })
          })

          // 品种
          this.buildFieldRow('品种', () => {
            TextInput({ text: this.viewModel.editingPet.breed, placeholder: '请输入品种' })
              .fontSize(14)
              .layoutWeight(1)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.viewModel.editingPet.breed = v })
          })

          // 性别
          this.buildFieldRow('性别', () => {
            this.buildChipSelector(GENDER_OPTIONS,
              (v: string) => { this.viewModel.editingPet.gender = v })
          })

          // 出生日期
          this.buildFieldRow('生日', () => {
            TextInput({ text: this.viewModel.editingPet.birthDate, placeholder: 'YYYY-MM-DD' })
              .fontSize(14)
              .layoutWeight(1)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.viewModel.editingPet.birthDate = v })
          })

          // 颜色
          this.buildFieldRow('颜色', () => {
            TextInput({ text: this.viewModel.editingPet.color, placeholder: '毛色/颜色' })
              .fontSize(14)
              .layoutWeight(1)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.viewModel.editingPet.color = v })
          })

          // 备注
          this.buildFieldRow('备注', () => {
            TextArea({ text: this.viewModel.editingPet.notes, placeholder: '备注信息...' })
              .fontSize(14)
              .height(70)
              .layoutWeight(1)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onChange((v: string) => { this.viewModel.editingPet.notes = v })
          })
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
          .onClick(() => { this.viewModel.savePet() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('90%')
    .maxHeight('80%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .position({ x: '5%', y: '10%' })
  }

  @Builder
  private buildFieldRow(label: string, contentBuilder: () => void): void {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor('#757575')
        .margin({ bottom: 4 })
        .width('100%')
      contentBuilder()
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  private buildChipSelector(options: string[], onSelect: (v: string) => void): void {
    Row() {
      ForEach(options, (opt: string) => {
        Text(opt)
          .fontSize(12)
          .fontColor(this.isSelected(opt) ? '#FF6F00' : '#757575')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(this.isSelected(opt) ? '#FFF8E1' : '#FAFAFA')
          .borderRadius(12)
          .border({
            width: this.isSelected(opt) ? 1 : 0,
            color: '#FFB300'
          })
          .margin({ right: 6 })
          .onClick(() => { onSelect(opt) })
      })
    }
    .width('100%')
  }

  private isSelected(opt: string): boolean {
    if (SPECIES_OPTIONS.indexOf(opt) >= 0) {
      return this.viewModel.editingPet.species === opt
    }
    if (GENDER_OPTIONS.indexOf(opt) >= 0) {
      return this.viewModel.editingPet.gender === opt
    }
    return false
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
        .onClick(() => { this.viewModel.openAddPetDialog() })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
