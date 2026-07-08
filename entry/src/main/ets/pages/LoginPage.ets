import { UserInfo, CURRENT_USER_KEY } from '../model/UserInfo'
import { DatabaseService } from '../service/DatabaseService'
import { DateUtil } from '../common/Utils'
import { router } from '@kit.ArkUI'

/**
 * 登录/注册页面
 */
@Entry
@Component
struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State isRegister: boolean = false
  @State errorMsg: string = ''
  @State isLoading: boolean = false

  aboutToAppear(): void {
    // 如果已经登录，跳过
    const uid = AppStorage.get<string>(CURRENT_USER_KEY)
    if (uid) {
      router.back()
    }
  }

  build() {
    Column() {
      // 返回按钮
      Row() {
        Button() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor('#424242')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => { router.back() })
      }
      .width('100%')
      .padding({ left: 16, top: 12 })

      Scroll() {
        Column() {
          // 图标
          Text('🐾')
            .fontSize(72)
            .margin({ top: 40, bottom: 16 })

          Text(this.isRegister ? '注册新账号' : '欢迎回来')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#212121')
            .margin({ bottom: 8 })

          Text(this.isRegister ? '创建账号，记录宠物成长' : '登录你的宠物成长日记')
            .fontSize(14)
            .fontColor('#9E9E9E')
            .margin({ bottom: 32 })

          // 用户名
          Text('用户名')
            .fontSize(13)
            .fontColor('#757575')
            .width('100%')
            .margin({ bottom: 4 })
          TextInput({ text: this.username, placeholder: '请输入用户名' })
            .fontSize(15)
            .width('100%')
            .height(44)
            .backgroundColor('#FAFAFA')
            .borderRadius(10)
            .margin({ bottom: 16 })
            .onChange((v: string) => { this.username = v; this.errorMsg = '' })

          // 密码
          Text('密码')
            .fontSize(13)
            .fontColor('#757575')
            .width('100%')
            .margin({ bottom: 4 })
          TextInput({ text: this.password, placeholder: '请输入密码' })
            .fontSize(15)
            .width('100%')
            .height(44)
            .type(InputType.Password)
            .backgroundColor('#FAFAFA')
            .borderRadius(10)
            .margin({ bottom: 16 })
            .onChange((v: string) => { this.password = v; this.errorMsg = '' })

          // 确认密码（仅注册）
          if (this.isRegister) {
            Text('确认密码')
              .fontSize(13)
              .fontColor('#757575')
              .width('100%')
              .margin({ bottom: 4 })
            TextInput({ text: this.confirmPassword, placeholder: '请再次输入密码' })
              .fontSize(15)
              .width('100%')
              .height(44)
              .type(InputType.Password)
              .backgroundColor('#FAFAFA')
              .borderRadius(10)
              .margin({ bottom: 16 })
              .onChange((v: string) => { this.confirmPassword = v; this.errorMsg = '' })
          }

          // 错误提示
          if (this.errorMsg) {
            Text(this.errorMsg)
              .fontSize(13)
              .fontColor('#FF5252')
              .width('100%')
              .padding(10)
              .backgroundColor('#FFEBEE')
              .borderRadius(8)
              .margin({ bottom: 12 })
          }

          // 登录/注册按钮
          Button(this.isRegister ? '注 册' : '登 录')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .width('100%')
            .height(46)
            .backgroundColor('#FF6F00')
            .borderRadius(23)
            .enabled(!this.isLoading)
            .onClick(() => {
              if (this.isRegister) {
                this.doRegister()
              } else {
                this.doLogin()
              }
            })

          // 切换登录/注册
          Row() {
            Text(this.isRegister ? '已有账号？' : '没有账号？')
              .fontSize(14)
              .fontColor('#9E9E9E')
            Text(this.isRegister ? '去登录' : '去注册')
              .fontSize(14)
              .fontColor('#FF6F00')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 4 })
              .onClick(() => {
                this.isRegister = !this.isRegister
                this.errorMsg = ''
                this.password = ''
                this.confirmPassword = ''
              })
          }
          .margin({ top: 20 })
        }
        .padding({ left: 24, right: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  async doRegister(): Promise<void> {
    const name = this.username.trim()
    const pwd = this.password.trim()

    if (!name) { this.errorMsg = '请输入用户名'; return }
    if (name.length < 2) { this.errorMsg = '用户名至少2个字符'; return }
    if (!pwd) { this.errorMsg = '请输入密码'; return }
    if (pwd.length < 4) { this.errorMsg = '密码至少4个字符'; return }
    if (this.isRegister && pwd !== this.confirmPassword) { this.errorMsg = '两次密码不一致'; return }

    this.isLoading = true
    try {
      const db = DatabaseService.getInstance()
      // 检查用户名是否已存在
      const existing = await db.queryUserByUsername(name)
      if (existing) {
        this.errorMsg = '用户名已被注册'
        this.isLoading = false
        return
      }

      const user = new UserInfo()
      user.id = DateUtil.generateId()
      user.username = name
      user.password = pwd
      user.joinDate = DateUtil.today()
      user.updateTime = DateUtil.today()
      await db.insertUserInfo(user)

      // 保存登录状态
      AppStorage.setOrCreate(CURRENT_USER_KEY, user.id)

      router.back()
    } catch (err) {
      this.errorMsg = '注册失败，请重试'
      console.error('[Login] 注册失败:', JSON.stringify(err))
    }
    this.isLoading = false
  }

  async doLogin(): Promise<void> {
    const name = this.username.trim()
    const pwd = this.password.trim()

    if (!name) { this.errorMsg = '请输入用户名'; return }
    if (!pwd) { this.errorMsg = '请输入密码'; return }

    this.isLoading = true
    try {
      const db = DatabaseService.getInstance()
      const user = await db.queryUserByUsername(name)
      if (!user) {
        this.errorMsg = '用户不存在，请先注册'
        this.isLoading = false
        return
      }
      if (user.password !== pwd) {
        this.errorMsg = '密码错误'
        this.isLoading = false
        return
      }

      // 保存登录状态
      AppStorage.setOrCreate(CURRENT_USER_KEY, user.id)

      router.back()
    } catch (err) {
      this.errorMsg = '登录失败，请重试'
      console.error('[Login] 登录失败:', JSON.stringify(err))
    }
    this.isLoading = false
  }
}
