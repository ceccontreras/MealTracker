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

        let days: [(Date, Bool)] = (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: todayStart) else { return nil }
            let entriesForDay = allEntries.filter { calendar.isDate($0.date, inSameDayAs: day) }

            let dayCalories = entriesForDay.reduce(0) { $0 + $1.calories }
            let dayProtein  = entriesForDay.reduce(0) { $0 + $1.protein }

            let meets = dayCalories >= calorieGoal && dayProtein >= proteinGoal
            return (day, meets)
        }

        return days.reversed()
    }

    private static let weekdayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df
    }()

    private static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df
    }()

    // MARK: - Extracted subviews to help the type-checker
    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 20) {
            // Calories vertical bar
            VStack(spacing: 8) {
                // Value at top
                VStack(spacing: 2) {
                    Text("\(totalCalories)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Vertical progress bar
                ZStack(alignment: .bottom) {
                    // Background track
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 180)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.8), Color.orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 60, height: 180 * calorieProgress)
                }
                
                // Label at bottom
                VStack(spacing: 4) {
                    Text("Calories")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Goal: \(calorieGoal)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Protein vertical bar
            VStack(spacing: 8) {
                // Value at top
                VStack(spacing: 2) {
                    Text("\(totalProtein)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("grams")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Vertical progress bar
                ZStack(alignment: .bottom) {
                    // Background track
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 180)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 60, height: 180 * proteinProgress)
                }
                
                // Label at bottom
                VStack(spacing: 4) {
                    Text("Protein")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Goal: \(proteinGoal)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("This week")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(weeklySummaries, id: \.date) { day in
                        let weekday = Self.weekdayFormatter.string(from: day.date)
                        let dayNum = Self.dayFormatter.string(from: day.date)
                        WeeklyDayView(
                            date: day.date,
                            meetsGoal: day.meetsGoal,
                            weekdayText: weekday,
                            dayNumberText: dayNum
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
        }
    }

    private struct WeeklyDayView: View {
        let date: Date
        let meetsGoal: Bool
        let weekdayText: String
        let dayNumberText: String

        var body: some View {
            VStack(spacing: 4) {
                Text(weekdayText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .strokeBorder(
                            meetsGoal ? Color.green : Color.secondary.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 30, height: 30)

                    if meetsGoal {
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Text(dayNumberText)
                            .font(.caption2)
                    }
                }
            }
        }
    }

    private struct TodayEntriesList: View {
        let entries: [FoodEntry]
        let onDelete: (_ idsToDelete: [UUID]) -> Void

        var body: some View {
            if entries.isEmpty {
                Text("No entries yet. Use the button below to add your first meal.")
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
                        let ids = offsets.map { entries[$0].id }
                        onDelete(ids)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header with vertical progress bars
                headerSection
                    .padding(.top, 8)

                // Mini "this week" calendar
                weeklySummarySection

                // List of today's entries
                TodayEntriesList(entries: todayEntries) { idsToDelete in
                    allEntries.removeAll { idsToDelete.contains($0.id) }
                }
            }
            .padding(.bottom, 90)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }

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
            .safeAreaInset(edge: .bottom) {
                ZStack {
                    // Visible colored background bar
                    Color.white
                        .ignoresSafeArea(edges: .bottom)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                    
                    // Floating action button
                    Button {
                        showingAddFood = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 64, height: 64)
                                .shadow(radius: 6)

                            Image(systemName: "plus")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .offset(y: -12)
                }
                .frame(height: 90)
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView { newEntry in
                    allEntries.append(newEntry)
                }
            }
            .onAppear {
                allEntries = FoodStorage.shared.loadEntries()
            }
            .onChange(of: allEntries) { _, newValue in
                FoodStorage.shared.saveEntries(newValue)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    ContentView()
}
