//
//  HistoryView.swift
//  MealTracker
//
//  Created by Carlos Campos on 12/4/25.
//

import SwiftUI

struct HistoryView: View {
    @State private var allEntries: [FoodEntry] = []
    
    // Group entries by day and compute totals
    private var groupedByDay: [(date: Date, totalCalories: Int, totalProtein: Int)] {
        let calendar = Calendar.current
        
        let groups = Dictionary(grouping: allEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        return groups
            .map { (date, entries) in
                let totalCalories = entries.reduce(0) { $0 + $1.calories }
                let totalProtein = entries.reduce(0) { $0 + $1.protein }
                return (date: date, totalCalories: totalCalories, totalProtein: totalProtein)
            }
            .sorted { $0.date > $1.date } // Most recent first
    }
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    var body: some View {
        List {
            if groupedByDay.isEmpty {
                Text("No history yet. Log some meals first.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(groupedByDay, id: \.date) { day in
                    VStack(alignment: .leading) {
                        Text(Self.dateFormatter.string(from: day.date))
                            .font(.headline)
                        Text("\(day.totalCalories) kcal • \(day.totalProtein) g protein")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("History")
        .onAppear {
            // Load all saved entries when History appears
            allEntries = FoodStorage.shared.loadEntries()
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
