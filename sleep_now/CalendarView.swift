import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var sleepRecords: [SleepRecord] = SleepRecord.sampleData
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday as first day
        return calendar
    }
    
    private var month: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: selectedDate)
    }
    
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else { return [] }
        let days = calendar.generateDates(inside: monthInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
        
        let firstWeekday = calendar.component(.weekday, from: days.first ?? selectedDate)
        let prefixDays = firstWeekday > 1 ? firstWeekday - 2 : 6
        
        // Previous month days
        var result: [Date] = []
        if let firstDay = days.first {
            for i in 0..<prefixDays {
                if let prevDay = calendar.date(byAdding: .day, value: -(prefixDays - i), to: firstDay) {
                    result.append(prevDay)
                }
            }
        }
        
        // Current month
        result.append(contentsOf: days)
        
        // Next month days (to make 42 days - 6 weeks)
        let suffixLength = 42 - result.count
        if suffixLength > 0, let lastDay = days.last {
            for i in 1...suffixLength {
                if let nextDay = calendar.date(byAdding: .day, value: i, to: lastDay) {
                    result.append(nextDay)
                }
            }
        }
        
        return result
    }
    
    private var sleepQualityForSelectedDate: Int? {
        sleepRecords.first(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) })?.quality
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Month header
                HStack {
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(month)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Weekday headers
                HStack {
                    ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { weekday in
                        Text(weekday)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 10)
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(days, id: \.self) { date in
                        DayView(date: date, selectedDate: $selectedDate, sleepRecords: sleepRecords)
                            .frame(height: 50)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Sleep quality for selected day
                VStack(spacing: 15) {
                    Text("睡眠质量")
                        .font(.headline)
                    
                    if let quality = sleepQualityForSelectedDate {
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= quality ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                            }
                        }
                        
                        Text(qualityDescription(quality))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    } else {
                        Text("暂无数据")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding()
            }
            .navigationTitle("睡眠日历")
        }
    }
    
    private func qualityDescription(_ quality: Int) -> String {
        switch quality {
        case 1: return "非常差"
        case 2: return "较差"
        case 3: return "一般"
        case 4: return "良好"
        case 5: return "优秀"
        default: return "未知"
        }
    }
}

struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date
    let sleepRecords: [SleepRecord]
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday as first day
        return calendar
    }
    
    private var day: String {
        let component = calendar.component(.day, from: date)
        return String(component)
    }
    
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isCurrentMonth: Bool {
        calendar.component(.month, from: date) == calendar.component(.month, from: selectedDate)
    }
    
    private var sleepQuality: Int? {
        sleepRecords.first(where: { calendar.isDate($0.date, inSameDayAs: date) })?.quality
    }
    
    var body: some View {
        Button(action: {
            selectedDate = date
        }) {
            VStack {
                Text(day)
                    .font(isSelected ? .headline : .body)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : (isCurrentMonth ? .primary : .secondary.opacity(0.5)))
                
                if let quality = sleepQuality {
                    HStack(spacing: 1) {
                        ForEach(1...min(quality, 3), id: \.self) { _ in
                            Circle()
                                .fill(sleepQualityColor(quality))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 36, height: 36)
            )
        }
    }
    
    private func sleepQualityColor(_ quality: Int) -> Color {
        switch quality {
        case 1, 2: return .red
        case 3: return .yellow
        case 4, 5: return .green
        default: return .gray
        }
    }
}

struct SleepRecord: Identifiable {
    let id = UUID()
    let date: Date
    let quality: Int // 1-5 scale
    
    static var sampleData: [SleepRecord] {
        let calendar = Calendar.current
        let today = Date()
        var records: [SleepRecord] = []
        
        for day in -10...5 {
            if let date = calendar.date(byAdding: .day, value: day, to: today) {
                let quality = Int.random(in: 1...5)
                records.append(SleepRecord(date: date, quality: quality))
            }
        }
        
        return records
    }
}

// Extension to help generate dates for the calendar
extension Calendar {
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(startingAfter: interval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}

#Preview {
    CalendarView()
} 