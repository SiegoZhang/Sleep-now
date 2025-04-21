//
//  sleep_nowApp.swift
//  sleep_now
//
//  Created by 张曦戈 on 2025/4/11.
//

import SwiftUI
import Foundation

// Global user manager to store the current user ID
class UserManager {
    static let shared = UserManager()
    let currentUserId = UUID(uuidString: "3ab6853f-b3ac-4364-9743-992c853f8026")!
    
    private init() {} // Singleton
}

@main
struct sleep_nowApp: App {
    @StateObject private var shieldViewModel = ShieldViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}
