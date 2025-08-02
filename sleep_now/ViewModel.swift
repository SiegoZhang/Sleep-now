import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import UserNotifications

@MainActor
class ShieldViewModel: ObservableObject {
    @Published var selection = FamilyActivitySelection()
    @Published var startTime = Date()
    @Published var endTime = Date().addingTimeInterval(3600)
    @Published var isShieldActive = false
    @Published var isSleepModeEnabled = false
    @Published var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // Default to weekdays (Mon-Fri)
    
    // Sleep plan properties
    @Published var sleepPlans: [SleepPlan] = []
    @Published var selectedPlanId: UUID?
    @Published var showAppPicker = false
    
    private let store = ManagedSettingsStore()
    private let userDefaults = UserDefaults(suiteName: "group.xg.sleep-now")
    
    init() {
        loadSettings()
        setupNotifications()
        checkAndApplyShieldIfNeeded()
    }
    
    private func loadSettings() {
        if let savedStartTime = userDefaults?.object(forKey: "startTime") as? Date {
            startTime = savedStartTime
        }
        if let savedEndTime = userDefaults?.object(forKey: "endTime") as? Date {
            endTime = savedEndTime
        }
        if let savedSelection = userDefaults?.data(forKey: "selection"),
           let decodedSelection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: savedSelection) {
            selection = decodedSelection
        }
        isSleepModeEnabled = userDefaults?.bool(forKey: "isSleepModeEnabled") ?? false
        
        // Load selected days
        if let savedDays = userDefaults?.array(forKey: "selectedDays") as? [Int] {
            selectedDays = Set(savedDays)
        }
        
        // Load selected plan ID
        if let savedPlanIdString = userDefaults?.string(forKey: "selectedPlanId"),
           let savedPlanId = UUID(uuidString: savedPlanIdString) {
            selectedPlanId = savedPlanId
        }
    }
    
    private func saveSettings() {
        userDefaults?.set(startTime, forKey: "startTime")
        userDefaults?.set(endTime, forKey: "endTime")
        userDefaults?.set(isSleepModeEnabled, forKey: "isSleepModeEnabled")
        if let encodedSelection = try? JSONEncoder().encode(selection) {
            userDefaults?.set(encodedSelection, forKey: "selection")
        }
        
        // Save selected days
        userDefaults?.set(Array(selectedDays), forKey: "selectedDays")
    }
    
    // Public method to save just the app selection
    func saveSelection() {
        if let encodedSelection = try? JSONEncoder().encode(selection) {
            userDefaults?.set(encodedSelection, forKey: "selection")
            print("Selection updated: \(selection.applicationTokens.count) apps selected")
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
        
        // Add a notification action to open the app
        let openAppAction = UNNotificationAction(identifier: "OPEN_APP_ACTION",
                                                 title: NSLocalizedString("notification_open_app", comment: "Open app notification action"),
                                                 options: [.foreground])

        // Add the action to a category
        let category = UNNotificationCategory(identifier: "SLEEP_CATEGORY",
                                                  actions: [openAppAction],
                                                  intentIdentifiers: [],
                                                  options: [])

        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            print("Family Controls authorization granted")
        } catch {
            print("Family Controls authorization failed: \(error)")
        }
    }
    
    func toggleSleepMode() {
        isSleepModeEnabled.toggle()
        userDefaults?.set(isSleepModeEnabled, forKey: "isSleepModeEnabled")
        
        if isSleepModeEnabled {
            checkAndApplyShieldIfNeeded()
            // Schedule checking for time changes
            scheduleTimeChecks()
            
            // Send notification
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification_sleep_mode_enabled", comment: "Sleep mode enabled notification title")
            content.body = NSLocalizedString("notification_sleep_mode_body", comment: "Sleep mode enabled notification body")
            content.sound = .default
            content.categoryIdentifier = "SLEEP_CATEGORY"
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        } else {
            // Remove shield if it's active
            removeShield()
        }
    }
    
    private func scheduleTimeChecks() {
        // Cancel existing time checks
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkAndApplyShieldIfNeeded()
            }
        }
    }
    
    private func checkAndApplyShieldIfNeeded() {
        if !isSleepModeEnabled {
            // If sleep mode is disabled, make sure shield is removed
            if isShieldActive {
                removeShield()
            }
            return
        }
        
        // Check if current time is within sleep period
        let now = Date()
        let calendar = Calendar.current
        
        // Check if today is selected
        let currentWeekday = calendar.component(.weekday, from: now) // 1=Sunday, 2=Monday, ..., 7=Saturday
        // Adjust to match our array where 0=Sunday, 1=Monday, ..., 6=Saturday
        let adjustedWeekday = currentWeekday - 1
        
        if !selectedDays.contains(adjustedWeekday) {
            // Today is not selected, remove shield if active
            if isShieldActive {
                removeShield()
            }
            return
        }
        
        // Extract just the time components
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        // Create today's dates with those time components
        let todayStart = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: now) ?? now
        let todayEnd = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: now) ?? now
        
        // Check if we're within the sleep period
        let isWithinSleepPeriod: Bool
        
        if todayEnd > todayStart { // Normal case (e.g., 10PM to 6AM same day)
            isWithinSleepPeriod = now >= todayStart && now < todayEnd
        } else { // Overnight case (e.g., 10PM to 6AM next day)
            isWithinSleepPeriod = now >= todayStart || now < todayEnd
        }
        
        // Apply or remove shield based on time
        if isWithinSleepPeriod && !isShieldActive {
            applyShield()
        } else if !isWithinSleepPeriod && isShieldActive {
            removeShield()
        }
    }
    
    func applyShield() {
        // Only apply shield if sleep mode is enabled
        guard isSleepModeEnabled else { return }
        
        // Apply shield
        let shield = Shield(selectionToShield: selection)
        store.shield.applicationCategories = .all()
        store.shield.applications = shield.applicationTokens
        store.shield.webDomainCategories = .all()
        store.shield.webDomains = shield.webDomainTokens
        isShieldActive = true
        
        // 发送通知
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification_sleep_time_started", comment: "Sleep time started notification title")
        content.body = NSLocalizedString("notification_sleep_time_started_body", comment: "Sleep time started notification body")
        content.sound = .default
        content.categoryIdentifier = "SLEEP_CATEGORY"
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        print("🛡️ Shield applied")
    }
    
    func removeShield() {
        // 移除所有屏蔽
        store.shield.applicationCategories = nil
        store.shield.applications = nil
        store.shield.webDomainCategories = nil
        store.shield.webDomains = nil
        isShieldActive = false
        
        if isSleepModeEnabled {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification_sleep_time_ended", comment: "Sleep time ended notification title")
            content.body = NSLocalizedString("notification_sleep_time_ended_body", comment: "Sleep time ended notification body")
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
        
        print("🛡️ Shield removed")
    }
    
    func scheduleShield() {
        saveSettings()
        checkAndApplyShieldIfNeeded()
        
        // Cancel any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let now = Date()
        let calendar = Calendar.current
        
        // Extract just the time components from our dates
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        
        // Create today's dates with those time components
        let todayStart = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: now) ?? now
        
        // Calculate delays
        let delayToStart = todayStart.timeIntervalSince(now)
        
        // Schedule start notification if needed
        if isSleepModeEnabled {
            let timeUntilStart = delayToStart > 0 ? delayToStart : delayToStart + 86400
            
            // Start notification
            if timeUntilStart > 300 {
                let startContent = UNMutableNotificationContent()
                startContent.title = NSLocalizedString("notification_sleep_mode_starting", comment: "Sleep mode starting notification title")
                startContent.body = NSLocalizedString("notification_sleep_mode_starting_body", comment: "Sleep mode starting notification body")
                startContent.sound = .default
                
                let startTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilStart - 300, repeats: false)
                let startRequest = UNNotificationRequest(identifier: "startNotification", content: startContent, trigger: startTrigger)
                UNUserNotificationCenter.current().add(startRequest)
            }
        }
    }
    
    // Toggle day selection
    func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
        saveSettings()
        scheduleShield()
    }
    
    // Method to save current plan settings
    func updateCurrentPlan() {
        saveSettings()
        scheduleShield()
        print("Current sleep plan updated")
    }
}

// Helper struct to handle activity selection
struct Shield {
    let applicationTokens: Set<ApplicationToken>
    let webDomainTokens: Set<WebDomainToken>
    
    init(selectionToShield: FamilyActivitySelection) {
        self.applicationTokens = selectionToShield.applicationTokens
        self.webDomainTokens = selectionToShield.webDomainTokens
    }
}
