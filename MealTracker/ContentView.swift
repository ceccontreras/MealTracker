import SwiftUI

struct ContentView: View {
    // MARK: - Goals stored in AppStorage (persist between launches)
    @AppStorage("calorieGoal") private var calorieGoal: Int = 2300
    @AppStorage("proteinGoal") private var proteinGoal: Int = 150

    @State private var allEntries: [FoodEntry] = []
    @State private var showingAddFood = false

    private var todayEntries: [FoodEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDateInToday($0.date) }
    }

    var totalCalories: Int {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Int {
        todayEntries.reduce(0) { $0 + $1.protein }
    }

    // MARK: - Progress values (0.0 to 1.0)
    private var calorieProgress: Double {
        guard calorieGoal > 0 else { return 0 }
        return min(Double(totalCalories) / Double(calorieGoal), 1.0)
    }

    private var proteinProgress: Double {
        guard proteinGoal > 0 else { return 0 }
        return min(Double(totalProtein) / Double(proteinGoal), 1.0)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header with totals + progress bars
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calories")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(totalCalories)")
                                .font(.title2)
                                .bold()
                            Text("Goal: \(calorieGoal) kcal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ProgressView(value: calorieProgress)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Protein")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(totalProtein) g")
                                .font(.title2)
                                .bold()
                            Text("Goal: \(proteinGoal) g")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ProgressView(value: proteinProgress)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // List of today's entries
                if todayEntries.isEmpty {
                    Text("No entries yet. Tap + to add your first meal.")
                        .foregroundStyle(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(todayEntries) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.name)
                                    .font(.headline)
                                Text("\(entry.calories) kcal • \(entry.protein) g • \(entry.mealType.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            let idsToDelete = offsets.map { todayEntries[$0].id }
                            allEntries.removeAll { idsToDelete.contains($0.id) }
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                // History button (left)
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }

                // Goals + Add buttons (right)
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        GoalSettingsView(calorieGoal: $calorieGoal,
                                         proteinGoal: $proteinGoal)
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }

                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView { newEntry in
                    allEntries.append(newEntry)
                }
            }
            .onAppear {
                allEntries = FoodStorage.shared.loadEntries()
            }
            .onChange(of: allEntries) { oldValue, newValue in
                FoodStorage.shared.saveEntries(newValue)
            }
        }
    }
}

#Preview {
    ContentView()
}
