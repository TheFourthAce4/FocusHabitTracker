//
//  FocusHabitTrackerApp.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import SwiftUI
import SwiftData

@main
struct FocusHabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        .modelContainer(for: [Habit.self, HabitLog.self])
    }
}
