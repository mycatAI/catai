import { UserInfo } from '../model/UserInfo'
import { PetInfo } from '../model/PetInfo'
import { DatabaseService } from '../service/DatabaseService'
import { DateUtil } from '../common/Utils'
import { router } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

/**
 * 我的页面
 * 展示用户个人信息和宠物简介
 */
@Entry
@Component
struct MyPage {
  @State user: UserInfo = new UserInfo()
  @State pets: PetInfo[] = []
  @State isEditing: boolean = false
  @State editUsername: string = ''
  @State editBio: string = ''
  @State editPhone: string = ''
  @State editEmail: string = ''
  @State editAvatar: string = ''
  @State isNewUser: boolean = false

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    const db = DatabaseService.getInstance()
    // 加载用户信息
    let user = await db.queryUserInfo('default_user')
    if (!user) {
      // 首次使用，创建默认用户
      user = new UserInfo()
      user.id = 'default_user'
      user.username = '宠物家长'
      user.joinDate = DateUtil.today()
      user.updateTime = DateUtil.today()
      await db.insertUserInfo(user)
      this.isNewUser = true
    }
    this.user = user

    // 加载宠物列表
    this.pets = await db.queryAllPets()
  }

  // 开始编辑个人信息
  startEdit(): void {
    this.editUsername = this.user.username
    this.editBio = this.user.bio
    this.editPhone = this.user.phone
    this.editEmail = this.user.email
    this.editAvatar = this.user.avatar
    this.isEditing = true
  }

  // 保存用户信息
  async saveUserInfo(): Promise<void> {
    const db = DatabaseService.getInstance()
    this.user.username = this.editUsername
    this.user.bio = this.editBio
    this.user.phone = this.editPhone
    this.user.email = this.editEmail
    this.user.avatar = this.editAvatar
    this.user.updateTime = DateUtil.today()
    await db.updateUserInfo(this.user)
    this.isEditing = false
  }

  // 选择头像
  async selectAvatar(): Promise<void> {
    try {
      const context = getContext(this)
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)
      if (result && result.photoUris && result.photoUris.length > 0) {
        this.editAvatar = result.photoUris[0]
      }
    } catch (err) {
      console.error('[MyPage] 选择头像失败:', JSON.stringify(err))
    }
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

        Text('我的')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
          .margin({ left: 8 })

        Blank()

        if (!this.isEditing) {
          Button('编辑')
            .fontSize(14)
            .fontColor('#FF6F00')
            .backgroundColor('#FFF8E1')
            .borderRadius(16)
            .padding({ left: 12, right: 12 })
            .onClick(() => { this.startEdit() })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Divider().height(1).color('#F5F5F5')

      Scroll() {
        Column() {
          // 用户信息卡片
          this.buildUserCard()

          // 编辑弹窗
          if (this.isEditing) {
            this.buildEditDialog()
          }

          // 我的宠物
          this.buildMyPetsSection()

          // 其他入口
          this.buildOtherLinks()
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  private buildUserCard(): void {
    Column() {
      // 头像和基本信息
      Row() {
        // 头像
        if (this.user.avatar) {
          Image(this.user.avatar)
            .width(72)
            .height(72)
            .borderRadius(36)
            .objectFit(ImageFit.Cover)
        } else {
          Column() {
            Text('🐾')
              .fontSize(40)
          }
          .width(72)
          .height(72)
          .borderRadius(36)
          .backgroundColor('#FFF3E0')
          .justifyContent(FlexAlign.Center)
        }

        // 用户名和签名
        Column() {
          Text(this.user.username || '宠物家长')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#212121')

          if (this.user.bio) {
            Text(this.user.bio)
              .fontSize(13)
              .fontColor('#9E9E9E')
              .margin({ top: 4 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else {
            Text('还没有个性签名，点击编辑添加吧~')
              .fontSize(13)
              .fontColor('#BDBDBD')
              .margin({ top: 4 })
          }

          Text('📅 ' + (this.user.joinDate || '未知') + ' 加入')
            .fontSize(12)
            .fontColor('#BDBDBD')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .margin({ left: 14 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 统计信息
      Row() {
        Column() {
          Text(String(this.pets.length))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6F00')
          Text('宠物')
            .fontSize(12)
            .fontColor('#9E9E9E')
        }
        .layoutWeight(1)

        Column() {
          Text(this.getTotalRecords() + '条')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6F00')
          Text('记录')
            .fontSize(12)
            .fontColor('#9E9E9E')
        }
        .layoutWeight(1)

        Column() {
          Text(this.getPetTypes())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6F00')
          Text('物种')
            .fontSize(12)
            .fontColor('#9E9E9E')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 20 })
      .padding({ top: 14, bottom: 14 })
      .backgroundColor('#FFF8E1')
      .borderRadius(10)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  private buildMyPetsSection(): void {
    Column() {
      Row() {
        Text('🐾 我的宠物')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#424242')
        Blank()
        Text('管理 >')
          .fontSize(13)
          .fontColor('#FF6F00')
          .onClick(() => {
            router.pushUrl({ url: 'pages/PetProfilePage' })
          })
      }
      .width('100%')
      .margin({ top: 24, bottom: 12 })

      if (this.pets.length === 0) {
        Row() {
          Text('🐾')
            .fontSize(20)
          Text('还没有添加宠物')
            .fontSize(14)
            .fontColor('#BDBDBD')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          ForEach(this.pets, (pet: PetInfo) => {
            Row() {
              // 宠物头像
              if (pet.avatar) {
                Image(pet.avatar)
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .objectFit(ImageFit.Cover)
              } else {
                Text(pet.species === '狗狗' ? '🐶' :
                  pet.species === '猫咪' ? '🐱' : '🐾')
                  .fontSize(28)
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .backgroundColor('#FFF3E0')
                  .textAlign(TextAlign.Center)
              }

              Column() {
                Text(pet.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#424242')
                Row() {
                  Text(pet.species)
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                  if (pet.breed) {
                    Text(' · ' + pet.breed)
                      .fontSize(12)
                      .fontColor('#9E9E9E')
                  }
                  if (pet.birthDate) {
                    Text(' · ' + DateUtil.calculateAge(pet.birthDate))
                      .fontSize(12)
                      .fontColor('#9E9E9E')
                  }
                }
                .margin({ top: 2 })
              }
              .layoutWeight(1)
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)

              Image($r('sys.symbol.chevron_right'))
                .width(16)
                .height(16)
                .fillColor('#BDBDBD')
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 8 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/PetProfilePage', params: { petId: pet.id } })
            })
          })
        }
      }
    }
  }

  @Builder
  private buildOtherLinks(): void {
    Column() {
      Text('⚙️ 其他')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#424242')
        .width('100%')
        .margin({ top: 24, bottom: 12 })

      Column() {
        Row() {
          Text('⚙️')
            .fontSize(18)
          Text('设置')
            .fontSize(15)
            .fontColor('#424242')
            .margin({ left: 10 })
          Blank()
          Image($r('sys.symbol.chevron_right'))
            .width(16)
            .height(16)
            .fillColor('#BDBDBD')
        }
        .width('100%')
        .padding(14)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' })
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
  }

  @Builder
  private buildEditDialog(): void {
    Column() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => { this.isEditing = false })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column() {
      Text('编辑个人信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 20 })

      Scroll() {
        Column() {
          // 头像
          Column() {
            Text('头像')
              .fontSize(13)
              .fontColor('#757575')
              .margin({ bottom: 6 })
              .width('100%')
            Row() {
              if (this.editAvatar) {
                Image(this.editAvatar)
                  .width(64)
                  .height(64)
                  .borderRadius(32)
                  .objectFit(ImageFit.Cover)
              } else {
                Text('🐾')
                  .fontSize(36)
                  .width(64)
                  .height(64)
                  .borderRadius(32)
                  .backgroundColor('#FFF3E0')
                  .textAlign(TextAlign.Center)
              }
              Button('更换头像')
                .fontSize(13)
                .fontColor('#FF6F00')
                .backgroundColor('#FFF8E1')
                .borderRadius(14)
                .height(30)
                .margin({ left: 12 })
                .onClick(() => { this.selectAvatar() })
            }
          }
          .width('100%')
          .margin({ bottom: 14 })

          // 用户名
          this.buildLabel('用户名')
          TextInput({ text: this.editUsername, placeholder: '请输入用户名' })
            .fontSize(14)
            .width('100%')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 14 })
            .onChange((v: string) => { this.editUsername = v })

          // 个性签名
          this.buildLabel('个性签名')
          TextArea({ text: this.editBio, placeholder: '写一句签名吧...' })
            .fontSize(14)
            .height(60)
            .width('100%')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 14 })
            .onChange((v: string) => { this.editBio = v })

          // 手机号
          this.buildLabel('手机号')
          TextInput({ text: this.editPhone, placeholder: '请输入手机号' })
            .fontSize(14)
            .width('100%')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 14 })
            .onChange((v: string) => { this.editPhone = v })

          // 邮箱
          this.buildLabel('邮箱')
          TextInput({ text: this.editEmail, placeholder: '请输入邮箱' })
            .fontSize(14)
            .width('100%')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 14 })
            .onChange((v: string) => { this.editEmail = v })
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
          .onClick(() => { this.isEditing = false })

        Button('保存')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FF6F00')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick(() => { this.saveUserInfo() })
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
  private buildLabel(text: string): void {
    Text(text)
      .fontSize(13)
      .fontColor('#757575')
      .margin({ bottom: 4 })
      .width('100%')
  }

  // 辅助方法
  private getTotalRecords(): string {
    // 简单统计：返回宠物数量相关
    return String(this.pets.length)
  }

  private getPetTypes(): string {
    const types = new Set<string>()
    for (const pet of this.pets) {
      types.add(pet.species)
    }
    return String(types.size)
  }
}
