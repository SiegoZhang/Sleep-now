//
//  SleepShieldMonitor.swift
//  SleepShieldMonitor
//
//  Created by 张曦戈 on 2025/4/11.
//

import DeviceActivity
import SwiftUI

@main
struct SleepShieldMonitor: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
