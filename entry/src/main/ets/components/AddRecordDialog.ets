import { GrowthRecord, GrowthRecordType, GROWTH_TYPE_LABELS, GROWTH_TYPE_ICONS } from '../model/GrowthRecord'
import { DateUtil } from '../common/Utils'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

/**
 * 添加成长记录弹窗组件
 */
@Component
export struct AddRecordDialog {
  @Prop showDialog: boolean = false
  @Prop petId: string = ''
  onConfirm?: (record: GrowthRecord) => void
  onCancel?: () => void

  @State private recordType: string = GrowthRecordType.DAILY
  @State private weight: string = ''
  @State private height: string = ''
  @State private photo: string = ''
  @State private notes: string = ''
  @State private recordDate: string = DateUtil.today()

  build() {
    if (this.showDialog) {
      Column() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#00000060')
          .onClick(() => {
            if (this.onCancel) this.onCancel()
          })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })

      // 弹窗内容
      Column() {
        // 标题栏
        Row() {
          Text('添加成长记录')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#212121')
          Blank()
          Button('取消')
            .fontSize(14)
            .fontColor('#757575')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              if (this.onCancel) this.onCancel()
            })
        }
        .width('100%')
        .padding(16)

        Divider().height(1).color('#F5F5F5')

        // 滚动内容
        Scroll() {
          Column() {
            // 记录类型选择
            this.buildTypeSelector()

            // 体重输入
            this.buildInputRow('⚖️ 体重 (kg)', '请输入体重', this.weight,
              (value: string) => { this.weight = value })

            // 身高输入
            this.buildInputRow('📏 身高 (cm)', '请输入身高', this.height,
              (value: string) => { this.height = value })

            // 照片
            this.buildPhotoRow()

            // 日期
            this.buildDateRow()

            // 备注
            this.buildNotesRow()
          }
          .padding(16)
        }
        .layoutWeight(1)

        Divider().height(1).color('#F5F5F5')

        // 确认按钮
        Button('保存记录')
          .width('100%')
          .height(44)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6F00')
          .borderRadius(22)
          .margin(16)
          .onClick(() => {
            const record = new GrowthRecord({
              petId: this.petId,
              type: this.recordType as GrowthRecordType,
              weight: parseFloat(this.weight) || 0,
              height: parseFloat(this.height) || 0,
              photo: this.photo,
              notes: this.notes,
              date: this.recordDate
            })
            if (this.onConfirm) {
              this.onConfirm(record)
              this.resetForm()
            }
          })
      }
      .width('92%')
      .maxHeight('80%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .position({ x: '4%', y: '10%' })
    }
  }

  @Builder
  private buildTypeSelector(): void {
    Column() {
      Text('记录类型')
        .fontSize(14)
        .fontColor('#424242')
        .margin({ bottom: 8 })
        .width('100%')

      Grid() {
        ForEach(Object.keys(GROWTH_TYPE_LABELS), (key: string) => {
          GridItem() {
            Column() {
              Text(GROWTH_TYPE_ICONS[key] || '📌')
                .fontSize(20)
              Text(GROWTH_TYPE_LABELS[key])
                .fontSize(11)
                .fontColor(this.recordType === key ? '#FF6F00' : '#757575')
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .backgroundColor(this.recordType === key ? '#FFF8E1' : '#FAFAFA')
            .borderRadius(8)
            .border({
              width: this.recordType === key ? 2 : 0,
              color: '#FFB300'
            })
            .onClick(() => { this.recordType = key })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(6)
      .columnsGap(6)
      .height(130)
    }
    .margin({ bottom: 16 })
  }

  @Builder
  private buildInputRow(label: string, placeholder: string, value: string, onChange: (v: string) => void): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#424242')
        .width(100)
      TextInput({ text: value, placeholder: placeholder })
        .type(InputType.Number)
        .fontSize(14)
        .layoutWeight(1)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .onChange(onChange)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  private buildPhotoRow(): void {
    Row() {
      Text('📸 照片')
        .fontSize(14)
        .fontColor('#424242')
        .width(100)
      if (this.photo) {
        Image(this.photo)
          .width(60)
          .height(60)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
        Button('删除')
          .fontSize(12)
          .fontColor('#FF5252')
          .backgroundColor(Color.Transparent)
          .onClick(() => { this.photo = '' })
      } else {
        Button('选择照片')
          .fontSize(13)
          .fontColor('#FF6F00')
          .backgroundColor('#FFF8E1')
          .borderRadius(8)
          .onClick(() => {
            this.selectPhoto()
          })
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  private buildDateRow(): void {
    Row() {
      Text('📅 日期')
        .fontSize(14)
        .fontColor('#424242')
        .width(100)
      TextInput({ text: this.recordDate, placeholder: 'YYYY-MM-DD' })
        .type(InputType.Normal)
        .fontSize(14)
        .layoutWeight(1)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .onChange((value: string) => { this.recordDate = value })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  private buildNotesRow(): void {
    Column() {
      Text('📝 备注')
        .fontSize(14)
        .fontColor('#424242')
        .margin({ bottom: 4 })
        .width('100%')
      TextArea({ text: this.notes, placeholder: '记录宠物的成长点滴...' })
        .fontSize(14)
        .height(80)
        .width('100%')
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .onChange((value: string) => { this.notes = value })
    }
  }

  private async selectPhoto(): Promise<void> {
    try {
      const context = getContext(this)
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)
      if (result && result.photoUris && result.photoUris.length > 0) {
        this.photo = result.photoUris[0]
      }
    } catch (err) {
      console.error('[AddRecordDialog] 选择照片失败:', JSON.stringify(err))
    }
  }

  private resetForm(): void {
    this.recordType = GrowthRecordType.DAILY
    this.weight = ''
    this.height = ''
    this.photo = ''
    this.notes = ''
    this.recordDate = DateUtil.today()
  }
}
