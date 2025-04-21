import SwiftUI

struct HomePage: View {
    @StateObject var model = ShieldViewModel()
    @State private var showPlanListSheet = false
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                // 这里会插入一个背景
                
                // 时间设置
                VStack {
                    ZStack {
                        // Circular timer display
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            .frame(width: 320, height: 320)
                        
                        // Sleep time duration arc
                        if model.isSleepModeEnabled {
                            CircleArcView(
                                durationAngle: calculateDurationAngle(start: model.startTime, end: model.endTime)
                            )
                            .frame(width: 320, height: 320)
                        }
                        
                        // Start time label
                        VStack {
                            Text("Start")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(formatTime(model.startTime))
                                .font(.system(size: 40, weight: .bold))
                        }
                        .offset(y: -80)
                        
                        // End time label
                        VStack {
                            Text(formatTime(model.endTime))
                                .font(.system(size: 40, weight: .bold))
                            Text("End")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .offset(y: 80)
                        
                        // Apps blocked indicator
                        if model.isSleepModeEnabled {
                            HStack(spacing: 4) {
                                Image(systemName: model.isShieldActive ? "lock.fill" : "lock.open.fill")
                                    .font(.system(size: 16))
                                //Text(model.isShieldActive ? "睡眠模式已激活" : "睡眠模式未激活")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(20)
                            .offset(y: 10)  // Centered position
                        } else {
                            HStack(spacing: 4) {
                                Text("去开启")
                                    .font(.system(size: 16, weight: .medium))
                                Image(systemName: "arrowshape.right.fill")
                                    .font(.system(size: 16))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(20)
                            .offset(y: 10)  // Centered position
                        }
                        

                        Button(action: {
                            showPlanListSheet = true
                        }) {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 320, height: 320)
                                .contentShape(Circle()) // 确保只有圆形区域响应点击
                        }
                        .buttonStyle(PlainButtonStyle()) // 去除按钮的默认样式
                        
                        // Edit button - now opens plan list
                        Button(action: {
                            showPlanListSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding(16)
                                .background(Color(white: 0.2))
                                .clipShape(Circle())
                        }
                        .offset(x: 150, y: -120)
                    }
                    
                                
                }
                
            }
            .navigationTitle("夜深了，该睡了")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .background(Color.black)
            .sheet(isPresented: $showPlanListSheet) {
                SleepSettingsView(viewModel: model)
            }
            
        }        
    }
    
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // New function to calculate the duration angle
    private func calculateDurationAngle(start: Date, end: Date) -> Double {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: start)
        let endComponents = calendar.dateComponents([.hour, .minute], from: end)

        guard let startHour = startComponents.hour, let startMinute = startComponents.minute,
              let endHour = endComponents.hour, let endMinute = endComponents.minute else {
            print("Error: Could not extract hour/minute components from dates.")
            return 0.0 
        }

        let startTimeInMinutes = Double(startHour * 60 + startMinute)
        let endTimeInMinutes = Double(endHour * 60 + endMinute)

        let durationMinutes: Double
        if endTimeInMinutes >= startTimeInMinutes {
            durationMinutes = endTimeInMinutes - startTimeInMinutes
        } else {
            // Time interval crosses midnight
            durationMinutes = (24.0 * 60.0 - startTimeInMinutes) + endTimeInMinutes
        }

        // Ensure duration doesn't exceed 24 hours (1440 minutes).
        let clampedDurationMinutes = min(durationMinutes, 24.0 * 60.0)

        // Calculate the angle. A full circle (360 degrees) corresponds to 24 hours (1440 minutes).
        let durationAngle = (clampedDurationMinutes / (24.0 * 60.0)) * 360.0
        
        // Avoid potential display issues with exactly 360 degrees
        return durationAngle >= 360.0 ? 359.99 : durationAngle
    }
}

// Updated CircleArcView to accept duration angle and draw clockwise from top
struct CircleArcView: View {
    var durationAngle: Double
    private let startAngleDegrees: Double = -90.0 // Start from the top (12 o'clock)

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2

                // Ensure durationAngle is non-negative
                let positiveDurationAngle = max(0, durationAngle)

                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(startAngleDegrees),
                    endAngle: .degrees(startAngleDegrees + positiveDurationAngle),
                    clockwise: false // Draw counter-clockwise
                )
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }
}

#Preview {
    HomePage()
} 
