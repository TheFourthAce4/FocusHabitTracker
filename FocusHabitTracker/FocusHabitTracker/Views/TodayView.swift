//
//  TodayView.swift
//  FocusHabitTracker
//
//  Created by Abdullah Alghabban on 10/29/25.
//

import SwiftUI
import SwiftData
import MapKit
import Combine

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @StateObject private var vm = TodayViewModel()
    
    @State private var showAdd = false
    @State private var showMapForHabit: Habit?
    @State private var editTarget: Habit?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if vm.isLoadingQuote {
                        ProgressView("Loading quote…")
                    } else if let q = vm.quote {
                        Text(q)
                            .italic()
                            .padding(.vertical, 4)
                    } else {
                        Text("“Stay consistent today.”").italic()
                    }
                }
                
                Section("Today") {
                    if habits.isEmpty {
                        Text("No habits yet. Tap + to add your first one.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(habits) { habit in
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.name)
                                    .font(.headline)
                                
                                HStack(spacing: 8) {
                                    // Frequency label
                                    Label(habit.frequency.capitalized, systemImage: "calendar")
                                        .font(.caption)
                                    
                                    // Priority
                                    if habit.priority == 1 {
                                        Label("High", systemImage: "exclamationmark.circle")
                                            .font(.caption)
                                    }
                                    
                                    // Date range indicator
                                    if habit.hasDateRange {
                                        Label("Date range", systemImage: "calendar.badge.clock")
                                            .font(.caption)
                                    }
                                    
                                    // Location indicator
                                    if habit.hasLocation {
                                        Label("Has location", systemImage: "mappin.and.ellipse")
                                            .font(.caption)
                                    }
                                }
                                .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Menu {
                                Button("Mark Done") {
                                    vm.toggleComplete(habit, context: context)
                                }
                                
                                Button("Edit") {
                                    editTarget = habit
                                }
                                
                                Button("Attach Location") {
                                    showMapForHabit = habit
                                }
                                
                                Button(role: .destructive) {
                                    vm.deleteHabit(habit, context: context)
                                } label: {
                                    Text("Delete")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Focus & Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: DashboardView()) { Image(systemName: "chart.bar.xaxis") }
                }
            }
            .task { await vm.fetchQuote() }
            .sheet(isPresented: $showAdd) {
                AddHabitView(vm: vm, editing: nil)
            }
            .sheet(item: $showMapForHabit) { habit in
                MapPickerView { coord in
                    vm.attachLocation(habit, lat: coord.latitude, lon: coord.longitude, context: context)
                }
            }
            
            .sheet(item: $editTarget) { habit in
                AddHabitView(vm: vm, editing: habit)
            }
        }
        
    }
}
