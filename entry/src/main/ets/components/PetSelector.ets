import { PetInfo } from '../model/PetInfo'
import { ImageUtil } from '../common/Utils'

/**
 * 宠物切换器组件
 * 横向滚动的宠物列表，用于快速切换当前宠物
 */
@Component
export struct PetSelector {
  @Prop pets: PetInfo[] = []
  @Prop selectedPetId: string = ''
  onSelect?: (petId: string) => void
  onAdd?: () => void

  build() {
    Column() {
      Scroll() {
        Row() {
          ForEach(this.pets, (pet: PetInfo, index: number) => {
            Column() {
              // 头像
              if (pet.avatar) {
                Image(pet.avatar)
                  .width(52)
                  .height(52)
                  .borderRadius(26)
                  .objectFit(ImageFit.Cover)
              } else {
                Text(ImageUtil.getDefaultAvatar(pet.species))
                  .fontSize(28)
                  .width(52)
                  .height(52)
                  .borderRadius(26)
                  .backgroundColor('#FFF3E0')
                  .textAlign(TextAlign.Center)
              }

              // 小圆点指示器
              Circle({ width: 8, height: 8 })
                .fill(this.selectedPetId === pet.id ? '#FF6F00' : '#E0E0E0')
                .margin({ top: 4 })

              // 名字
              Text(pet.name)
                .fontSize(12)
                .fontColor(this.selectedPetId === pet.id ? '#FF6F00' : '#757575')
                .fontWeight(this.selectedPetId === pet.id ? FontWeight.Bold : FontWeight.Normal)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 2 })
            }
            .width(72)
            .padding({ top: 8, bottom: 8 })
            .borderRadius(12)
            .backgroundColor(this.selectedPetId === pet.id ? '#FFF8E1' : Color.Transparent)
            .onClick(() => {
              if (this.onSelect) this.onSelect(pet.id)
            })
          })

          // 添加新宠物按钮
          Column() {
            Column() {
              Text('+')
                .fontSize(28)
                .fontColor('#BDBDBD')
            }
            .width(52)
            .height(52)
            .borderRadius(26)
            .border({ width: 2, color: '#E0E0E0', style: BorderStyle.Dashed })
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FAFAFA')

            Text('添加')
              .fontSize(12)
              .fontColor('#BDBDBD')
              .margin({ top: 4 })
          }
          .width(72)
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            if (this.onAdd) this.onAdd()
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }
}
