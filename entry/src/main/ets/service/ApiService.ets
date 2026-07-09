import { http } from '@kit.NetworkKit'
import { PetInfo } from '../model/PetInfo'
import { GrowthRecord, GrowthRecordType } from '../model/GrowthRecord'
import { HealthReminder, ReminderType, RepeatCycle } from '../model/HealthReminder'
import { UserInfo } from '../model/UserInfo'
import { FeedPostData } from './DatabaseService'
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'

/** 服务端地址 — 鸿蒙模拟器用 10.0.2.2 访问宿主机，真机改为电脑IP */
const BASE_URL = 'http://10.0.2.2:8080/api'

/** JWT Token 存储 Key */
export const TOKEN_KEY = 'jwt_token'

/** 通用 API 响应 */
interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

/** 登录/注册返回 */
interface LoginResponseData {
  token: string
  userId: string
  username: string
  avatar: string
}

// ==================== 请求体类 ====================

class LoginBody {
  username: string
  password: string
  constructor(username: string, password: string) {
    this.username = username
    this.password = password
  }
}

class PetBody {
  name: string
  species: string
  breed: string
  birthDate: string
  gender: string
  avatar: string
  weight: number
  height: number
  color: string
  notes: string
  constructor(name: string, species: string, breed: string, birthDate: string,
    gender: string, avatar: string, weight: number, height: number,
    color: string, notes: string) {
    this.name = name
    this.species = species
    this.breed = breed
    this.birthDate = birthDate
    this.gender = gender
    this.avatar = avatar
    this.weight = weight
    this.height = height
    this.color = color
    this.notes = notes
  }
}

class RecordBody {
  date: string
  weight: number
  height: number
  photo: string
  notes: string
  type: string
  constructor(date: string, weight: number, height: number, photo: string,
    notes: string, type: string) {
    this.date = date
    this.weight = weight
    this.height = height
    this.photo = photo
    this.notes = notes
    this.type = type
  }
}

class ReminderBody {
  type: string
  title: string
  date: string
  time: string
  repeatCycle: string
  enabled: boolean
  notes: string
  constructor(type: string, title: string, date: string, time: string,
    repeatCycle: string, enabled: boolean, notes: string) {
    this.type = type
    this.title = title
    this.date = date
    this.time = time
    this.repeatCycle = repeatCycle
    this.enabled = enabled
    this.notes = notes
  }
}

class FeedBody {
  topicId: string
  content: string
  constructor(topicId: string, content: string) {
    this.topicId = topicId
    this.content = content
  }
}

class UserProfileBody {
  username: string
  bio: string
  phone: string
  email: string
  avatar: string
  topics: string
  constructor(username: string, bio: string, phone: string, email: string,
    avatar: string, topics: string) {
    this.username = username
    this.bio = bio
    this.phone = phone
    this.email = email
    this.avatar = avatar
    this.topics = topics
  }
}

/**
 * 后端 API 服务（单例）
 */
export class ApiService {
  private static instance: ApiService

  static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService()
    }
    return ApiService.instance
  }

  // ==================== Token 管理 ====================

  getToken(): string {
    return AppStorage.get<string>(TOKEN_KEY) || ''
  }

  setToken(token: string): void {
    AppStorage.setOrCreate(TOKEN_KEY, token)
  }

  clearToken(): void {
    AppStorage.setOrCreate(TOKEN_KEY, '')
    AppStorage.setOrCreate('currentUserId', '')
  }

  isLoggedIn(): boolean {
    const token = this.getToken()
    return token.length > 0
  }

  // ==================== HTTP — 每次新建，不设 timeout ====================

  private async request<T>(method: http.RequestMethod, path: string, body?: object): Promise<T | null> {
    const token = this.getToken()
    const url = BASE_URL + path
    let response: http.HttpResponse

    try {
      const req = http.createHttp()
      if (token.length > 0) {
        if (body && (method === http.RequestMethod.POST || method === http.RequestMethod.PUT)) {
          response = await req.request(url, {
            method: method,
            header: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
            extraData: JSON.stringify(body)
          })
        } else {
          response = await req.request(url, {
            method: method,
            header: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
          })
        }
      } else {
        if (body && (method === http.RequestMethod.POST || method === http.RequestMethod.PUT)) {
          response = await req.request(url, {
            method: method,
            header: { 'Content-Type': 'application/json' },
            extraData: JSON.stringify(body)
          })
        } else {
          response = await req.request(url, {
            method: method,
            header: { 'Content-Type': 'application/json' }
          })
        }
      }
      req.destroy()

      const rawResult = response.result
      let result: ApiResponse<T>
      if (typeof rawResult === 'string') {
        result = JSON.parse(rawResult as string) as ApiResponse<T>
      } else {
        result = rawResult as ApiResponse<T>
      }

      if (result.code === 200) {
        return result.data
      } else if (result.code === 401 || result.code === 403) {
        this.clearToken()
        promptAction.showToast({ message: '登录已过期，请重新登录', duration: 2000 })
        router.replaceUrl({ url: 'pages/LoginPage' })
        return null
      } else {
        promptAction.showToast({ message: result.message || '请求失败', duration: 2000 })
        return null
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求失败', duration: 2000 })
      return null
    }
  }

  private async get<T>(path: string): Promise<T | null> {
    return this.request<T>(http.RequestMethod.GET, path)
  }

  private async post<T>(path: string, body?: object): Promise<T | null> {
    return this.request<T>(http.RequestMethod.POST, path, body)
  }

  private async put<T>(path: string, body?: object): Promise<T | null> {
    return this.request<T>(http.RequestMethod.PUT, path, body)
  }

  private async del<T>(path: string): Promise<T | null> {
    return this.request<T>(http.RequestMethod.DELETE, path)
  }

  // ==================== 认证 ====================

  async register(username: string, password: string): Promise<LoginResponseData | null> {
    const body = new LoginBody(username, password)
    const result = await this.post<LoginResponseData>('/auth/register', body)
    if (result) {
      this.setToken(result.token)
      AppStorage.setOrCreate('currentUserId', result.userId)
    }
    return result
  }

  async login(username: string, password: string): Promise<LoginResponseData | null> {
    const body = new LoginBody(username, password)
    const result = await this.post<LoginResponseData>('/auth/login', body)
    if (result) {
      this.setToken(result.token)
      AppStorage.setOrCreate('currentUserId', result.userId)
    }
    return result
  }

  async checkUsername(username: string): Promise<boolean> {
    const result = await this.get<boolean>('/auth/check-username?username=' + encodeURIComponent(username))
    return result ?? false
  }

  // ==================== 用户 ====================

  async getUserProfile(): Promise<UserInfo | null> {
    const data = await this.get<UserInfo>('/users/me')
    if (data) {
      return new UserInfo(data)
    }
    return null
  }

  async updateUserProfile(req: UserProfileBody): Promise<UserInfo | null> {
    const data = await this.put<UserInfo>('/users/me', req)
    if (data) {
      return new UserInfo(data)
    }
    return null
  }

  // ==================== 宠物 ====================

  async getPets(): Promise<PetInfo[]> {
    const list = await this.get<PetInfo[]>('/pets')
    return list || []
  }

  async getPet(id: string): Promise<PetInfo | null> {
    const data = await this.get<PetInfo>('/pets/' + id)
    return data ? data : null
  }

  async createPet(req: PetBody): Promise<PetInfo | null> {
    const data = await this.post<PetInfo>('/pets', req)
    return data ? data : null
  }

  async updatePet(id: string, req: PetBody): Promise<PetInfo | null> {
    const data = await this.put<PetInfo>('/pets/' + id, req)
    return data ? data : null
  }

  async deletePet(id: string): Promise<boolean> {
    await this.del<void>('/pets/' + id)
    return true
  }

  // ==================== 成长记录 ====================

  async getRecords(petId: string, type?: string): Promise<GrowthRecord[]> {
    let path = '/pets/' + petId + '/records'
    if (type && type !== 'all') {
      path += '?type=' + encodeURIComponent(type)
    }
    const list = await this.get<GrowthRecord[]>(path)
    if (list) {
      return list.map((item: GrowthRecord) => {
        const r = new GrowthRecord()
        r.id = item.id ?? ''
        r.petId = item.petId ?? petId
        r.date = item.date ?? ''
        r.weight = item.weight ?? 0
        r.height = item.height ?? 0
        r.photo = item.photo ?? ''
        r.notes = item.notes ?? ''
        r.type = (item.type || 'daily') as GrowthRecordType
        r.createTime = item.createTime ?? ''
        return r
      })
    }
    return []
  }

  async createRecord(petId: string, req: RecordBody): Promise<GrowthRecord | null> {
    const data = await this.post<GrowthRecord>('/pets/' + petId + '/records', req)
    if (data) {
      const r = new GrowthRecord()
      r.id = data.id ?? ''
      r.petId = data.petId ?? petId
      r.date = data.date ?? ''
      r.weight = data.weight ?? 0
      r.height = data.height ?? 0
      r.photo = data.photo ?? ''
      r.notes = data.notes ?? ''
      r.type = (data.type || 'daily') as GrowthRecordType
      r.createTime = data.createTime ?? ''
      return r
    }
    return null
  }

  async deleteRecord(id: string): Promise<boolean> {
    await this.del<void>('/records/' + id)
    return true
  }

  // ==================== 健康提醒 ====================

  async getReminders(petId: string): Promise<HealthReminder[]> {
    const list = await this.get<HealthReminder[]>('/pets/' + petId + '/reminders')
    if (list) {
      return list.map((item: HealthReminder) => {
        const r = new HealthReminder()
        r.id = item.id ?? ''
        r.petId = item.petId ?? petId
        r.type = (item.type || 'custom') as ReminderType
        r.title = item.title ?? ''
        r.date = item.date ?? ''
        r.time = item.time ?? '09:00'
        r.repeatCycle = (item.repeatCycle || 'none') as RepeatCycle
        r.enabled = item.enabled ?? true
        r.notes = item.notes ?? ''
        r.createTime = item.createTime ?? ''
        return r
      })
    }
    return []
  }

  async getTodayReminders(petId: string): Promise<HealthReminder[]> {
    const list = await this.get<HealthReminder[]>('/pets/' + petId + '/reminders/today')
    if (list) {
      return list.map((item: HealthReminder) => {
        const r = new HealthReminder()
        r.id = item.id ?? ''
        r.petId = item.petId ?? petId
        r.type = (item.type || 'custom') as ReminderType
        r.title = item.title ?? ''
        r.date = item.date ?? ''
        r.time = item.time ?? '09:00'
        r.repeatCycle = (item.repeatCycle || 'none') as RepeatCycle
        r.enabled = item.enabled ?? true
        r.notes = item.notes ?? ''
        r.createTime = item.createTime ?? ''
        return r
      })
    }
    return []
  }

  async getUpcomingReminders(petId: string): Promise<HealthReminder[]> {
    const list = await this.get<HealthReminder[]>('/pets/' + petId + '/reminders/upcoming')
    if (list) {
      return list.map((item: HealthReminder) => {
        const r = new HealthReminder()
        r.id = item.id ?? ''
        r.petId = item.petId ?? petId
        r.type = (item.type || 'custom') as ReminderType
        r.title = item.title ?? ''
        r.date = item.date ?? ''
        r.time = item.time ?? '09:00'
        r.repeatCycle = (item.repeatCycle || 'none') as RepeatCycle
        r.enabled = item.enabled ?? true
        r.notes = item.notes ?? ''
        r.createTime = item.createTime ?? ''
        return r
      })
    }
    return []
  }

  async createReminder(petId: string, req: ReminderBody): Promise<HealthReminder | null> {
    const data = await this.post<HealthReminder>('/pets/' + petId + '/reminders', req)
    if (data) {
      const r = new HealthReminder()
      r.id = data.id ?? ''
      r.petId = data.petId ?? petId
      r.type = (data.type || 'custom') as ReminderType
      r.title = data.title ?? ''
      r.date = data.date ?? ''
      r.time = data.time ?? '09:00'
      r.repeatCycle = (data.repeatCycle || 'none') as RepeatCycle
      r.enabled = data.enabled ?? true
      r.notes = data.notes ?? ''
      r.createTime = data.createTime ?? ''
      return r
    }
    return null
  }

  async updateReminder(id: string, req: ReminderBody): Promise<HealthReminder | null> {
    const data = await this.put<HealthReminder>('/reminders/' + id, req)
    if (data) {
      const r = new HealthReminder()
      r.id = data.id ?? ''
      r.petId = data.petId ?? ''
      r.type = (data.type || 'custom') as ReminderType
      r.title = data.title ?? ''
      r.date = data.date ?? ''
      r.time = data.time ?? '09:00'
      r.repeatCycle = (data.repeatCycle || 'none') as RepeatCycle
      r.enabled = data.enabled ?? true
      r.notes = data.notes ?? ''
      r.createTime = data.createTime ?? ''
      return r
    }
    return null
  }

  async deleteReminder(id: string): Promise<boolean> {
    await this.del<void>('/reminders/' + id)
    return true
  }

  // ==================== 社区动态 ====================

  async getFeedPosts(topicId?: string): Promise<FeedPostData[]> {
    let path = '/feed'
    if (topicId) {
      path += '?topicId=' + encodeURIComponent(topicId)
    }
    const list = await this.get<FeedPostData[]>(path)
    return list || []
  }

  async getFeedPostsByUser(userId: string): Promise<FeedPostData[]> {
    const list = await this.get<FeedPostData[]>('/feed/user/' + userId)
    return list || []
  }

  async createFeedPost(req: FeedBody): Promise<FeedPostData | null> {
    const data = await this.post<FeedPostData>('/feed', req)
    return data || null
  }
}

export { LoginBody, PetBody, RecordBody, ReminderBody, FeedBody, UserProfileBody }
