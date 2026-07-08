/**
 * 用户信息数据模型
 */
@Observed
export class UserInfo {
  /** 用户ID */
  id: string = 'default_user'
  /** 用户名/昵称 */
  username: string = ''
  /** 密码 */
  password: string = ''
  /** 用户头像URI */
  avatar: string = ''
  /** 个性签名 */
  bio: string = ''
  /** 手机号 */
  phone: string = ''
  /** 邮箱 */
  email: string = ''
  /** 注册日期 */
  joinDate: string = ''
  /** 更新日期 */
  updateTime: string = ''

  constructor(data?: UserInfo) {
    if (data) {
      this.id = data.id ?? this.id
      this.username = data.username ?? this.username
      this.password = data.password ?? this.password
      this.avatar = data.avatar ?? this.avatar
      this.bio = data.bio ?? this.bio
      this.phone = data.phone ?? this.phone
      this.email = data.email ?? this.email
      this.joinDate = data.joinDate ?? this.joinDate
      this.updateTime = data.updateTime ?? this.updateTime
    }
  }
}

/** 当前登录用户ID（存储在 AppStorage 中） */
export const CURRENT_USER_KEY = 'currentUserId'
