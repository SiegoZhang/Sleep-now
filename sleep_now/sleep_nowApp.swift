//
//  sleep_nowApp.swift
//  sleep_now
//
//  Created by 张曦戈 on 2025/4/11.
//

import SwiftUI
import Foundation
import CoreData

@main
struct sleep_nowApp: App {
    @StateObject private var shieldViewModel = ShieldViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // 确保在应用启动时注册自定义值转换器
        registerValueTransformers()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // 注册 NSSecureUnarchiveFromData 值转换器
    private func registerValueTransformers() {
        // 确保已注册 StringArrayTransformer
        ValueTransformer.setValueTransformer(
            StringArrayTransformer(),
            forName: NSValueTransformerName(StringArrayTransformer.transformerName)
        )
        
        // 确保已注册 IntArrayTransformer
        ValueTransformer.setValueTransformer(
            IntArrayTransformer(),
            forName: NSValueTransformerName(IntArrayTransformer.transformerName)
        )
    }
}
