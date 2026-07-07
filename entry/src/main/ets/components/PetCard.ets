import { PetInfo } from '../model/PetInfo'
import { ImageUtil, DateUtil } from '../common/Utils'

/**
 * 宠物卡片组件
 * 展示宠物基本信息
 */
@Component
export struct PetCard {
  @Prop pet: PetInfo = new PetInfo()
  @Prop isSelected: boolean = false
  onCardClick?: () => void
  onLongPress?: () => void

  build() {
    Column() {
      Row() {
        // 头像区域
        Column() {
          if (this.pet.avatar) {
            Image(this.pet.avatar)
              .width(60)
              .height(60)
              .borderRadius(30)
              .objectFit(ImageFit.Cover)
          } else {
            Text(ImageUtil.getDefaultAvatar(this.pet.species))
              .fontSize(36)
              .width(60)
              .height(60)
              .borderRadius(30)
              .backgroundColor('#FFF3E0')
              .textAlign(TextAlign.Center)
          }
        }

        // 信息区域
        Column() {
          Text(this.pet.name || '未命名')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isSelected ? '#FF6F00' : '#212121')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(this.pet.species || '')
              .fontSize(13)
              .fontColor('#757575')
            if (this.pet.breed) {
              Text(' · ')
                .fontSize(13)
                .fontColor('#BDBDBD')
              Text(this.pet.breed)
                .fontSize(13)
                .fontColor('#757575')
            }
          }
          .margin({ top: 2 })

          if (this.pet.birthDate) {
            Text(`🎂 ${DateUtil.calculateAge(this.pet.birthDate)}`)
              .fontSize(12)
              .fontColor('#9E9E9E')
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)

        // 右侧箭头
        Image($r('sys.symbol.chevron_right'))
          .width(20)
          .height(20)
          .fillColor('#BDBDBD')
      }
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .borderRadius(12)
    .backgroundColor(this.isSelected ? '#FFF8E1' : '#FFFFFF')
    .border({
      width: this.isSelected ? 2 : 0,
      color: '#FFB300',
      style: BorderStyle.Solid
    })
    .onClick(() => {
      if (this.onCardClick) this.onCardClick()
    })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          if (this.onLongPress) this.onLongPress()
        })
    )
  }
}
