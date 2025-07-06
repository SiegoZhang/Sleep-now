# Sleep - iOS Sleep Management App

<div align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue.svg" alt="Platform iOS" />
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5.0" />
  <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" alt="iOS 15.0+" />
  <img src="https://img.shields.io/badge/Xcode-14.0+-blue.svg" alt="Xcode 14.0+" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License" />
</div>

## Overview

**Sleep** is a comprehensive iOS application designed to help users maintain healthy sleep habits by automatically blocking distracting apps during designated sleep hours. Built with Apple's Family Controls framework, the app provides intelligent app blocking, customizable sleep schedules, and a beautiful user interface.

## ✨ Key Features

### 🛡️ Smart App Blocking
- **Automatic app shielding** during sleep hours using Apple's Family Controls
- **Selective app blocking** - choose which apps to block
- **Real-time monitoring** with automatic activation and deactivation
- **System-level blocking** that cannot be bypassed

### 📅 Flexible Sleep Scheduling
- **Custom sleep schedules** with start and end times
- **Weekly day selection** - choose specific days for sleep mode
- **Overnight schedule support** (e.g., 10 PM to 6 AM)
- **Multiple sleep plans** with easy switching

### 🔔 Smart Notifications
- **Sleep mode activation** notifications
- **Sleep time reminders** with customizable alerts
- **Interactive notifications** with app opening actions
- **Localized notification content** (English/Chinese)

### 💾 Data Management
- **Core Data integration** for persistent storage
- **User profile management** with customizable settings
- **Sleep plan synchronization** across app sessions
- **Automatic data backup** and recovery

### 🎨 Beautiful Interface
- **Modern SwiftUI design** with smooth animations
- **Dynamic color schemes** supporting light/dark modes
- **Intuitive time picker** with AM/PM format
- **Visual feedback** for all user interactions

## 📱 Screenshots

*[Add screenshots of your app here]*

## 🛠️ Technical Architecture

### Core Technologies
- **SwiftUI** - Modern declarative UI framework
- **Family Controls** - Apple's parental control framework
- **Core Data** - Local data persistence
- **UserNotifications** - Push notification management
- **Combine** - Reactive programming support

### Project Structure
```
sleep_now/
├── ViewModels/
│   └── ViewModel.swift          # Main app logic and state management
├── Views/
│   ├── ContentView.swift        # Main app interface
│   └── SleepSettingsView.swift  # Settings and configuration
├── Models/
│   └── SleepPlan.swift         # Sleep plan data model
├── Services/
│   ├── CoreDataManager.swift   # Data persistence layer
│   ├── SleepPlanService.swift  # Sleep plan business logic
│   └── ProfileService.swift    # User profile management
└── Resources/
    ├── en.lproj/               # English localization
    └── zh-Hans.lproj/          # Chinese localization
```

## 🚀 Installation

### Prerequisites
- iOS 15.0 or later
- Xcode 14.0 or later
- Apple Developer Account (for Family Controls entitlements)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/SiegoZhang/Sleep.git
   cd Sleep
   ```

2. **Open in Xcode**
   ```bash
   open sleep_now.xcodeproj
   ```

3. **Configure Family Controls**
   - Ensure your Apple Developer Account has Family Controls capability
   - The app requires special entitlements for Family Controls access
   - Set up App Groups for data sharing: `group.xg.sleep-now`

4. **Build and Run**
   - Select your target device
   - Build and run the project (⌘+R)

## 🔧 Configuration

### Family Controls Setup
The app requires Family Controls authorization to function properly:

```swift
// Request authorization (handled automatically)
try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
```

### App Groups
Configure the following App Group identifier:
- `group.xg.sleep-now`

### Required Entitlements
- `com.apple.developer.family-controls`
- `com.apple.security.application-groups`

## 📖 Usage Guide

### Setting Up Sleep Mode

1. **Launch the app** and grant necessary permissions
2. **Enable Sleep Mode** using the toggle switch
3. **Set sleep schedule** by configuring start and end times
4. **Select days** when sleep mode should be active
5. **Choose apps to block** during sleep hours

### Managing Sleep Plans

1. **Create multiple sleep plans** for different schedules
2. **Switch between plans** easily from the main interface
3. **Edit existing plans** to modify times or blocked apps
4. **Delete unwanted plans** from the settings

### Notifications

The app provides several notification types:
- **Sleep mode activation** alerts
- **Sleep time reminders** (5 minutes before)
- **Sleep period end** notifications

## 🔒 Privacy & Security

- **Local data storage** - all data stays on your device
- **No data collection** - the app doesn't collect or transmit personal data
- **System-level security** - uses Apple's Family Controls for reliable blocking
- **User control** - complete control over what gets blocked and when

## 🌐 Localization

The app supports multiple languages:
- **English** (en)
- **Chinese Simplified** (zh-Hans)

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- Family Controls entitlement

## 🐛 Known Issues

- Family Controls requires iOS 15.0 or later
- App blocking may not work in development mode without proper entitlements
- Some system apps cannot be blocked due to Apple's restrictions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**SiegoZhang**
- GitHub: [@SiegoZhang](https://github.com/SiegoZhang)

## 🙏 Acknowledgments

- Apple for providing the Family Controls framework
- The SwiftUI community for inspiration and support
- All contributors who helped improve this project

## 📞 Support

If you encounter any issues or have questions:
- Create an issue on GitHub
- Check the documentation
- Review the troubleshooting guide

---

<div align="center">
  <p>Made with ❤️ for better sleep habits</p>
</div> 