//
//  ContentView.swift
//  sleep_now
//
//  Created by 张曦戈 on 2025/4/11.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @StateObject var model = ShieldViewModel()
    @State private var selectedTab = 0
    @ObservedObject private var playerViewModel = MusicPlayerViewModel.shared
    @State private var showMusicSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area with tabs
            ZStack {
                switch selectedTab {
                case 0:
                    HomePage()
                case 1:
                    NavigationStack {
                        CalendarView()
                    }
                case 2:
                    NavigationStack {
                        ProfileView()
                    }
                default:
                    HomePage()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Music player appears between content and tab bar
            if playerViewModel.currentTrack != nil && selectedTab == 0 {
                Button(action: {
                    showMusicSheet = true
                }) {
                    MusicPlayerView()
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Tab bar at bottom
            HStack {
                ForEach([0, 1, 2], id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: getTabIcon(index))
                                .font(.system(size: 22))
                            Text(getTabTitle(index))
                                .font(.system(size: 12))
                        }
                        .foregroundColor(selectedTab == index ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            .background(Color.black)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.black)
        .sheet(isPresented: $showMusicSheet) {
            MusicView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func getTabIcon(_ index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "calendar"
        case 2: return "person.fill"
        default: return "house.fill"
        }
    }
    
    private func getTabTitle(_ index: Int) -> String {
        switch index {
        case 0: return "首页"
        case 1: return "日历"
        case 2: return "我的"
        default: return "首页"
        }
    }
}

#Preview {
    ContentView()
}

