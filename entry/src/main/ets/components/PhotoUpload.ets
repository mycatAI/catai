/**
 * 照片上传组件
 * 支持选择照片并预览
 */
@Component
export struct PhotoUpload {
  @Prop photos: string[] = []
  @Prop maxCount: number = 9
  @Prop editable: boolean = true
  onPhotosChange?: (photos: string[]) => void

  build() {
    Column() {
      Row() {
        Text('📸 宠物相册')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#424242')
        Blank()
        Text(`${this.photos.length}/${this.maxCount}`)
          .fontSize(12)
          .fontColor('#BDBDBD')
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 照片网格
      Grid() {
        ForEach(this.photos, (photo: string, index: number) => {
          GridItem() {
            Stack() {
              Image(photo)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(8)

              if (this.editable) {
                // 删除按钮
                Button() {
                  Text('✕')
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                }
                .width(22)
                .height(22)
                .borderRadius(11)
                .backgroundColor('#FF5252')
                .position({ x: '100%', y: 0 })
                .translate({ x: -8, y: 8 })
                .onClick(() => {
                  const newPhotos = [...this.photos]
                  newPhotos.splice(index, 1)
                  if (this.onPhotosChange) {
                    this.onPhotosChange(newPhotos)
                  }
                })
              }
            }
          }
          .borderRadius(8)
        })

        // 添加按钮
        if (this.editable && this.photos.length < this.maxCount) {
          GridItem() {
            Column() {
              Text('+')
                .fontSize(32)
                .fontColor('#BDBDBD')
              Text('添加照片')
                .fontSize(11)
                .fontColor('#BDBDBD')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .border({ width: 1, color: '#E0E0E0', style: BorderStyle.Dashed })
            .borderRadius(8)
            .backgroundColor('#FAFAFA')
            .onClick(() => {
              this.selectPhoto()
            })
          }
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .height(this.calculateGridHeight())
    }
    .width('100%')
  }

  private calculateGridHeight(): number {
    const rowCount = Math.ceil((this.photos.length + (this.editable ? 1 : 0)) / 3)
    const itemSize = 100 // approximate item height
    const gap = 8 * (rowCount - 1)
    return rowCount * itemSize + gap
  }

  private async selectPhoto(): Promise<void> {
    try {
      // 使用 photoAccessHelper 选择照片
      const photoAccessHelper = require('@kit.MediaLibraryKit').photoAccessHelper
      const context = getContext(this)
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = this.maxCount - this.photos.length

      const uris: string[] = await phAccessHelper.PhotoViewPicker.select(photoSelectOptions)
      if (uris && uris.length > 0) {
        const newPhotos = [...this.photos, ...uris]
        if (this.onPhotosChange) {
          this.onPhotosChange(newPhotos)
        }
      }
    } catch (err) {
      console.error('[PhotoUpload] 选择照片失败:', JSON.stringify(err))
    }
  }
}
