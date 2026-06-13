//
//  Models.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String

    var frequency: String
    var selectedWeekdays: [Int]?
    var startDate: Date?
    var endDate: Date?
    var priority: Int
    var createdAt: Date
    var latitude: Double?
    var longitude: Double?
    var hasDateRange: Bool {
        startDate != nil || endDate != nil
    }

    init(
        id: UUID = .init(),
        name: String,
        frequency: String = "daily",
        selectedWeekdays: [Int]? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        priority: Int = 0,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.selectedWeekdays = selectedWeekdays
        self.startDate = startDate
        self.endDate = endDate
        self.priority = priority
        self.createdAt = .now
        self.latitude = latitude
        self.longitude = longitude
    }

    var hasLocation: Bool { latitude != nil && longitude != nil }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func isDueToday(_ date: Date = .now) -> Bool {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)

        if let start = startDate, date < start { return false }
        if let end = endDate, date > end { return false }

        switch frequency {
        case "daily":
            return true

        case "weekly":
            return cal.component(.weekday, from: createdAt) == weekday

        case "monthly":
            return cal.component(.day, from: createdAt) ==
                   cal.component(.day, from: date)

        case "weekdays":
            return selectedWeekdays?.contains(weekday) ?? false

        default:
            return true
        }
    }
}

@Model
final class HabitLog {
    @Attribute(.unique) var id: UUID
    var habitID: UUID
    var date: Date

    init(id: UUID = .init(), habitID: UUID, date: Date = .now) {
        self.id = id
        self.habitID = habitID
        self.date = date
    }
}
