//
//  ContentView.swift
//  MealTracker
//
//  Created by Carlos Campos on 12/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var entries: [FoodEntry] = []
    @State private var showingAddFood = false

    var totalCalories: Int {
        entries.map { $0.calories }.reduce(0, +)
    }

    var totalProtein: Int {
        entries.map { $0.protein }.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(totalCalories)")
                            .font(.title2)
                            .bold()
                    }

                    Spacer()

                    VStack(alignment: .leading) {
                        Text("Protein")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(totalProtein) g")
                            .font(.title2)
                            .bold()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                if entries.isEmpty {
                    Text("No entries yet. Tap + to add your first meal.")
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
                        .onDelete { offsets in
                            entries.remove(atOffsets: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                // 🔹 New: History button on the left
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                
                // Existing: Add (+) button on the right
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView { newEntry in
                    entries.append(newEntry)
                }
            }
            .onAppear {
                // Load ALL entries from JSON
                entries = FoodStorage.shared.loadEntries()
            }
            .onChange(of: entries) { oldValue, newValue in
                // Save ALL entries to JSON whenever anything changes
                FoodStorage.shared.saveEntries(newValue)
            }
        }
    }
}

#Preview {
    ContentView()
}
