import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { CURRENT_USER_KEY, TOKEN_KEY } from '../model/UserInfo'
import { ApiService } from '../service/ApiService'
import { FeedPostData } from '../service/DatabaseService'
import { DateUtil } from '../common/Utils'

interface TopicTag {
  id: string
  icon: string
  name: string
}

const TOPIC_TAGS: TopicTag[] = [
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

const SAMPLE_FEEDS: FeedPostData[] = [
  { id: -1, userId: '', topicId: 'get_along', content: '新猫到家第三天，终于主动蹭我了！秘诀就是不要主动抱它，让它自己来探索你~', author: '猫咪达人', avatar: '🐱', likes: 328, comments: 45, createTime: '2025-06-01' },
  { id: -2, userId: '', topicId: 'diet', content: '自制狗饭配方分享：鸡胸肉+胡萝卜+南瓜，狗狗超爱吃，毛也变亮了！', author: '营养师小王', avatar: '🐕', likes: 256, comments: 38, createTime: '2025-06-02' },
  { id: -3, userId: '', topicId: 'train', content: '用零食训练法，3天教会狗狗坐下、握手、趴下，真的不难！', author: '训犬师老张', avatar: '🎾', likes: 412, comments: 67, createTime: '2025-06-03' },
  { id: -4, userId: '', topicId: 'medical', content: '猫咪疫苗接种时间表，新手家长必收藏！附各年龄段注意事项', author: '宠物医生李', avatar: '💉', likes: 520, comments: 89, createTime: '2025-06-04' },
  { id: -5, userId: '', topicId: 'emotion', content: '狗狗真的会难过吗？主人出差一周回来，它居然哭了...动物的情感比我们想的更丰富', author: '宠物心理师', avatar: '💕', likes: 635, comments: 102, createTime: '2025-06-05' },
  { id: -6, userId: '', topicId: 'behavior', content: '猫咪踩奶是什么意思？原来是小时候的记忆，说明它把你当妈妈了！', author: '猫语者', avatar: '🐈', likes: 480, comments: 56, createTime: '2025-06-06' },
  { id: -7, userId: '', topicId: 'groom', content: '夏天给狗狗剃毛要注意！剃太短反而容易晒伤，留2-3厘米最合适', author: '美容师阿美', avatar: '✂️', likes: 198, comments: 23, createTime: '2025-06-07' },
  { id: -8, userId: '', topicId: 'get_along', content: '孩子和狗狗相处守则：教会孩子尊重狗狗的边界，避免意外发生', author: '亲子宠物', avatar: '👨‍👩‍👧', likes: 370, comments: 44, createTime: '2025-06-08' },
  { id: -9, userId: '', topicId: 'play', content: '10个低成本狗狗益智玩具DIY，用家里的旧衣服就能做！', author: '手工达人', avatar: '🧶', likes: 285, comments: 31, createTime: '2025-06-09' },
  { id: -10, userId: '', topicId: 'travel', content: '带猫咪自驾游攻略：提前准备好猫包、猫砂盆、水碗，猫咪也能玩得开心', author: '旅行家阿飞', avatar: '🚗', likes: 310, comments: 41, createTime: '2025-06-10' },
  { id: -11, userId: '', topicId: 'diet', content: '猫咪不能吃的10种食物清单：巧克力、洋葱、葡萄...一定要记好！', author: '营养师小王', avatar: '🐕', likes: 550, comments: 73, createTime: '2025-06-11' },
  { id: -12, userId: '', topicId: 'breed', content: '养柯基前必须知道的5件事：掉毛、脊椎问题、精力旺盛...养之前想清楚', author: '柯基家长会', avatar: '🐶', likes: 440, comments: 85, createTime: '2025-06-12' },
  { id: -13, userId: '', topicId: 'medical', content: '宠物驱虫怎么选？体外驱虫和体内驱虫的区别，一次讲清楚', author: '宠物医生李', avatar: '💉', likes: 390, comments: 52, createTime: '2025-06-13' },
  { id: -14, userId: '', topicId: 'emotion', content: '狗狗老了之后的变化：睡眠变多、反应变慢...请多给它们一些耐心', author: '老年犬护理', avatar: '🐕‍🦺', likes: 680, comments: 98, createTime: '2025-06-14' },
  { id: -15, userId: '', topicId: 'train', content: '狗狗乱叫怎么办？先别急着骂，搞清楚它为什么叫才能对症下药', author: '训犬师老张', avatar: '🎾', likes: 345, comments: 48, createTime: '2025-06-15' }
]

@Entry
@Component
struct TopicFeedPage {
  @State selectedTopics: string[] = []
  @State allPosts: FeedPostData[] = []
  @State showPublish: boolean = false
  @State publishContent: string = ''
  @State publishTopic: string = 'get_along'
  @State currentUserId: string = ''

  aboutToAppear(): void {
    // 登录检查
    const api = ApiService.getInstance()
    if (!api.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录后再查看宠友圈', duration: 2000 })
      router.replaceUrl({ url: 'pages/LoginPage' })
      return
    }
    const uid = AppStorage.get<string>(CURRENT_USER_KEY)
    this.currentUserId = uid || ''
    this.loadFeeds()
  }

  async loadFeeds(): Promise<void> {
    const api = ApiService.getInstance()
    const dbPosts = await api.getFeedPosts()
    // 合并后端帖子和示例帖子
    this.allPosts = [...dbPosts, ...SAMPLE_FEEDS]
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

        Text('🔥 宠友圈')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
          .margin({ left: 8 })

        Blank()

        Button('✏️ 发布')
          .fontSize(13)
          .fontColor('#FF6F00')
          .backgroundColor('#FFF8E1')
          .borderRadius(14)
          .padding({ left: 10, right: 10 })
          .height(30)
          .onClick(() => { this.showPublish = true })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Divider().height(1).color('#F5F5F5')

      Scroll() {
        Column() {
          // 话题筛选条
          Row() {
            Text('🏷️ 按话题筛选（可多选）')
              .fontSize(13)
              .fontColor('#9E9E9E')
          }
          .width('100%')
          .margin({ top: 4, bottom: 8 })

          Scroll() {
            Row() {
              ForEach(TOPIC_TAGS, (tag: TopicTag) => {
                Text(tag.icon + ' ' + tag.name)
                  .fontSize(12)
                  .fontColor(this.selectedTopics.indexOf(tag.id) >= 0 ? '#FFFFFF' : '#757575')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.selectedTopics.indexOf(tag.id) >= 0 ? '#FF6F00' : '#F5F5F5')
                  .borderRadius(14)
                  .margin({ right: 8 })
                  .onClick(() => { this.toggleTopic(tag.id) })
              })
            }
            .padding({ top: 4, bottom: 4 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.selectedTopics.length === 0) {
            Text('💡 未选择话题，展示点赞最高的动态')
              .fontSize(12)
              .fontColor('#BDBDBD')
              .width('100%')
              .margin({ top: 8, bottom: 4 })
          }

          // 动态列表
          Column() {
            ForEach(this.getFilteredFeeds(), (post: FeedPostData) => {
              Column() {
                Row() {
                  Text(post.avatar)
                    .fontSize(24)
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#FFF3E0')
                    .textAlign(TextAlign.Center)
                  Column() {
                    Row() {
                      Text(post.author)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#424242')
                      if (post.userId === this.currentUserId) {
                        Text('  [我的]')
                          .fontSize(11)
                          .fontColor('#FF6F00')
                      }
                    }
                    Text(this.getTopicName(post.topicId))
                      .fontSize(11)
                      .fontColor('#FF6F00')
                  }
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)
                  Blank()
                }

                Text(post.content)
                  .fontSize(14)
                  .fontColor('#616161')
                  .lineHeight(22)
                  .margin({ top: 10 })
                  .width('100%')

                Row() {
                  Text(`❤️ ${post.likes}`)
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                  Text(`💬 ${post.comments}`)
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                    .margin({ left: 16 })
                  Blank()
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 8 })
              .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 })
            })

            if (this.getFilteredFeeds().length === 0) {
              Row() {
                Text('📭')
                  .fontSize(20)
                Text('该话题暂无动态')
                  .fontSize(14)
                  .fontColor('#BDBDBD')
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding(24)
              .backgroundColor('#FAFAFA')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
            }
          }
          .margin({ top: 8 })
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 发布弹窗
      if (this.showPublish) {
        this.buildPublishDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  private buildPublishDialog(): void {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => { this.showPublish = false })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column() {
      Text('✏️ 发布动态')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 16 })

      // 话题选择
      Text('选择话题')
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 6 })
        .padding({ left: 20 })

      Scroll() {
        Row() {
          ForEach(TOPIC_TAGS, (tag: TopicTag) => {
            Text(tag.icon + ' ' + tag.name)
              .fontSize(12)
              .fontColor(this.publishTopic === tag.id ? '#FFFFFF' : '#757575')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor(this.publishTopic === tag.id ? '#FF6F00' : '#F5F5F5')
              .borderRadius(12)
              .margin({ right: 6 })
              .onClick(() => { this.publishTopic = tag.id })
          })
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)
      .margin({ bottom: 12 })

      // 内容输入
      Text('内容')
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 4 })
        .padding({ left: 20 })
      TextArea({ text: this.publishContent, placeholder: '分享你的宠物故事...' })
        .fontSize(14)
        .height(100)
        .width('100%')
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .margin({ left: 20, right: 20, bottom: 16 })
        .onChange((v: string) => { this.publishContent = v })

      Row() {
        Button('取消')
          .fontSize(15)
          .fontColor('#757575')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onClick(() => { this.showPublish = false })

        Button('发布')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FF6F00')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick(() => { this.publishPost() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .position({ x: '5%', y: '20%' })
  }

  async publishPost(): Promise<void> {
    const content = this.publishContent.trim()
    if (!content) {
      promptAction.showToast({ message: '请输入内容', duration: 1500 })
      return
    }
    const api = ApiService.getInstance()
    // 后端自动从JWT获取userId、author、avatar
    const result = await api.createFeedPost({
      topicId: this.publishTopic,
      content: content
    })
    if (result) {
      promptAction.showToast({ message: '发布成功！', duration: 1500 })
      this.showPublish = false
      this.publishContent = ''
      await this.loadFeeds()
    } else {
      promptAction.showToast({ message: '发布失败，请重试', duration: 1500 })
    }
  }

  toggleTopic(topicId: string): void {
    const idx = this.selectedTopics.indexOf(topicId)
    if (idx >= 0) {
      this.selectedTopics.splice(idx, 1)
    } else {
      this.selectedTopics.push(topicId)
    }
    this.selectedTopics = [...this.selectedTopics]
  }

  getFilteredFeeds(): FeedPostData[] {
    let result = this.allPosts
    if (this.selectedTopics.length > 0) {
      result = result.filter(f => this.selectedTopics.indexOf(f.topicId) >= 0)
    }
    // 未选时按点赞排序
    if (this.selectedTopics.length === 0) {
      result = [...result].sort((a, b) => b.likes - a.likes)
    }
    return result
  }

  getTopicName(topicId: string): string {
    const t = TOPIC_TAGS.find(tag => tag.id === topicId)
    return t ? t.icon + ' ' + t.name : topicId
  }
}
