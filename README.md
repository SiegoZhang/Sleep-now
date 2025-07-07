# sleep now - iOS Sleep Management App

<div align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue.svg" alt="Platform iOS" />
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5.0" />
  <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" alt="iOS 15.0+" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License" />
</div>

## Overview

**sleep now** helps you maintain healthy sleep habits by automatically blocking distracting apps during designated sleep hours. Built with Apple's Family Controls framework for reliable system-level app blocking.

## ✨ Features

- 🛡️ **Smart App Blocking** - Automatic app shielding during sleep hours
- 📅 **Flexible Scheduling** - Custom sleep schedules with weekly day selection
- 🔔 **Smart Notifications** - Sleep reminders and activation alerts
- 🎨 **Beautiful Interface** - Modern SwiftUI design with dark/light mode support
- 🌐 **Bilingual** - English and Chinese localization

## 🚀 Quick Start

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Apple Developer Account (for Family Controls)

### Installation
```bash
git clone https://github.com/SiegoZhang/Sleep.git
cd Sleep
open sleep_now.xcodeproj
```

### Setup
1. Configure Family Controls entitlement in your developer account
2. Set up App Group: `group.xg.sleep-now`
3. Build and run the project

## 🛠️ Tech Stack

- **SwiftUI** - UI framework
- **Family Controls** - App blocking
- **Core Data** - Local storage
- **UserNotifications** - Alerts and reminders

## 📖 Usage

1. Launch the app and grant Family Controls permission
2. Enable Sleep Mode and set your schedule
3. Select which apps to block during sleep hours
4. The app will automatically activate/deactivate based on your schedule

## 🔒 Privacy

- All data stays on your device
- No data collection or transmission
- Full user control over blocked apps

## 👨‍💻 Author

**SiegoZhang** - [@SiegoZhang](https://github.com/SiegoZhang)

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

---

<div align="center">
  <p>Made with ❤️ for better sleep habits</p>
</div> 