import SwiftUI

struct DayDetailView: View {
    let date: Date

    @State private var allEntries: [FoodEntry] = []

    // Editing state
    @State private var editingEntry: FoodEntry? = nil
    @State private var editCalories: String = ""
    @State private var editProtein: String = ""
    @State private var editName: String = ""
    @State private var editMealType: MealType = .breakfast

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        return df
    }()

    private var entriesForDay: [FoodEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var totalCalories: Int {
        entriesForDay.reduce(0) { $0 + $1.calories }
    }

    private var totalProtein: Int {
        entriesForDay.reduce(0) { $0 + $1.protein }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Self.dateFormatter.string(from: date))
                    .font(.title3).bold()
                Text("\(totalCalories) kcal • \(totalProtein) g protein")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if entriesForDay.isEmpty {
                Text("No entries for this day.")
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(entriesForDay) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.name)
                                .font(.headline)
                            Text("\(entry.calories) kcal • \(entry.protein) g • \(entry.mealType.displayName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // ONLY set the selected entry.
                            // The sheet will load edit fields from `entry` in .onAppear.
                            editingEntry = entry
                        }
                    }
                }
            }
        }
        .navigationTitle("Day Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            allEntries = FoodStorage.shared.loadEntries()
        }
        .sheet(item: $editingEntry) { entry in
            NavigationStack {
                Form {
                    Section("Meal name") {
                        TextField("Name", text: $editName)
                    }

                    Section("Meal type") {
                        Picker("Meal type", selection: $editMealType) {
                            ForEach(MealType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Calories") {
                        TextField("Calories", text: $editCalories)
                            .keyboardType(.numberPad)
                    }

                    Section("Protein (g)") {
                        TextField("Protein", text: $editProtein)
                            .keyboardType(.numberPad)
                    }

                    Section {
                        Button("Save changes") {
                            saveChanges(for: entry)
                        }
                    }
                }
                .navigationTitle("Edit Meal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            editingEntry = nil
                        }
                    }
                }
                // This is the key fix:
                // Load the edit fields from the sheet’s `entry`
                .onAppear {
                    editName = entry.name
                    editCalories = String(entry.calories)
                    editProtein = String(entry.protein)
                    editMealType = entry.mealType
                }
            }
        }
    }

    private func saveChanges(for entry: FoodEntry) {
        guard let newCalories = Int(editCalories),
              let newProtein = Int(editProtein),
              !editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        let updated = FoodEntry(
            id: entry.id,
            name: editName,
            calories: newCalories,
            protein: newProtein,
            mealType: editMealType,
            date: entry.date
        )

        allEntries = allEntries.map { $0.id == entry.id ? updated : $0 }
        FoodStorage.shared.saveEntries(allEntries)
        editingEntry = nil
    }
}

#Preview {
    NavigationStack {
        DayDetailView(date: Date())
    }
}
