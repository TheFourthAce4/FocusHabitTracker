//
//  DashboardView.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    
    // all habits in the system
    @Query private var habits: [Habit]
    
    // all logs, newest first
    @Query(sort: \HabitLog.date, order: .reverse) private var logs: [HabitLog]
    
    private let cal = Calendar.current
    
    var body: some View {
        List {
            todaySummarySection
            perHabitStatsSection
            recentCompletionsSection
        }
        .navigationTitle("Dashboard")
    }
}

private extension DashboardView {
    // today summary
    var todaySummarySection: some View {
        Section("Today") {
            let due = todayDueHabits
            let completed = todayCompletedHabits
            let totalDue = due.count
            let totalCompleted = completed.count
            let rate = completionRateToday
            
            if totalDue == 0 {
                Text("No habits due today.")
                    .foregroundStyle(.secondary)
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Habits due today: \(totalDue)")
                        Text("Completed: \(totalCompleted)")
                        Text("Completion rate: \(Int(rate * 100))%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                
                ProgressView(value: rate) {
                    Text("Progress")
                } currentValueLabel: {
                    Text("\(Int(rate * 100))%")
                }
            }
        }
    }
    
    // per-habit stats: total completions + streak
    var perHabitStatsSection: some View {
        Section("Per Habit Stats") {
            if habits.isEmpty {
                Text("No habits yet. Add some on the main screen.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(habits) { habit in
                    let total = totalCompletions(for: habit)
                    let streak = currentStreak(for: habit)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(habit.name)
                                .font(.headline)
                            if habit.priority == 1 {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Label("Completions: \(total)",
                                  systemImage: "checkmark.circle")
                            Label("Streak: \(streak) day\(streak == 1 ? "" : "s")",
                                  systemImage: "flame.fill")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // recent completions list (last few logs)
    var recentCompletionsSection: some View {
        Section("Recent Completions") {
            if logs.isEmpty {
                Text("No completions logged yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(recentLogsLimited) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habitName(for: log) ?? "Habit")
                            .font(.subheadline)
                            .bold()
                        Text(log.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(log.date, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
}

private extension DashboardView {
    // habits due today
    var todayDueHabits: [Habit] {
        habits.filter { $0.isDueToday(Date()) }
    }
    
    // habits that have at least one completion log today
    var todayCompletedHabits: [Habit] {
        let todayLogs = logs.filter { cal.isDateInToday($0.date) }
        let idsCompletedToday = Set(todayLogs.map { $0.habitID })
        return todayDueHabits.filter { idsCompletedToday.contains($0.id) }
    }
    
    // completion rate for today between 0 and 1
    var completionRateToday: Double {
        let total = todayDueHabits.count
        guard total > 0 else { return 0 }
        return Double(todayCompletedHabits.count) / Double(total)
    }
    
    // limit recent list
    var recentLogsLimited: [HabitLog] {
        Array(logs.prefix(20))
    }
    
    // name lookup for a habit from a log
    func habitName(for log: HabitLog) -> String? {
        habits.first(where: { $0.id == log.habitID })?.name
    }
    
    // all logs for a given habit
    func logs(for habit: Habit) -> [HabitLog] {
        logs.filter { $0.habitID == habit.id }
    }
    
    // total completions for a habit
    func totalCompletions(for habit: Habit) -> Int {
        logs(for: habit).count
    }
    
    // current streak: how many consecutive days (including today if completed)
    func currentStreak(for habit: Habit) -> Int {
        let habitLogs = logs(for: habit).sorted { $0.date > $1.date }
        guard !habitLogs.isEmpty else { return 0 }
        
        var streak = 0
        var offset = 0
        
        while true {
            guard let targetDate = cal.date(byAdding: .day, value: -offset, to: Date()) else {
                break
            }
            let hasLog = habitLogs.contains { log in
                cal.isDate(log.date, inSameDayAs: targetDate)
            }
            if hasLog {
                streak += 1
                offset += 1
            } else {
                break
            }
        }
        return streak
    }
}
