//
//  AddFoodView.swift
//  MealTracker
//
//  Created by Carlos Campos on 12/3/25.
//

import SwiftUI

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var mealType: MealType = .breakfast

    // Parent view will decide what to do with the new entry
    var onSave: (FoodEntry) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    TextField("Name", text: $name)
                }

                Section("Nutrition") {
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.numberPad)
                }

                Section("Meal") {
                    Picker("Meal type", selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Add Food")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Basic validation
                        guard
                            !name.isEmpty,
                            let cal = Int(calories),
                            let prot = Int(protein)
                        else { return }

                        let entry = FoodEntry(
                            id: UUID(),
                            name: name,
                            calories: cal,
                            protein: prot,
                            mealType: mealType,
                            date: Date()
                        )

                        onSave(entry)    // send to parent
                        dismiss()        // close sheet
                    }
                }
            }
        }
    }
}

#Preview {
    AddFoodView { _ in }
}
