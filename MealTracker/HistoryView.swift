import SwiftUI

struct HistoryView: View {
    @State private var allEntries: [FoodEntry] = []
    
    // Group entries by day
    private var groupedByDay: [(date: Date, entries: [FoodEntry])] {
        let calendar = Calendar.current
        
        let groups = Dictionary(grouping: allEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        return groups
            .map { (date: $0.key, entries: $0.value) }
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
                ForEach(groupedByDay, id: \.date) { group in
                    NavigationLink {
                        // Pass only the date now
                        DayDetailView(date: group.date)
                    } label: {
                        let totalCalories = group.entries.reduce(0) { $0 + $1.calories }
                        let totalProtein = group.entries.reduce(0) { $0 + $1.protein }
                        
                        VStack(alignment: .leading) {
                            Text(Self.dateFormatter.string(from: group.date))
                                .font(.headline)
                            Text("\(totalCalories) kcal • \(totalProtein) g protein")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .onAppear {
            allEntries = FoodStorage.shared.loadEntries()
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
