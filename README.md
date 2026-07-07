# 🐾 宠物成长日记 (catAI)

基于 **HarmonyOS NEXT** 开发的宠物成长管理应用，帮助主人记录爱宠的每一个成长瞬间。

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 🐶 **多宠物档案** | 支持同时管理多只宠物，每只宠物拥有独立档案 |
| 📝 **成长记录** | 记录体重、身高等成长数据，支持增删改查 |
| 📊 **成长图表** | 使用 Canvas 自绘制图表，可视化展⽰体重/身⾼变化趋势 |
| 📸 **时间轴相册** | 按日期自动排列宠物照片，形成成长时间线 |
| 💉 **健康提醒** | 疫苗、驱虫、体检等定时健康提醒，支持循环重复 |
| 🔔 **通知服务** | 集成系统通知，到时间自动推送提醒 |
| 📱 **服务卡片** | 桌面小部件展⽰今日待办事项 |
| ⚡ **LazyForEach** | 成长记录列表懒加载，优化渲染性能 |

## 🏗️ 技术架构

- **开发框架**: ArkTS + ArkUI (Stage 模型)
- **编译 SDK**: HarmonyOS 6.1.1(24)
- **数据存储**: 关系型数据库 (RelationalStore)
- **通知服务**: @kit.NotificationKit
- **状态管理**: @Observed / @ObjectLink
- **构建工具**: Hvigor

## 📁 项目结构

```
catAI/
├── AppScope/                     # 应用全局配置
│   ├── app.json5                # Bundle名称、版本号
│   └── resources/               # 全局资源
├── entry/                        # 主模块
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/     # 应用入口 Ability
│       │   ├── pages/            # 页面
│       │   │   ├── Index.ets              # 首页仪表盘
│       │   │   ├── PetProfilePage.ets     # 宠物档案管理
│       │   │   ├── GrowthRecordPage.ets   # 成长记录+图表
│       │   │   ├── TimelinePage.ets       # 时间轴相册
│       │   │   ├── HealthReminderPage.ets # 健康提醒管理
│       │   │   └── SettingsPage.ets       # 设置页
│       │   ├── model/            # 数据模型
│       │   │   ├── PetInfo.ets            # 宠物信息模型
│       │   │   ├── GrowthRecord.ets       # 成长记录模型
│       │   │   └── HealthReminder.ets     # 健康提醒模型
│       │   ├── viewmodel/        # 状态管理
│       │   │   ├── PetViewModel.ets
│       │   │   ├── GrowthRecordViewModel.ets
│       │   │   └── ReminderViewModel.ets
│       │   ├── components/       # 可复用组件
│       │   │   ├── PetCard.ets            # 宠物卡片
│       │   │   ├── PetSelector.ets        # 宠物切换器
│       │   │   ├── GrowthChart.ets        # Canvas 成长图表
│       │   │   ├── PhotoUpload.ets        # 照片上传
│       │   │   ├── TimelineItem.ets       # 时间轴条目
│       │   │   ├── ReminderCard.ets       # 提醒卡片
│       │   │   └── AddRecordDialog.ets    # 添加记录弹窗
│       │   ├── service/          # 服务层
│       │   │   ├── DatabaseService.ets    # 数据库服务
│       │   │   └── NotificationService.ets# 通知服务
│       │   └── common/           # 工具类
│       │       └── Utils.ets             # 日期/图片工具
│       └── resources/            # 模块资源
├── hvigorfile.ts
├── build-profile.json5
└── oh-package.json5
```

## 🚀 快速开始

### 环境要求

- **DevEco Studio**: 5.0+
- **HarmonyOS SDK**: API 12+ (6.1.1)
- **Node.js**: 18+

### 运行项目

1. 用 DevEco Studio 打开本项目
2. 等待依赖同步完成（ohpm install）
3. 连接设备或启动模拟器
4. 点击 ▶ 运行

### 推送至 GitHub

```bash
cd D:\hongmengOS\AllApp\catAI2
git add .
git commit -m "feat: init HarmonyOS Pet Growth Diary project"
git remote add origin https://github.com/<你的用户名>/catAI.git
git branch -M main
git push -u origin main
```

## 📋 开发路线

- [x] 项目骨架搭建
- [x] 数据模型层 (Model)
- [x] 状态管理层 (ViewModel)
- [x] UI 组件库 (Components)
- [x] 宠物档案 CRUD
- [x] 成长记录增删 + 图表
- [x] 时间轴相册
- [x] 健康提醒 + 通知
- [ ] 服务卡片 (桌面小部件)
- [ ] 云同步 (Cloud DB + Cloud Storage)

## 📝 License

MIT License

---

🐾 记录爱宠成长，珍藏每一刻美好回忆
