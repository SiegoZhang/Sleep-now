---
description: 
globs: 
alwaysApply: false
---
**产品需求文档 (PRD)—睡眠辅助iOS APP**

---

### 一.产品概述

这是一款许可用于帮助使用者轻松进入睡眠状态的iOS APP。产品核心功能是在设置的睡眠时间内，利用Apple的Family Control API封锁指定的应用，同时播放自定义的睡眠音乐，作为辅助。

---

### 二.核心功能

1. **睡眠时间设置**
   - 设置睡眠开始时间和结束时间
   - 在睡眠时间内，启动Family Control API，block使用者选择的应用

2. **block功能延迟关闭**
   - 如果使用者想提前关闭block，需要马上点击关闭按钮，提示“15分钟后可关闭”
   - 带有音乐导向，吸引使用者听睡眠音乐，而不是立即关闭

3. **睡眠音乐播放**
   - 全自定义睡眠音乐（可选择预置音乐）

4. **睡眠提醒 Notification**
   - 睡眠时间开始前，发送本地 notification，提醒用户该睡觉了
   - 睡眠时间结束，发送本地notification，问候用户早安

5. **UI体验**
   - 优秀的UI设计，配合可爱小猫吉祥物动画

6. **入门导向 Onboarding**
   - 首次使用有精致导向，解释功能

7. **数据保存方案**
   - 本地保存：使用CoreData管理用户设置
   - iCloud云备份：支持多设备同步

---

### 三.目标用户

- 有睡眠困难，希望抵制夜间浪费时间使用手机的人
- 喜欢听音乐轻松入睡的用户
- 定期睡眠筹划者

---

### 四.技术要求

- iOS平台，iOS 16+
- FamilyControls API实现APP封锁
- UserNotifications实现notification提醒
- SwiftUI进行UI编写
- CoreData管理本地数据
- iCloud同步支持

---

### 五.开发项目优先级 (MVP)

1. 睡眠时间设置+封锁应用（基本功能）
2. 睡眠音乐播放，预置音乐
3. 提醒notification
4. 基础版UI+onboarding
5. CoreData本地保存

---



