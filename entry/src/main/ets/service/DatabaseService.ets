import { PetInfo } from '../model/PetInfo'
import { GrowthRecord, GrowthRecordType } from '../model/GrowthRecord'
import { HealthReminder, ReminderType, RepeatCycle } from '../model/HealthReminder'
import { UserInfo } from '../model/UserInfo'
import { relationalStore } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'PetDiary.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

const SQL_CREATE_PET_INFO = `
  CREATE TABLE IF NOT EXISTS pet_info (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    species TEXT DEFAULT '',
    breed TEXT DEFAULT '',
    birth_date TEXT DEFAULT '',
    gender TEXT DEFAULT '',
    avatar TEXT DEFAULT '',
    weight REAL DEFAULT 0,
    height REAL DEFAULT 0,
    color TEXT DEFAULT '',
    notes TEXT DEFAULT '',
    create_time TEXT DEFAULT '',
    update_time TEXT DEFAULT ''
  )
`

const SQL_CREATE_GROWTH_RECORD = `
  CREATE TABLE IF NOT EXISTS growth_record (
    id TEXT PRIMARY KEY,
    pet_id TEXT NOT NULL,
    date TEXT DEFAULT '',
    weight REAL DEFAULT 0,
    height REAL DEFAULT 0,
    photo TEXT DEFAULT '',
    notes TEXT DEFAULT '',
    type TEXT DEFAULT 'daily',
    create_time TEXT DEFAULT '',
    FOREIGN KEY (pet_id) REFERENCES pet_info(id)
  )
`

const SQL_CREATE_HEALTH_REMINDER = `
  CREATE TABLE IF NOT EXISTS health_reminder (
    id TEXT PRIMARY KEY,
    pet_id TEXT NOT NULL,
    type TEXT DEFAULT 'custom',
    title TEXT DEFAULT '',
    date TEXT DEFAULT '',
    time TEXT DEFAULT '09:00',
    repeat_cycle TEXT DEFAULT 'none',
    enabled INTEGER DEFAULT 1,
    notes TEXT DEFAULT '',
    create_time TEXT DEFAULT '',
    FOREIGN KEY (pet_id) REFERENCES pet_info(id)
  )
`

const SQL_CREATE_USER_INFO = `
  CREATE TABLE IF NOT EXISTS user_info (
    id TEXT PRIMARY KEY,
    username TEXT DEFAULT '',
    avatar TEXT DEFAULT '',
    bio TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    email TEXT DEFAULT '',
    join_date TEXT DEFAULT '',
    update_time TEXT DEFAULT ''
  )
`

/**
 * 本地数据库服务
 * 使用关系型数据库存储宠物的全部数据
 */
export class DatabaseService {
  private static instance: DatabaseService
  private store: relationalStore.RdbStore | null = null

  static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService()
    }
    return DatabaseService.instance
  }

  /**
   * 初始化数据库
   */
  async init(context: Context): Promise<void> {
    try {
      this.store = await relationalStore.getRdbStore(context, STORE_CONFIG)
      await this.store.executeSql(SQL_CREATE_PET_INFO)
      await this.store.executeSql(SQL_CREATE_GROWTH_RECORD)
      await this.store.executeSql(SQL_CREATE_HEALTH_REMINDER)
      await this.store.executeSql(SQL_CREATE_USER_INFO)
      console.info('[DatabaseService] 数据库初始化成功')
    } catch (err) {
      console.error('[DatabaseService] 数据库初始化失败:', JSON.stringify(err))
    }
  }

  // ==================== 宠物档案 CRUD ====================

  async insertPet(pet: PetInfo): Promise<boolean> {
    if (!this.store) return false
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        id: pet.id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        birth_date: pet.birthDate,
        gender: pet.gender,
        avatar: pet.avatar,
        weight: pet.weight,
        height: pet.height,
        color: pet.color,
        notes: pet.notes,
        create_time: pet.createTime,
        update_time: pet.updateTime
      }
      await this.store.insert('pet_info', valueBucket)
      return true
    } catch (err) {
      console.error('[DatabaseService] insertPet failed:', JSON.stringify(err))
      return false
    }
  }

  async updatePet(pet: PetInfo): Promise<boolean> {
    if (!this.store) return false
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        birth_date: pet.birthDate,
        gender: pet.gender,
        avatar: pet.avatar,
        weight: pet.weight,
        height: pet.height,
        color: pet.color,
        notes: pet.notes,
        update_time: pet.updateTime
      }
      const predicates = new relationalStore.RdbPredicates('pet_info')
      predicates.equalTo('id', pet.id)
      await this.store.update(valueBucket, predicates)
      return true
    } catch (err) {
      console.error('[DatabaseService] updatePet failed:', JSON.stringify(err))
      return false
    }
  }

  async deletePet(petId: string): Promise<boolean> {
    if (!this.store) return false
    try {
      // 同时删除关联的成长记录和提醒
      let predicates = new relationalStore.RdbPredicates('growth_record')
      predicates.equalTo('pet_id', petId)
      await this.store.delete(predicates)

      predicates = new relationalStore.RdbPredicates('health_reminder')
      predicates.equalTo('pet_id', petId)
      await this.store.delete(predicates)

      predicates = new relationalStore.RdbPredicates('pet_info')
      predicates.equalTo('id', petId)
      await this.store.delete(predicates)
      return true
    } catch (err) {
      console.error('[DatabaseService] deletePet failed:', JSON.stringify(err))
      return false
    }
  }

  async queryAllPets(): Promise<PetInfo[]> {
    if (!this.store) return []
    try {
      const predicates = new relationalStore.RdbPredicates('pet_info')
      predicates.orderByDesc('update_time')
      const resultSet = await this.store.query(predicates)
      const pets: PetInfo[] = []
      while (resultSet.goToNextRow()) {
        const pet = new PetInfo()
        pet.id = resultSet.getString(resultSet.getColumnIndex('id'))
        pet.name = resultSet.getString(resultSet.getColumnIndex('name'))
        pet.species = resultSet.getString(resultSet.getColumnIndex('species'))
        pet.breed = resultSet.getString(resultSet.getColumnIndex('breed'))
        pet.birthDate = resultSet.getString(resultSet.getColumnIndex('birth_date'))
        pet.gender = resultSet.getString(resultSet.getColumnIndex('gender'))
        pet.avatar = resultSet.getString(resultSet.getColumnIndex('avatar'))
        pet.weight = resultSet.getDouble(resultSet.getColumnIndex('weight'))
        pet.height = resultSet.getDouble(resultSet.getColumnIndex('height'))
        pet.color = resultSet.getString(resultSet.getColumnIndex('color'))
        pet.notes = resultSet.getString(resultSet.getColumnIndex('notes'))
        pet.createTime = resultSet.getString(resultSet.getColumnIndex('create_time'))
        pet.updateTime = resultSet.getString(resultSet.getColumnIndex('update_time'))
        pets.push(pet)
      }
      resultSet.close()
      return pets
    } catch (err) {
      console.error('[DatabaseService] queryAllPets failed:', JSON.stringify(err))
      return []
    }
  }

  async queryPetById(petId: string): Promise<PetInfo | null> {
    if (!this.store) return null
    try {
      const predicates = new relationalStore.RdbPredicates('pet_info')
      predicates.equalTo('id', petId)
      const resultSet = await this.store.query(predicates)
      if (resultSet.goToFirstRow()) {
        const pet = new PetInfo()
        pet.id = resultSet.getString(resultSet.getColumnIndex('id'))
        pet.name = resultSet.getString(resultSet.getColumnIndex('name'))
        pet.species = resultSet.getString(resultSet.getColumnIndex('species'))
        pet.breed = resultSet.getString(resultSet.getColumnIndex('breed'))
        pet.birthDate = resultSet.getString(resultSet.getColumnIndex('birth_date'))
        pet.gender = resultSet.getString(resultSet.getColumnIndex('gender'))
        pet.avatar = resultSet.getString(resultSet.getColumnIndex('avatar'))
        pet.weight = resultSet.getDouble(resultSet.getColumnIndex('weight'))
        pet.height = resultSet.getDouble(resultSet.getColumnIndex('height'))
        pet.color = resultSet.getString(resultSet.getColumnIndex('color'))
        pet.notes = resultSet.getString(resultSet.getColumnIndex('notes'))
        pet.createTime = resultSet.getString(resultSet.getColumnIndex('create_time'))
        pet.updateTime = resultSet.getString(resultSet.getColumnIndex('update_time'))
        resultSet.close()
        return pet
      }
      resultSet.close()
      return null
    } catch (err) {
      console.error('[DatabaseService] queryPetById failed:', JSON.stringify(err))
      return null
    }
  }

  // ==================== 成长记录 CRUD ====================

  async insertGrowthRecord(record: GrowthRecord): Promise<boolean> {
    if (!this.store) return false
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        id: record.id,
        pet_id: record.petId,
        date: record.date,
        weight: record.weight,
        height: record.height,
        photo: record.photo,
        notes: record.notes,
        type: record.type,
        create_time: record.createTime
      }
      await this.store.insert('growth_record', valueBucket)
      return true
    } catch (err) {
      console.error('[DatabaseService] insertGrowthRecord failed:', JSON.stringify(err))
      return false
    }
  }

  async deleteGrowthRecord(recordId: string): Promise<boolean> {
    if (!this.store) return false
    try {
      const predicates = new relationalStore.RdbPredicates('growth_record')
      predicates.equalTo('id', recordId)
      await this.store.delete(predicates)
      return true
    } catch (err) {
      console.error('[DatabaseService] deleteGrowthRecord failed:', JSON.stringify(err))
      return false
    }
  }

  async queryGrowthRecordsByPetId(petId: string): Promise<GrowthRecord[]> {
    if (!this.store) return []
    try {
      const predicates = new relationalStore.RdbPredicates('growth_record')
      predicates.equalTo('pet_id', petId)
      predicates.orderByDesc('date')
      const resultSet = await this.store.query(predicates)
      const records: GrowthRecord[] = []
      while (resultSet.goToNextRow()) {
        const record = new GrowthRecord()
        record.id = resultSet.getString(resultSet.getColumnIndex('id'))
        record.petId = resultSet.getString(resultSet.getColumnIndex('pet_id'))
        record.date = resultSet.getString(resultSet.getColumnIndex('date'))
        record.weight = resultSet.getDouble(resultSet.getColumnIndex('weight'))
        record.height = resultSet.getDouble(resultSet.getColumnIndex('height'))
        record.photo = resultSet.getString(resultSet.getColumnIndex('photo'))
        record.notes = resultSet.getString(resultSet.getColumnIndex('notes'))
        record.type = resultSet.getString(resultSet.getColumnIndex('type')) as GrowthRecordType
        record.createTime = resultSet.getString(resultSet.getColumnIndex('create_time'))
        records.push(record)
      }
      resultSet.close()
      return records
    } catch (err) {
      console.error('[DatabaseService] queryGrowthRecords failed:', JSON.stringify(err))
      return []
    }
  }

  // ==================== 健康提醒 CRUD ====================

  async insertReminder(reminder: HealthReminder): Promise<boolean> {
    if (!this.store) return false
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        id: reminder.id,
        pet_id: reminder.petId,
        type: reminder.type,
        title: reminder.title,
        date: reminder.date,
        time: reminder.time,
        repeat_cycle: reminder.repeatCycle,
        enabled: reminder.enabled ? 1 : 0,
        notes: reminder.notes,
        create_time: reminder.createTime
      }
      await this.store.insert('health_reminder', valueBucket)
      return true
    } catch (err) {
      console.error('[DatabaseService] insertReminder failed:', JSON.stringify(err))
      return false
    }
  }

  async updateReminder(reminder: HealthReminder): Promise<boolean> {
    if (!this.store) return false
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        type: reminder.type,
        title: reminder.title,
        date: reminder.date,
        time: reminder.time,
        repeat_cycle: reminder.repeatCycle,
        enabled: reminder.enabled ? 1 : 0,
        notes: reminder.notes
      }
      const predicates = new relationalStore.RdbPredicates('health_reminder')
      predicates.equalTo('id', reminder.id)
      await this.store.update(valueBucket, predicates)
      return true
    } catch (err) {
      console.error('[DatabaseService] updateReminder failed:', JSON.stringify(err))
      return false
    }
  }

  async deleteReminder(reminderId: string): Promise<boolean> {
    if (!this.store) return false
    try {
      const predicates = new relationalStore.RdbPredicates('health_reminder')
      predicates.equalTo('id', reminderId)
      await this.store.delete(predicates)
      return true
    } catch (err) {
      console.error('[DatabaseService] deleteReminder failed:', JSON.stringify(err))
      return false
    }
  }

  async queryRemindersByPetId(petId: string): Promise<HealthReminder[]> {
    if (!this.store) return []
    try {
      const predicates = new relationalStore.RdbPredicates('health_reminder')
      predicates.equalTo('pet_id', petId)
      predicates.orderByAsc('date')
      const resultSet = await this.store.query(predicates)
      const reminders: HealthReminder[] = []
      while (resultSet.goToNextRow()) {
        const reminder = new HealthReminder()
        reminder.id = resultSet.getString(resultSet.getColumnIndex('id'))
        reminder.petId = resultSet.getString(resultSet.getColumnIndex('pet_id'))
        reminder.type = resultSet.getString(resultSet.getColumnIndex('type')) as ReminderType
        reminder.title = resultSet.getString(resultSet.getColumnIndex('title'))
        reminder.date = resultSet.getString(resultSet.getColumnIndex('date'))
        reminder.time = resultSet.getString(resultSet.getColumnIndex('time'))
        reminder.repeatCycle = resultSet.getString(resultSet.getColumnIndex('repeat_cycle')) as RepeatCycle
        reminder.enabled = resultSet.getLong(resultSet.getColumnIndex('enabled')) === 1
        reminder.notes = resultSet.getString(resultSet.getColumnIndex('notes'))
        reminder.createTime = resultSet.getString(resultSet.getColumnIndex('create_time'))
        reminders.push(reminder)
      }
      resultSet.close()
      return reminders
    } catch (err) {
      console.error('[DatabaseService] queryReminders failed:', JSON.stringify(err))
      return []
    }
  }

  async queryAllEnabledReminders(): Promise<HealthReminder[]> {
    if (!this.store) return []
    try {
      const predicates = new relationalStore.RdbPredicates('health_reminder')
      predicates.equalTo('enabled', 1)
      predicates.orderByAsc('date')
      const resultSet = await this.store.query(predicates)
      const reminders: HealthReminder[] = []
      while (resultSet.goToNextRow()) {
        const reminder = new HealthReminder()
        reminder.id = resultSet.getString(resultSet.getColumnIndex('id'))
        reminder.petId = resultSet.getString(resultSet.getColumnIndex('pet_id'))
        reminder.type = resultSet.getString(resultSet.getColumnIndex('type')) as ReminderType
        reminder.title = resultSet.getString(resultSet.getColumnIndex('title'))
        reminder.date = resultSet.getString(resultSet.getColumnIndex('date'))
        reminder.time = resultSet.getString(resultSet.getColumnIndex('time'))
        reminder.repeatCycle = resultSet.getString(resultSet.getColumnIndex('repeat_cycle')) as RepeatCycle
        reminder.enabled = true
        reminder.notes = resultSet.getString(resultSet.getColumnIndex('notes'))
        reminder.createTime = resultSet.getString(resultSet.getColumnIndex('create_time'))
        reminders.push(reminder)
      }
      resultSet.close()
      return reminders
    } catch (err) {
      console.error('[DatabaseService] queryAllEnabledReminders failed:', JSON.stringify(err))
      return []
    }
  }

  // ==================== 用户信息 CRUD ====================

  async insertUserInfo(user: UserInfo): Promise<boolean> {
    if (!this.store) return false
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        id: user.id,
        username: user.username,
        avatar: user.avatar,
        bio: user.bio,
        phone: user.phone,
        email: user.email,
        join_date: user.joinDate,
        update_time: user.updateTime
      }
      await this.store.insert('user_info', valueBucket)
      return true
    } catch (err) {
      console.error('[DatabaseService] insertUserInfo failed:', JSON.stringify(err))
      return false
    }
  }

  async updateUserInfo(user: UserInfo): Promise<boolean> {
    if (!this.store) return false
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        username: user.username,
        avatar: user.avatar,
        bio: user.bio,
        phone: user.phone,
        email: user.email,
        update_time: user.updateTime
      }
      const predicates = new relationalStore.RdbPredicates('user_info')
      predicates.equalTo('id', user.id)
      await this.store.update(valueBucket, predicates)
      return true
    } catch (err) {
      console.error('[DatabaseService] updateUserInfo failed:', JSON.stringify(err))
      return false
    }
  }

  async queryUserInfo(userId: string): Promise<UserInfo | null> {
    if (!this.store) return null
    try {
      const predicates = new relationalStore.RdbPredicates('user_info')
      predicates.equalTo('id', userId)
      const resultSet = await this.store.query(predicates)
      if (resultSet.goToFirstRow()) {
        const user = new UserInfo()
        user.id = resultSet.getString(resultSet.getColumnIndex('id'))
        user.username = resultSet.getString(resultSet.getColumnIndex('username'))
        user.avatar = resultSet.getString(resultSet.getColumnIndex('avatar'))
        user.bio = resultSet.getString(resultSet.getColumnIndex('bio'))
        user.phone = resultSet.getString(resultSet.getColumnIndex('phone'))
        user.email = resultSet.getString(resultSet.getColumnIndex('email'))
        user.joinDate = resultSet.getString(resultSet.getColumnIndex('join_date'))
        user.updateTime = resultSet.getString(resultSet.getColumnIndex('update_time'))
        resultSet.close()
        return user
      }
      resultSet.close()
      return null
    } catch (err) {
      console.error('[DatabaseService] queryUserInfo failed:', JSON.stringify(err))
      return null
    }
  }
}
