//
//  ViewModels.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import SwiftUI
import SwiftData
import Combine
import CoreLocation

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var quote: String?
    @Published var isLoadingQuote = false
    @Published var errorMessage: String?
    
    func fetchQuote() async {
        isLoadingQuote = true
        defer { isLoadingQuote = false }
        do {
            quote = try await QuoteService.fetchDailyQuote()
        } catch {
            quote = "Focus on small wins today."
            errorMessage = "Couldn’t load quote."
        }
    }
    
    func addHabit(
            name: String,
            freq: String,
            priority: Int,
            weekdays: [Int]?,
            start: Date?,
            end: Date?,
            coord: CLLocationCoordinate2D?,
            context: ModelContext
        ) {
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

            let h = Habit(
                name: name,
                frequency: freq,
                selectedWeekdays: weekdays,
                startDate: start,
                endDate: end,
                priority: priority,
                latitude: coord?.latitude,
                longitude: coord?.longitude
            )
            context.insert(h)
            try? context.save()
        }
    func attachLocation(_ habit: Habit, lat: Double, lon: Double, context: ModelContext) {
        habit.latitude = lat
        habit.longitude = lon
        try? context.save()
    }
    
    func toggleComplete(_ habit: Habit, context: ModelContext) {
        let log = HabitLog(habitID: habit.id)
        context.insert(log)
        try? context.save()
    }
    func deleteHabit(_ habit: Habit, context: ModelContext) {
        let habitID = habit.id
        let fetch = FetchDescriptor<HabitLog>(predicate: #Predicate { $0.habitID == habitID })
        if let logs = try? context.fetch(fetch) {
            logs.forEach { context.delete($0) }
        }
        context.delete(habit)
        try? context.save()
    }
}
