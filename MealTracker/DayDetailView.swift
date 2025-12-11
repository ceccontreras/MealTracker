import SwiftUI

struct DayDetailView: View {
    let date: Date
    
    @State private var allEntries: [FoodEntry] = []
    @State private var editingEntry: FoodEntry? = nil
    @State private var editCalories: String = ""
    @State private var editProtein: String = ""
    
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
                        .contentShape(Rectangle()) // make full row tappable
                        .onTapGesture {
                            // Start editing this entry
                            editingEntry = entry
                            editCalories = String(entry.calories)
                            editProtein = String(entry.protein)
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
        // Sheet for editing calories & protein
        .sheet(item: $editingEntry) { entry in
            NavigationStack {
                Form {
                    Section("Meal") {
                        Text(entry.name)
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
            }
        }
    }
    
    // MARK: - Helpers
    
    private func saveChanges(for entry: FoodEntry) {
        guard
            let newCalories = Int(editCalories),
            let newProtein = Int(editProtein)
        else {
            // Could add validation UI later
            return
        }
        
        // Update in the global list
        if let index = allEntries.firstIndex(where: { $0.id == entry.id }) {
            allEntries[index].calories = newCalories
            allEntries[index].protein = newProtein
        }
        
        // Persist to disk
        FoodStorage.shared.saveEntries(allEntries)
        
        // Close sheet
        editingEntry = nil
    }
}

#Preview {
    NavigationStack {
        DayDetailView(date: Date())
    }
}
