//
//  GoalSettingView.swift
//  MealTracker
//
//  Created by Carlos Campos on 12/8/25.
//

import SwiftUI

struct GoalSettingsView: View {
    @Binding var calorieGoal: Int
    @Binding var proteinGoal: Int
    
    var body: some View {
        Form {
            Section("Calorie Goal") {
                Stepper(value: $calorieGoal, in: 0...10000, step: 50) {
                    Text("\(calorieGoal) kcal")
                }
            }
            
            Section("Protein Goal") {
                Stepper(value: $proteinGoal, in: 0...400, step: 5) {
                    Text("\(proteinGoal) g")
                }
            }
            
            Section {
                Text("These goals are used on the Today screen to calculate your progress.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GoalSettingsView(
            calorieGoal: .constant(2300),
            proteinGoal: .constant(150)
        )
    }
}
