import SwiftUI

struct ProfileView: View {
    @State private var userName = "用户"
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var showingSettingsSheet = false
    @State private var selectedTheme = "系统"
    
    let themeOptions = ["系统", "浅色", "深色"]
    
    var body: some View {
        NavigationStack {
            List {
                // User profile section
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .symbolRenderingMode(.hierarchical)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            if isEditingName {
                                TextField("输入名称", text: $tempName)
                                    .onSubmit {
                                        if !tempName.isEmpty {
                                            userName = tempName
                                        }
                                        isEditingName = false
                                    }
                            } else {
                                Text(userName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Text("睡眠记录：12天")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if isEditingName {
                                if !tempName.isEmpty {
                                    userName = tempName
                                }
                                isEditingName = false
                            } else {
                                tempName = userName
                                isEditingName = true
                            }
                        }) {
                            Image(systemName: isEditingName ? "checkmark" : "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                // Stats section
                Section(header: Text("睡眠统计")) {
                    HStack {
                        StatView(title: "平均时长", value: "7.5小时", icon: "clock.fill", color: .blue)
                        Spacer()
                        StatView(title: "平均评分", value: "4.2分", icon: "star.fill", color: .yellow)
                        Spacer()
                        StatView(title: "连续记录", value: "5天", icon: "flame.fill", color: .orange)
                    }
                    .padding(.vertical, 10)
                }
                
                // Settings section
                Section(header: Text("设置")) {
                    NavigationLink(destination: Text("通知设置页面")) {
                        SettingRowView(icon: "bell.fill", title: "通知设置", color: .red)
                    }
                    
                    Button(action: {
                        showingSettingsSheet = true
                    }) {
                        SettingRowView(icon: "paintbrush.fill", title: "主题设置", color: .purple)
                    }
                    
                    NavigationLink(destination: Text("隐私政策页面")) {
                        SettingRowView(icon: "lock.fill", title: "隐私政策", color: .blue)
                    }
                    
                    NavigationLink(destination: Text("帮助中心页面")) {
                        SettingRowView(icon: "questionmark.circle.fill", title: "帮助中心", color: .green)
                    }
                }
                
                // App info section
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Logout section
                Section {
                    Button(action: {
                        // Logout action
                    }) {
                        HStack {
                            Spacer()
                            Text("退出登录")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showingSettingsSheet) {
                ThemeSettingsView(selectedTheme: $selectedTheme, themeOptions: themeOptions)
            }
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingRowView: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ThemeSettingsView: View {
    @Binding var selectedTheme: String
    let themeOptions: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(themeOptions, id: \.self) { theme in
                    Button(action: {
                        selectedTheme = theme
                    }) {
                        HStack {
                            Text(theme)
                            Spacer()
                            if selectedTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("主题设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileView()
} 