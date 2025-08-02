//
//  ContentView.swift
//  sleep_now
//

//

import SwiftUI
import FamilyControls

extension Color {
    var red: Double {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        uiColor.getRed(&red, green: nil, blue: nil, alpha: nil)
        return Double(red)
    }
    
    var green: Double {
        let uiColor = UIColor(self)
        var green: CGFloat = 0
        uiColor.getRed(nil, green: &green, blue: nil, alpha: nil)
        return Double(green)
    }
    
    var blue: Double {
        let uiColor = UIColor(self)
        var blue: CGFloat = 0
        uiColor.getRed(nil, green: nil, blue: &blue, alpha: nil)
        return Double(blue)
    }
}

struct ContentView: View {
    @StateObject var model = ShieldViewModel()
    @State private var showPlanListSheet = false
    @State private var hasAppeared = false
    @State private var userName: String = NSLocalizedString("default_user_name", comment: "Default user name")
    @State private var currentTime = Date()
    
    // Timer to update the time every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Full screen time spectrum
                GeometryReader { geometry in
                    ZStack {
                        // To make the gradient more pronounced, we create a single smooth gradient
                        // instead of stacking 60 individual, barely different color rectangles.
                        // This gradient smoothly transitions colors from 30 minutes in the past
                        // to 30 minutes in the future, with the current time's color at the center.
                        LinearGradient(
                            gradient: Gradient(colors: [
                                getColorForTimeOffset(-30),
                                getColorForTimeOffset(-15),
                                getColorForTimeOffset(0),
                                getColorForTimeOffset(15),
                                getColorForTimeOffset(30)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        
                        // Current time label on the right side
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 16) {
                                    Text(getCurrentTimeString())
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(getMotivationalQuote())
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                }                                

                                Spacer()
                            }
                            .padding(.trailing, 20)
                        }
                        .frame(height: geometry.size.height)
                    }
                }
                .ignoresSafeArea(.all)
                
                // Floating settings button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showPlanListSheet = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onAppear {
                currentTime = Date()
            }
            .sheet(isPresented: $showPlanListSheet) {
                SleepSettingsView(viewModel: model)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea(.all)
    }
    
    // Get colors for a specific hour
    private func getColorsForHour(_ hour: Int) -> [Color] {
        switch hour {
        case 0: // Midnight 12AM - Deep Night Sky
            return [
                Color(red: 7/255, green: 15/255, blue: 43/255),    // #070F2B
                Color(red: 27/255, green: 26/255, blue: 85/255),   // #1B1A55
                Color(red: 83/255, green: 92/255, blue: 145/255)  // #535C91
            ]
        case 1: // 1AM - Mysterious Purple Night
            return [
                Color(red: 27/255, green: 26/255, blue: 85/255),   // #1B1A55
                Color(red: 83/255, green: 92/255, blue: 145/255), // #535C91
                Color(red: 27/255, green: 26/255, blue: 85/255)   // #1B1A55
            ]
        case 2: // 2AM - Serene Blue Purple
            return [
                Color(red: 27/255, green: 26/255, blue: 85/255),   // #1B1A55
                Color(red: 83/255, green: 92/255, blue: 145/255), // #535C91
                Color(red: 146/255, green: 144/255, blue: 195/255) // #9290C3
            ]
        case 3: // 3AM - Deep Blue Night
            return [
                Color(red: 83/255, green: 92/255, blue: 145/255), // #535C91
                Color(red: 146/255, green: 144/255, blue: 195/255),// #9290C3
                Color(red: 83/255, green: 92/255, blue: 145/255)  // #535C91
            ]
        case 4: // 4AM - Pre-Dawn Night
            return [
                Color(red: 83/255, green: 92/255, blue: 145/255),  // #535C91
                Color(red: 146/255, green: 144/255, blue: 195/255),// #9290C3
                Color(red: 146/255, green: 144/255, blue: 195/255) // #9290C3
            ]
        case 5: // 5AM - Dawn Twilight
            return [
                Color(red: 0.04, green: 0.08, blue: 0.22), // Deep Night Blue
                Color(red: 0.35, green: 0.25, blue: 0.45), // Light Purple
                Color(red: 0.9, green: 0.5, blue: 0.3)     // Warm Orange
            ]
        case 6: // 6AM - Sunrise Pink Orange
            return [
                Color(red: 0.9, green: 0.5, blue: 0.3),    // Warm Orange
                Color(red: 1.0, green: 0.7, blue: 0.5),    // Light Orange
                Color(red: 1.0, green: 0.8, blue: 0.4),    // Golden Yellow
            ]
        case 7: // 7AM - Golden Morning Light
            return [
                Color(red: 1.0, green: 0.8, blue: 0.4),    // Golden Yellow
                Color(red: 1.0, green: 0.9, blue: 0.6),    // Light Gold
                Color(red: 0.4, green: 0.8, blue: 0.9),    // Fresh Blue
            ]
        case 8: // 8AM - Fresh Blue Green
            return [
                Color(red: 0.4, green: 0.8, blue: 0.9),    // Fresh Blue
                Color(red: 0.6, green: 0.9, blue: 1.0),    // Sky Blue
                Color(red: 0.5, green: 0.9, blue: 0.8),    // Mint Green
            ]
        case 9: // 9AM - Mint Green Blue
            return [
                Color(red: 0.5, green: 0.9, blue: 0.8),    // Mint Green
                Color(red: 0.7, green: 1.0, blue: 0.9),    // Light Mint
                Color(red: 0.3, green: 0.9, blue: 0.6),    // Emerald Green
            ]
        case 10: // 10AM - Emerald Fresh
            return [
                Color(red: 0.3, green: 0.9, blue: 0.6),    // Emerald Green
                Color(red: 0.5, green: 1.0, blue: 0.8),    // Light Green
                Color(red: 0.8, green: 1.0, blue: 0.4),    // Lemon Green
            ]
        case 11: // 11AM - Lemon Yellow Green
            return [
                Color(red: 0.8, green: 1.0, blue: 0.4),    // Lemon Green
                Color(red: 0.9, green: 1.0, blue: 0.6),    // Light Yellow Green
                Color(red: 0.7, green: 0.9, blue: 0.3)     // Deep Yellow Green
            ]
        case 12: // 12PM - Bright Sky Blue
            return [
                Color(red: 0.2, green: 0.7, blue: 1.0),    // Sky Blue
                Color(red: 0.4, green: 0.8, blue: 1.0),    // Bright Blue
                Color(red: 0.1, green: 0.6, blue: 0.9)     // Deep Sky Blue
            ]
        case 13: // 1PM - Azure Sky
            return [
                Color(red: 0.3, green: 0.6, blue: 1.0),    // Azure Blue
                Color(red: 0.5, green: 0.7, blue: 1.0),    // Light Azure
                Color(red: 0.2, green: 0.5, blue: 0.9)     // Deep Azure
            ]
        case 14: // 2PM - Cyan Blue Tone
            return [
                Color(red: 0.2, green: 0.5, blue: 0.9),    // Cyan Blue
                Color(red: 0.4, green: 0.6, blue: 1.0),    // Bright Cyan Blue
                Color(red: 0.1, green: 0.4, blue: 0.8)     // Deep Cyan Blue
            ]
        case 15: // 3PM - Warm Gold Blue
            return [
                Color(red: 0.6, green: 0.7, blue: 1.0),    // Gold Blue
                Color(red: 0.8, green: 0.8, blue: 1.0),    // Light Gold Blue
                Color(red: 0.4, green: 0.6, blue: 0.9)     // Deep Gold Blue
            ]
        case 16: // 4PM - Golden Hour
            return [
                Color(red: 1.0, green: 0.8, blue: 0.5),    // Golden
                Color(red: 1.0, green: 0.9, blue: 0.7),    // Light Gold
                Color(red: 0.9, green: 0.7, blue: 0.4)     // Deep Golden
            ]
        case 17: // 5PM - Warm Orange Gold
            return [
                Color(red: 1.0, green: 0.7, blue: 0.3),    // Warm Orange
                Color(red: 1.0, green: 0.8, blue: 0.5),    // Light Orange
                Color(red: 0.9, green: 0.6, blue: 0.2)     // Deep Orange
            ]
        case 18: // 6PM - Sunset Orange Red
            return [
                Color(red: 1.0, green: 0.5, blue: 0.2),    // Sunset Orange
                Color(red: 1.0, green: 0.7, blue: 0.4),    // Light Sunset Orange
                Color(red: 0.9, green: 0.4, blue: 0.1)     // Deep Sunset Orange
            ]
        case 19: // 7PM - Fiery Red Dusk
            return [
                Color(red: 1.0, green: 0.3, blue: 0.1),    // Fiery Red
                Color(red: 1.0, green: 0.5, blue: 0.3),    // Light Fiery Red
                Color(red: 0.8, green: 0.2, blue: 0.05)    // Deep Fiery Red
            ]
        case 20: // 8PM - Purple Red Dusk
            return [
                Color(red: 0.8, green: 0.2, blue: 0.4),    // Purple Red
                Color(red: 0.9, green: 0.4, blue: 0.6),    // Light Purple Red
                Color(red: 0.7, green: 0.1, blue: 0.3)     // Deep Purple Red
            ]
        case 21: // 9PM - Deep Purple Night
            return [
                Color(red: 0.4, green: 0.1, blue: 0.5),    // Deep Purple
                Color(red: 0.6, green: 0.3, blue: 0.7),    // Bright Purple
                Color(red: 0.3, green: 0.05, blue: 0.4)    // Very Deep Purple
            ]
        case 22: // 10PM - Blue Purple Night Sky
            return [
                Color(red: 27/255, green: 26/255, blue: 85/255),    // #1B1A55
                Color(red: 7/255, green: 15/255, blue: 43/255),     // #070F2B
                Color(red: 27/255, green: 26/255, blue: 85/255)     // #1B1A55
            ]
        case 23: // 11PM - Deep Night Blue Purple
            return [
                Color(red: 7/255, green: 15/255, blue: 43/255),     // #070F2B
                Color(red: 27/255, green: 26/255, blue: 85/255),    // #1B1A55
                Color(red: 7/255, green: 15/255, blue: 43/255)      // #070F2B
            ]
        default:
            return [
                Color(red: 0.02, green: 0.02, blue: 0.15),
                Color(red: 0.05, green: 0.05, blue: 0.25),
                Color(red: 0.01, green: 0.01, blue: 0.1)
            ]
        }
    }
    
    // Interpolate between two color arrays
    private func interpolateColors(from: [Color], to: [Color], progress: Double) -> [Color] {
        guard from.count == to.count else { return from }
        
        var result: [Color] = []
        
        for i in 0..<from.count {
            let fromComponents = getColorComponents(from[i])
            let toComponents = getColorComponents(to[i])
            
            let interpolatedRed = fromComponents.red + (toComponents.red - fromComponents.red) * progress
            let interpolatedGreen = fromComponents.green + (toComponents.green - fromComponents.green) * progress
            let interpolatedBlue = fromComponents.blue + (toComponents.blue - fromComponents.blue) * progress
            
            result.append(Color(red: interpolatedRed, green: interpolatedGreen, blue: interpolatedBlue))
        }
        
        return result
    }
    
    // Extract RGB components from Color
    private func getColorComponents(_ color: Color) -> (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red: Double(red), green: Double(green), blue: Double(blue))
    }

    private func getCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale.current
        return formatter.string(from: currentTime).lowercased()
    }

    private func getMotivationalQuote() -> String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 0...4:
            return NSLocalizedString("quote_0_4", comment: "Night quote")
        case 5...7:
            return NSLocalizedString("quote_5_7", comment: "Morning quote")
        case 8...11:
            return NSLocalizedString("quote_8_11", comment: "Morning-mid quote")
        case 12...13:
            return NSLocalizedString("quote_12_13", comment: "Afternoon quote")
        case 14...17:
            return NSLocalizedString("quote_14_17", comment: "Afternoon-evening quote")
        case 18...20:
            return NSLocalizedString("quote_18_20", comment: "Evening quote")
        case 21...23:
            return NSLocalizedString("quote_21_23", comment: "Night preparation quote")
        default:
            return NSLocalizedString("quote_default", comment: "Default quote")
        }
    }

    private func getColorThemeName(_ hour: Int) -> String {
        switch hour {
        case 0:
            return NSLocalizedString("theme_deep_night_blue", comment: "Deep night blue theme")
        case 1:
            return NSLocalizedString("theme_mysterious_purple_night", comment: "Mysterious purple night theme")
        case 2:
            return NSLocalizedString("theme_serene_blue_purple", comment: "Serene blue purple theme")
        case 3:
            return NSLocalizedString("theme_deep_blue_night", comment: "Deep blue night theme")
        case 4:
            return NSLocalizedString("theme_pre_dawn_night", comment: "Pre-dawn night theme")
        case 5:
            return NSLocalizedString("theme_dawn_twilight", comment: "Dawn twilight theme")
        case 6:
            return NSLocalizedString("theme_sunrise_pink_orange", comment: "Sunrise pink orange theme")
        case 7:
            return NSLocalizedString("theme_golden_morning_light", comment: "Golden morning light theme")
        case 8:
            return NSLocalizedString("theme_fresh_blue_green", comment: "Fresh blue green theme")
        case 9:
            return NSLocalizedString("theme_mint_green_blue", comment: "Mint green blue theme")
        case 10:
            return NSLocalizedString("theme_emerald_fresh", comment: "Emerald fresh theme")
        case 11:
            return NSLocalizedString("theme_lemon_yellow_green", comment: "Lemon yellow green theme")
        case 12:
            return NSLocalizedString("theme_bright_sky_blue", comment: "Bright sky blue theme")
        case 13:
            return NSLocalizedString("theme_azure_sky", comment: "Azure sky theme")
        case 14:
            return NSLocalizedString("theme_cyan_blue_tone", comment: "Cyan blue tone theme")
        case 15:
            return NSLocalizedString("theme_warm_gold_blue", comment: "Warm gold blue theme")
        case 16:
            return NSLocalizedString("theme_golden_hour", comment: "Golden hour theme")
        case 17:
            return NSLocalizedString("theme_warm_orange_gold", comment: "Warm orange gold theme")
        case 18:
            return NSLocalizedString("theme_sunset_orange_red", comment: "Sunset orange red theme")
        case 19:
            return NSLocalizedString("theme_fiery_red_dusk", comment: "Fiery red dusk theme")
        case 20:
            return NSLocalizedString("theme_purple_red_dusk", comment: "Purple red dusk theme")
        case 21:
            return NSLocalizedString("theme_deep_purple_night", comment: "Deep purple night theme")
        case 22:
            return NSLocalizedString("theme_blue_purple_night_sky", comment: "Blue purple night sky theme")
        case 23:
            return NSLocalizedString("theme_deep_night_blue_purple", comment: "Deep night blue purple theme")
        default:
            return NSLocalizedString("theme_unknown", comment: "Unknown theme")
        }
    }

    private func getColorForTimeOffset(_ offset: Int) -> Color {
        let calendar = Calendar.current
        let targetTime = calendar.date(byAdding: .minute, value: offset, to: currentTime)!
        let hour = calendar.component(.hour, from: targetTime)
        let minute = calendar.component(.minute, from: targetTime)
        let second = calendar.component(.second, from: targetTime)
        
        // Calculate progress within the current hour (0.0 to 1.0)
        let hourProgress = (Double(minute) + Double(second) / 60.0) / 60.0
        
        let currentColors = getColorsForHour(hour)
        let nextColors = getColorsForHour((hour + 1) % 24)
        
        // Interpolate between current and next hour colors
        let interpolatedColors = interpolateColors(from: currentColors, to: nextColors, progress: hourProgress)
        
        // Create a gradient and return the average color to match background
        let avgRed = (interpolatedColors[0].red + interpolatedColors[1].red + interpolatedColors[2].red) / 3.0
        let avgGreen = (interpolatedColors[0].green + interpolatedColors[1].green + interpolatedColors[2].green) / 3.0
        let avgBlue = (interpolatedColors[0].blue + interpolatedColors[1].blue + interpolatedColors[2].blue) / 3.0
        
        return Color(red: avgRed, green: avgGreen, blue: avgBlue)
    }

    private func getTimeLabel(_ offset: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let targetTime = Calendar.current.date(byAdding: .minute, value: offset, to: currentTime)!
        return formatter.string(from: targetTime).lowercased()
    }
}

#Preview {
    ContentView()
}

