//
//  AddHabitView.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import SwiftUI
import SwiftData
import CoreLocation

struct AddHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: TodayViewModel
    
    var editing: Habit?
    
    @State private var name = ""
    @State private var frequency = "daily"        // daily, weekly, monthly, weekdays
    @State private var priorityHigh = false
    
    // weekday selection (1 = Sun... 7 = Sat)
    @State private var weekdaySet = Set<Int>()
    
    // date range
    @State private var useDateRange = false
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    
    // location
    @State private var pendingCoord: CLLocationCoordinate2D? = nil
    @State private var showMap = false
    
    @State private var didLoadEditing = false
    var body: some View {
        NavigationStack {
            Form {
                // BASICS
                Section("Basics") {
                    TextField("Habit name", text: $name)
                    
                    Picker("Frequency", selection: $frequency) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                        Text("Weekdays").tag("weekdays")
                    }
                    .pickerStyle(.segmented)
                    
                    if frequency == "weekdays" {
                        WeekdaySelector(selection: $weekdaySet)
                    }
                    
                    Toggle("High Priority", isOn: $priorityHigh)
                }
                
                // DATE RANGE
                Section("Date Range") {
                    Toggle("Use date range", isOn: $useDateRange.animation())
                    
                    if useDateRange {
                        DatePicker(
                            "From",
                            selection: nonOptional($startDate, .now),
                            displayedComponents: .date
                        )
                        DatePicker(
                            "To",
                            selection: nonOptional($endDate, .now),
                            displayedComponents: .date
                        )
                        
                        if let s = startDate, let e = endDate, s > e {
                            Text("Start date must be before end date.")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                // LOCATION
                Section("Location") {
                    HStack {
                        if let c = currentCoordPreview {
                            Text("Lat \(c.latitude, format: .number.precision(.fractionLength(4)))  Lon \(c.longitude, format: .number.precision(.fractionLength(4)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("No location attached")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Attach Location") {
                            showMap = true
                        }
                    }
                }
                
                // SAVE
                Section {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle(editing == nil ? "Add Habit" : "Edit Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showMap) {
                MapPickerView { coord in
                    pendingCoord = coord
                }
            }
            .onAppear {
                guard !didLoadEditing, let habit = editing else { return }
                didLoadEditing = true
                
                // prefill fields from existing habit
                name = habit.name
                frequency = habit.frequency
                priorityHigh = (habit.priority == 1)
                
                if let days = habit.selectedWeekdays {
                    weekdaySet = Set(days)
                } else {
                    weekdaySet = []
                }
                
                if let s = habit.startDate {
                    startDate = s
                    useDateRange = true
                }
                if let e = habit.endDate {
                    endDate = e
                    useDateRange = true
                }
                
                if let coord = habit.coordinate {
                    pendingCoord = coord
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if frequency == "weekdays", weekdaySet.isEmpty { return false }
        if useDateRange, let s = startDate, let e = endDate, s > e { return false }
        return true
    }
    
    private var currentCoordPreview: CLLocationCoordinate2D? {
        pendingCoord
    }
    
    private func saveHabit() {
        let weekdays = (frequency == "weekdays") ? Array(weekdaySet).sorted() : nil
        let start = useDateRange ? startDate : nil
        let end = useDateRange ? endDate : nil
        let priority = priorityHigh ? 1 : 0
        
        if let habit = editing {
            // EDIT EXISTING HABIT
            habit.name = name
            habit.frequency = frequency
            habit.selectedWeekdays = weekdays
            habit.startDate = start
            habit.endDate = end
            habit.priority = priority
            
            if let coord = pendingCoord {
                habit.latitude = coord.latitude
                habit.longitude = coord.longitude
            }
            
            try? context.save()
        } else {
            // CREATE NEW HABIT
            vm.addHabit(
                name: name,
                freq: frequency,
                priority: priority,
                weekdays: weekdays,
                start: start,
                end: end,
                coord: pendingCoord,
                context: context
            )
        }
        
        dismiss()
    }
    
    private func nonOptional(_ source: Binding<Date?>, _ defaultValue: Date) -> Binding<Date> {
        Binding<Date>(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
    
    // simple weekday selector
    private struct WeekdaySelector: View {
        @Binding var selection: Set<Int>
        private let labels = [1:"Sun",2:"Mon",3:"Tue",4:"Wed",5:"Thu",6:"Fri",7:"Sat"]
        
        var body: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(1...7, id: \.self) { d in
                    let isOn = selection.contains(d)
                    Text(labels[d] ?? "")
                        .font(.caption)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(isOn ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isOn ? Color.accentColor : Color.secondary.opacity(0.5), lineWidth: 1)
                        )
                        .cornerRadius(8)
                        .onTapGesture {
                            if isOn { selection.remove(d) } else { selection.insert(d) }
                        }
                }
            }
            .padding(.top, 4)
        }
    }
}
