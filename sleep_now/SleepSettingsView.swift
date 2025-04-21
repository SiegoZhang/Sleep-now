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
        return formatter
    }()
    
    init(viewModel: ShieldViewModel) {
        self.model = viewModel
        
        // Customize form appearance for dark theme
        UITableView.appearance().backgroundColor = .black
        UITableViewCell.appearance().backgroundColor = .black
        
        // Make section headers white
        UITableView.appearance().sectionHeaderTopPadding = 20
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("🕒 Schedule").foregroundColor(.white)) {
                        HStack {
                            Text("Start time:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(timeFormatter.string(from: model.startTime))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
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
                        .listRowBackground(Color.black)
                        
                        if showStartTimePicker {
                            DatePicker("", selection: $model.startTime, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .onChange(of: model.startTime) { _ in
                                    model.scheduleShield()
                                }
                                .padding(.vertical, 6)
                                .frame(maxHeight: 200)
                                .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                                .colorScheme(.dark)
                                .listRowBackground(Color.black)
                        }
                        
                        HStack {
                            Text("End time:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(timeFormatter.string(from: model.endTime))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
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
                        .listRowBackground(Color.black)
                        
                        if showEndTimePicker {
                            DatePicker("", selection: $model.endTime, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .onChange(of: model.endTime) { _ in
                                    model.scheduleShield()
                                }
                                .padding(.vertical, 6)
                                .frame(maxHeight: 200)
                                .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                                .colorScheme(.dark)
                                .listRowBackground(Color.black)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(0..<7) { index in
                                let weekday = ["S", "M", "T", "W", "T", "F", "S"][index]
                                Button(action: {
                                    model.toggleDay(index)
                                }) {
                                    Text(weekday)
                                        .font(.system(.body, design: .rounded))
                                        .frame(width: 36, height: 36)
                                        .background(model.selectedDays.contains(index) ? Color.blue : Color(white: 0.2))
                                        .foregroundColor(model.selectedDays.contains(index) ? .white : .gray)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.black)
                    }
                    
                    Section(header: Text("📱 要屏蔽的应用").foregroundColor(.white)) {
                        Button {
                            Task {
                                await model.requestAuthorization()
                                model.showAppPicker = true
                            }
                        } label: {
                            HStack {
                                Text("选择要屏蔽的应用")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.black)
                        .background(
                            NavigationLink(isActive: $model.showAppPicker) {
                                AppsSelectionView()
                                    .environmentObject(model)
                            } label: {
                                EmptyView()
                            }
                        )
                        
                        if !model.selection.applicationTokens.isEmpty {
                            Text("已选择 \(model.selection.applicationTokens.count) 个应用")
                                .foregroundColor(.green)
                                .listRowBackground(Color.black)
                        }
                    }
                    
                    Section(header: Text("🎵 睡眠音乐").foregroundColor(.white)) {
                        Button {
                            model.showMusicPicker = true
                        } label: {
                            HStack {
                                Text("选择睡眠音乐")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.black)
                        .background(
                            NavigationLink(isActive: $model.showMusicPicker) {
                                SleepMusicView()
                                    .environmentObject(model)
                            } label: {
                                EmptyView()
                            }
                        )
                        
                        if let currentTrack = model.selectedSleepMusic {
                            HStack {
                                Image(systemName: currentTrack.coverImage)
                                    .foregroundColor(.blue)
                                Text(currentTrack.title)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(currentTrack.artist)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .listRowBackground(Color.black)
                        } else {
                            Text("未选择音乐")
                                .foregroundColor(.gray)
                                .listRowBackground(Color.black)
                        }
                    }
                    
                    Section(header: Text("睡眠模式").foregroundColor(.white)) {
                        Toggle(isOn: $model.isSleepModeEnabled) {
                            Text("开启睡眠模式")
                                .foregroundColor(.white)
                        }
                        .onChange(of: model.isSleepModeEnabled) { _ in
                            model.toggleSleepMode()
                        }
                        .listRowBackground(Color.black)
                        
                        if model.isSleepModeEnabled {
                            HStack {
                                Image(systemName: model.isShieldActive ? "lock.fill" : "lock.open.fill")
                                    .foregroundColor(.white)
                                Text(model.isShieldActive ? "睡眠模式已激活" : "睡眠模式未激活")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(statusDescription())
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .listRowBackground(Color.black)
                        }
                    }
                    
                   
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("设置睡眠计划")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        model.updateCurrentPlan()
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
        }
        .onDisappear {
            model.updateCurrentPlan()
        }
        .preferredColorScheme(.dark)
    }
    
    private func statusDescription() -> String {
        if model.isShieldActive {
            return "当前在睡眠时间内"
        } else {
            return "等待睡眠时间"
        }
    }
}

struct AppsSelectionView: View {
    @EnvironmentObject var model: ShieldViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        FamilyActivityPicker(selection: $model.selection)
            .navigationTitle("选取活动")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: model.selection) { _ in
                model.saveSelection()
            }
            .preferredColorScheme(.dark)
    }
}

struct SleepSettingsPreview: PreviewProvider {
    static var previews: some View {
        SleepSettingsView(viewModel: ShieldViewModel())
            .preferredColorScheme(.dark)
    }
} 
