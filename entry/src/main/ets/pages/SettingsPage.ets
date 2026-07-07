import { router } from '@kit.ArkUI'

/**
 * 设置页面
 */
@Entry
@Component
struct SettingsPage {
  @State appVersion: string = '1.0.0'
  @State dataCount: string = '0条记录'

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

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Divider().height(1).color('#F5F5F5')

      Scroll() {
        Column() {
          // 数据管理
          this.buildSection('数据管理', () => {
            this.buildItem('📦 查看宠物档案', '管理所有宠物信息', () => {
              router.pushUrl({ url: 'pages/PetProfilePage' })
            })
            this.buildItem('📊 数据统计', this.dataCount, () => {})
            this.buildItem('☁️ 云同步', '备份数据到云端', () => {})
          })

          // 通知设置
          this.buildSection('通知设置', () => {
            this.buildItem('🔔 提醒通知', '已开启', () => {})
            this.buildItem('⏰ 默认提醒时间', '09:00', () => {})
            this.buildItem('📱 通知方式', '系统通知', () => {})
          })

          // 显示设置
          this.buildSection('显示设置', () => {
            this.buildItem('🎨 主题模式', '跟随系统', () => {})
            this.buildItem('📏 体重单位', 'kg', () => {})
            this.buildItem('📐 身高单位', 'cm', () => {})
          })

          // 关于
          this.buildSection('关于', () => {
            this.buildItem('ℹ️ 应用版本', `v${this.appVersion}`, () => {})
            this.buildItem('📄 用户协议', '', () => {})
            this.buildItem('🔒 隐私政策', '', () => {})
            this.buildItem('⭐ 给我们评分', '', () => {})
          })
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
  private buildSection(title: string, contentBuilder: () => void): void {
    Column() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#9E9E9E')
        .margin({ top: 20, bottom: 8, left: 4 })
        .width('100%')

      Column() {
        contentBuilder()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
  }

  @Builder
  private buildItem(title: string, subtitle: string, onClick: () => void): void {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#424242')
        .layoutWeight(1)

      Text(subtitle)
        .fontSize(13)
        .fontColor('#BDBDBD')
        .margin({ right: 8 })

      Image($r('sys.symbol.chevron_right'))
        .width(16)
        .height(16)
        .fillColor('#BDBDBD')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(onClick)
  }
}
