import Foundation

struct SleepPlan: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let selectedDays: [Int]
    let blockedApps: [String]
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case startTime = "start_time"
        case endTime = "end_time"
        case selectedDays = "selected_days"
        case blockedApps = "blocked_apps"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // 自定义编码方法，处理时间格式
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        
        // 只编码时间部分，格式为 HH:MM:SS
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        try container.encode(timeFormatter.string(from: startTime), forKey: .startTime)
        try container.encode(timeFormatter.string(from: endTime), forKey: .endTime)
        
        try container.encode(selectedDays, forKey: .selectedDays)
        try container.encode(blockedApps, forKey: .blockedApps)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    // 自定义解码方法，处理时间格式
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        
        // 解析时间字符串
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        let startTimeString = try container.decode(String.self, forKey: .startTime)
        let endTimeString = try container.decode(String.self, forKey: .endTime)
        
        // 使用今天的日期创建完整的Date对象
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let startTime = timeFormatter.date(from: startTimeString) {
            self.startTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                          minute: calendar.component(.minute, from: startTime),
                                          second: calendar.component(.second, from: startTime),
                                          of: today) ?? Date()
        } else {
            self.startTime = Date()
        }
        
        if let endTime = timeFormatter.date(from: endTimeString) {
            self.endTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime),
                                        minute: calendar.component(.minute, from: endTime),
                                        second: calendar.component(.second, from: endTime),
                                        of: today) ?? Date()
        } else {
            self.endTime = Date()
        }
        
        selectedDays = try container.decode([Int].self, forKey: .selectedDays)
        blockedApps = try container.decode([String].self, forKey: .blockedApps)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        
        // 处理created_at和updated_at字段
        // 首先尝试作为ISO8601日期字符串解析
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            if let date = dateFormatter.date(from: createdAtString) {
                self.createdAt = date
            } else {
                // 如果ISO8601格式失败，尝试其他常见格式
                let fallbackFormatter = DateFormatter()
                fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let date = fallbackFormatter.date(from: createdAtString) {
                    self.createdAt = date
                } else {
                    self.createdAt = Date()
                }
            }
        } else {
            // 如果不是字符串，尝试作为时间戳
            self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            if let date = dateFormatter.date(from: updatedAtString) {
                self.updatedAt = date
            } else {
                // 如果ISO8601格式失败，尝试其他常见格式
                let fallbackFormatter = DateFormatter()
                fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let date = fallbackFormatter.date(from: updatedAtString) {
                    self.updatedAt = date
                } else {
                    self.updatedAt = Date()
                }
            }
        } else {
            // 如果不是字符串，尝试作为时间戳
            self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        }
    }
    
    init(id: UUID = UUID(),
         startTime: Date,
         endTime: Date,
         selectedDays: [Int] = [1, 2, 3, 4, 5], // Default to weekdays
         blockedApps: [String] = [],
         isActive: Bool = true,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.selectedDays = selectedDays
        self.blockedApps = blockedApps
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
} 