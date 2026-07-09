import { UserInfo, CURRENT_USER_KEY, TOKEN_KEY } from '../model/UserInfo'
import { PetInfo } from '../model/PetInfo'
import { ApiService, UserProfileBody } from '../service/ApiService'
import { DateUtil } from '../common/Utils'
import { router } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

/** 宠物关注话题 */
interface PetTopic {
  id: string
  icon: string
  name: string
}
const PET_TOPICS: PetTopic[] = [
  { id: 'get_along', icon: '🤝', name: '如何相处' },
  { id: 'diet', icon: '🍖', name: '饮食健康' },
  { id: 'train', icon: '🎾', name: '训练技巧' },
  { id: 'medical', icon: '🏥', name: '医疗护理' },
  { id: 'groom', icon: '✂️', name: '美容清洁' },
  { id: 'behavior', icon: '🐕', name: '行为解读' },
  { id: 'travel', icon: '🚗', name: '出行攻略' },
  { id: 'breed', icon: '📚', name: '品种知识' },
  { id: 'play', icon: '🎮', name: '互动游戏' },
  { id: 'emotion', icon: '💕', name: '情感陪伴' }
]

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
  @State editTopics: string[] = []
  @State isNewUser: boolean = false

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    const api = ApiService.getInstance()
    // 检查登录状态
    if (!api.isLoggedIn()) {
      // 未登录，显示空用户
      this.user = new UserInfo()
      this.user.username = '未登录'
      this.user.bio = '点击下方登录，关联你的宠物'
      this.pets = []
      return
    }

    // 从后端加载用户信息
    const user = await api.getUserProfile()
    if (user) {
      this.user = user
    } else {
      this.user = new UserInfo()
      this.user.username = '宠物家长'
      this.user.joinDate = DateUtil.today()
      this.user.updateTime = DateUtil.today()
    }

    // 从后端加载宠物列表（按当前用户过滤）
    this.pets = await api.getPets()
  }

  // 开始编辑个人信息
  startEdit(): void {
    this.editUsername = this.user.username
    this.editBio = this.user.bio
    this.editPhone = this.user.phone
    this.editEmail = this.user.email
    this.editAvatar = this.user.avatar
    this.editTopics = this.user.topics ? this.user.topics.split(',') : []
    this.isEditing = true
  }

  // 切换话题选中状态
  toggleTopic(topicId: string): void {
    const idx = this.editTopics.indexOf(topicId)
    if (idx >= 0) {
      this.editTopics.splice(idx, 1)
    } else {
      this.editTopics.push(topicId)
    }
    // 触发响应式更新
    this.editTopics = [...this.editTopics]
  }

  // 保存用户信息（通过 API 更新）
  async saveUserInfo(): Promise<void> {
    const api = ApiService.getInstance()
    this.isEditing = false
    const req = new UserProfileBody(this.editUsername, this.editBio, this.editPhone,
      this.editEmail, this.editAvatar, this.editTopics.join(','))
    const result = await api.updateUserProfile(req)
    if (result) {
      this.user = result
    } else {
      // 即使失败也更新本地显示
      const updatedUser = new UserInfo(this.user)
      updatedUser.username = this.editUsername
      updatedUser.bio = this.editBio
      updatedUser.phone = this.editPhone
      updatedUser.email = this.editEmail
      updatedUser.avatar = this.editAvatar
      updatedUser.topics = this.editTopics.join(',')
      updatedUser.updateTime = DateUtil.today()
      this.user = updatedUser
    }
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

          // 我的宠物
          this.buildMyPetsSection()

          // 其他入口
          this.buildOtherLinks()
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 编辑弹窗（固定浮层，不随内容滚动）
      if (this.isEditing) {
        this.buildEditDialog()
      }
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

      // 关注的话题
      if (this.user.topics) {
        this.buildTopicTags()
      }
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

  // 退出登录
  logout(): void {
    const api = ApiService.getInstance()
    api.clearToken()
    this.user = new UserInfo()
    router.replaceUrl({ url: 'pages/Index' })
  }

  @Builder
  private buildOtherLinks(): void {
    Column() {
      Text('账户管理')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#424242')
        .width('100%')
        .margin({ top: 24, bottom: 12 })

      // 登录/注册（未登录时显示）
      if (!this.getLoginUserId()) {
        Column() {
          Row() {
            Text('🔑')
              .fontSize(18)
            Text('登录 / 注册')
              .fontSize(15)
              .fontColor('#FF6F00')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 10 })
            Blank()
            Image($r('sys.symbol.chevron_right'))
              .width(16)
              .height(16)
              .fillColor('#FF6F00')
          }
          .width('100%')
          .padding(14)
          .onClick(() => {
            router.pushUrl({ url: 'pages/LoginPage' })
          })
        }
        .width('100%')
        .backgroundColor('#FFF8E1')
        .borderRadius(12)
        .margin({ bottom: 8 })
      }

      // 退出登录（已登录时显示）
      if (this.getLoginUserId()) {
        Column() {
          Row() {
            Text('🚪')
              .fontSize(18)
            Text('退出登录')
              .fontSize(15)
              .fontColor('#FF5252')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 10 })
            Blank()
          }
          .width('100%')
          .padding(14)
          .onClick(() => { this.logout() })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ bottom: 8 })
      }

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
  private buildTopicTags(): void {
    Column() {
      Text('🏷️ 关注话题')
        .fontSize(12)
        .fontColor('#9E9E9E')
        .width('100%')
        .margin({ top: 14, bottom: 6 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.getUserTopics(), (topic: PetTopic) => {
          Text(topic.icon + ' ' + topic.name)
            .fontSize(11)
            .fontColor('#FF6F00')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#FFF8E1')
            .borderRadius(12)
            .margin({ right: 6, bottom: 4 })
        })
      }
      .width('100%')
    }
  }

  // 解析用户话题为 PetTopic 数组
  private getUserTopics(): PetTopic[] {
    if (!this.user.topics) return []
    const ids = this.user.topics.split(',')
    const result: PetTopic[] = []
    for (const id of ids) {
      const found = PET_TOPICS.find(t => t.id === id)
      if (found) result.push(found)
    }
    return result
  }

  // 获取当前登录用户ID
  private getLoginUserId(): string {
    const api = ApiService.getInstance()
    if (api.isLoggedIn()) {
      const uid = AppStorage.get<string>(CURRENT_USER_KEY)
      return uid || ''
    }
    return ''
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

          // 关注话题
          this.buildLabel('关注话题')
          Column() {
            ForEach(PET_TOPICS, (topic: PetTopic) => {
              Row() {
                Text(topic.icon + ' ' + topic.name)
                  .fontSize(14)
                  .fontColor(this.editTopics.indexOf(topic.id) >= 0 ? '#FF6F00' : '#424242')
                Blank()
                if (this.editTopics.indexOf(topic.id) >= 0) {
                  Text('✓')
                    .fontSize(14)
                    .fontColor('#FF6F00')
                    .fontWeight(FontWeight.Bold)
                }
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(this.editTopics.indexOf(topic.id) >= 0 ? '#FFF8E1' : '#FAFAFA')
              .borderRadius(8)
              .margin({ bottom: 6 })
              .onClick(() => { this.toggleTopic(topic.id) })
            })
          }
          .margin({ bottom: 14 })
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
