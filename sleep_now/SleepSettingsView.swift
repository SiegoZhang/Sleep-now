import SwiftUI
import FamilyControls

struct SleepSettingsView: View {
    @ObservedObject var model: ShieldViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    // State variables to control the visibility of time pickers
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    
    // Create a formatter for AM/PM time format
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale.current
        return formatter
    }()
    
    init(viewModel: ShieldViewModel) {
        self.model = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(NSLocalizedString("schedule_section", comment: "Schedule section header"))) {
                    HStack {
                        Text(NSLocalizedString("start_time", comment: "Start time label"))
                        Spacer()
                        Text(timeFormatter.string(from: model.startTime))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation {
                                    showStartTimePicker.toggle()
                                    if showStartTimePicker {
                                        showEndTimePicker = false
                                    }
                                }
                            }
                    }
                    
                    if showStartTimePicker {
                        DatePicker("", selection: $model.startTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .onChange(of: model.startTime) { _ in
                                model.scheduleShield()
                            }
                            .padding(.vertical, 6)
                            .frame(maxHeight: 200)
                            .environment(\.locale, Locale.current)
                    }
                    
                    HStack {
                        Text(NSLocalizedString("end_time", comment: "End time label"))
                        Spacer()
                        Text(timeFormatter.string(from: model.endTime))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation {
                                    showEndTimePicker.toggle()
                                    if showEndTimePicker {
                                        showStartTimePicker = false
                                    }
                                }
                            }
                    }
                    
                    if showEndTimePicker {
                        DatePicker("", selection: $model.endTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .onChange(of: model.endTime) { _ in
                                model.scheduleShield()
                            }
                            .padding(.vertical, 6)
                            .frame(maxHeight: 200)
                            .environment(\.locale, Locale.current)
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(0..<7) { index in
                            let weekdayKeys = ["weekday_sunday", "weekday_monday", "weekday_tuesday", "weekday_wednesday", "weekday_thursday", "weekday_friday", "weekday_saturday"]
                            let weekday = NSLocalizedString(weekdayKeys[index], comment: "Weekday abbreviation")
                            Button(action: {
                                model.toggleDay(index)
                            }) {
                                Text(weekday)
                                    .font(.system(.body, design: .rounded))
                                    .frame(width: 36, height: 36)
                                    .background(model.selectedDays.contains(index) ? Color.blue : Color(UIColor.systemGray5))
                                    .foregroundColor(model.selectedDays.contains(index) ? .white : .primary)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text(NSLocalizedString("apps_to_block_section", comment: "Apps to block section header"))) {
                    Button {
                        Task {
                            await model.requestAuthorization()
                            model.showAppPicker = true
                        }
                    } label: {
                        HStack {
                            Text(NSLocalizedString("select_apps_to_block", comment: "Select apps to block button"))
                                .padding(.vertical, 8)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .background {
                        NavigationLink(isActive: $model.showAppPicker) {
                            AppsSelectionView()
                                .environmentObject(model)
                        } label: {
                            EmptyView()
                        }
                    }
                    
                    if !model.selection.applicationTokens.isEmpty {
                        Text(String(format: NSLocalizedString("apps_selected_format", comment: "Apps selected format"), model.selection.applicationTokens.count))
                            .foregroundColor(.green)
                    }
                }
                
                Section() {
                    if model.isSleepModeEnabled {
                        HStack {
                            Image(systemName: model.isShieldActive ? "lock.fill" : "lock.open.fill")
                            Text(model.isShieldActive ? NSLocalizedString("sleep_mode_activated", comment: "Sleep mode activated") : NSLocalizedString("sleep_mode_deactivated", comment: "Sleep mode deactivated"))
                            Spacer()
                            Text(statusDescription())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Button(action: {
                                model.toggleSleepMode()
                            }) {
                                Image(systemName: "power")
                                    .font(.system(size: 50, weight: .bold))
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.white)
                                    .background(model.isSleepModeEnabled ? Color.red : Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: (model.isSleepModeEnabled ? Color.red : Color.blue).opacity(0.3), radius: 8, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(model.isSleepModeEnabled ? NSLocalizedString("turn_off_sleep_mode", comment: "Turn off sleep mode") : NSLocalizedString("turn_on_sleep_mode", comment: "Turn on sleep mode"))
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(NSLocalizedString("sleep_schedule_settings", comment: "Sleep schedule settings title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "Done button")) {
                        model.updateCurrentPlan()
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            model.updateCurrentPlan()
        }
    }
    
    private func statusDescription() -> String {
        if model.isShieldActive {
            return NSLocalizedString("currently_in_sleep_time", comment: "Currently in sleep time")
        } else {
            return NSLocalizedString("waiting_for_sleep_time", comment: "Waiting for sleep time")
        }
    }
}

struct AppsSelectionView: View {
    @EnvironmentObject var model: ShieldViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        FamilyActivityPicker(selection: $model.selection)
            .navigationTitle(NSLocalizedString("select_activities", comment: "Select activities title"))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: model.selection) { _ in
                model.saveSelection()
            }
    }
}

struct SleepSettingsPreview: PreviewProvider {
    static var previews: some View {
        SleepSettingsView(viewModel: ShieldViewModel())
    }
} 
