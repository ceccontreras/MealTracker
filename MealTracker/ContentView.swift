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

    // MARK: - Weekly summary (last 7 days)

    private var weeklySummaries: [(date: Date, meetsGoal: Bool)] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        // Build an array of last 7 days (today, yesterday, etc.), then reverse so oldest first
        let days: [(Date, Bool)] = (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: todayStart) else { return nil }
            let entriesForDay = allEntries.filter { calendar.isDate($0.date, inSameDayAs: day) }

            let dayCalories = entriesForDay.reduce(0) { $0 + $1.calories }
            let dayProtein = entriesForDay.reduce(0) { $0 + $1.protein }

            let meets = dayCalories >= calorieGoal && dayProtein >= proteinGoal
            return (day, meets)
        }

        return days.reversed()
    }

    private static let weekdayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "E" // Mon, Tue, Wed...
        return df
    }()

    private static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d" // 1,2,3...
        return df
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                // MAIN CONTENT
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

                    // Mini "this week" calendar
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This week")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(weeklySummaries, id: \.date) { day in
                                    VStack(spacing: 4) {
                                        Text(Self.weekdayFormatter.string(from: day.date))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)

                                        ZStack {
                                            Circle()
                                                .strokeBorder(
                                                    day.meetsGoal ? Color.green : Color.secondary.opacity(0.3),
                                                    lineWidth: 2
                                                )
                                                .frame(width: 30, height: 30)

                                            if day.meetsGoal {
                                                Image(systemName: "checkmark")
                                                    .font(.caption2)
                                                    .foregroundStyle(.green)
                                            } else {
                                                Text(Self.dayFormatter.string(from: day.date))
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                        }
                    }

                    // List of today's entries
                    if todayEntries.isEmpty {
                        Text("No entries yet. Use the button below to add your first meal.")
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

                // FLOATING ADD MEAL BUTTON (bottom, centered)
                VStack {
                    Spacer()
                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 24)
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

                // Only the Goals button in the top-right now
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        GoalSettingsView(
                            calorieGoal: $calorieGoal,
                            proteinGoal: $proteinGoal
                        )
                    } label: {
                        Image(systemName: "slider.horizontal.3")
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
