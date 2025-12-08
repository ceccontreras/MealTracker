//
//  DayDetailView.swift
//  MealTracker
//
//  Created by Carlos Campos on 12/7/25.
//

import SwiftUI

struct DayDetailView: View {
    let date: Date
    let entries: [FoodEntry]
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full   // e.g. "Thursday, December 5, 2025"
        return df
    }()
    
    private var totalCalories: Int {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    private var totalProtein: Int {
        entries.reduce(0) { $0 + $1.protein }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date + totals
            VStack(alignment: .leading, spacing: 4) {
                Text(Self.dateFormatter.string(from: date))
                    .font(.title3)
                    .bold()
                
                Text("\(totalCalories) kcal • \(totalProtein) g protein")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if entries.isEmpty {
                Text("No entries for this day.")
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.name)
                                .font(.headline)
                            Text("\(entry.calories) kcal • \(entry.protein) g • \(entry.mealType.displayName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Day Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DayDetailView(
            date: Date(),
            entries: [
                FoodEntry(
                    id: UUID(),
                    name: "Sample Meal",
                    calories: 300,
                    protein: 25,
                    mealType: .lunch,
                    date: Date()
                )
            ]
        )
    }
}
