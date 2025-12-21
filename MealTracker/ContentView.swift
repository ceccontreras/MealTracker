import SwiftUI

struct ContentView: View {
    // MARK: - Goals stored in AppStorage (persist between launches)
    @AppStorage("calorieGoal") private var calorieGoal: Int = 2300
    @AppStorage("proteinGoal") private var proteinGoal: Int = 150

    @State private var allEntries: [FoodEntry] = []
    @State private var showingAddFood = false

    // MARK: - Today filter
    private var todayEntries: [FoodEntry] {
        let calendar = Calendar.current
        return allEntries
            .filter { calendar.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Totals
    private var totalCalories: Int {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    private var totalProtein: Int {
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

    // MARK: - Header Card
    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 20) {
            Spacer()

            // Calories vertical bar
            VStack(spacing: 8) {
                VStack(spacing: 2) {
                    Text("\(totalCalories)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 180)

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
                VStack(spacing: 2) {
                    Text("\(totalProtein)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("grams")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 180)

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

                VStack(spacing: 4) {
                    Text("Protein")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Goal: \(proteinGoal)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Weekly Card
    @ViewBuilder
    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This week")
                .font(.caption)
                .foregroundStyle(.secondary)

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
                .padding(.vertical, 12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .padding(.horizontal)
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

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)

            HStack {
                // History
                NavigationLink {
                    HistoryView()
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                        .frame(width: 50, height: 50)
                }

                Spacer()

                // Add
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

                Spacer()

                // Settings
                NavigationLink {
                    GoalSettingsView(
                        calorieGoal: $calorieGoal,
                        proteinGoal: $proteinGoal
                    )
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                        .frame(width: 50, height: 50)
                }
            }
            .padding(.horizontal, 30)
        }
        .frame(height: 90)
    }

    // MARK: - Body (single List = reliable layout)
    var body: some View {
        NavigationStack {
            List {
                headerSection
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                weeklySummarySection
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                Section {
                    if todayEntries.isEmpty {
                        Text("No entries yet. Use the + button below to add your first meal.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(todayEntries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.name)
                                    .font(.headline)

                                Text("\(entry.calories) kcal • \(entry.protein) g • \(entry.mealType.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    allEntries.removeAll { $0.id == entry.id }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    Text("Entries")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .textCase(nil)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")

            .safeAreaInset(edge: .bottom) {
                bottomBar
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
        }
    }
}

#Preview {
    ContentView()
}
