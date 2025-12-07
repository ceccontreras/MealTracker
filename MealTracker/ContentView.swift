import SwiftUI

struct ContentView: View {
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
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }

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
