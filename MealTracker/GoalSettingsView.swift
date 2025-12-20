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
        ScrollView {
            VStack(spacing: 24) {
                // Header section
                HeaderSection()
                
                // Calorie Goal Card
                GoalCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "Calorie Goal",
                    value: $calorieGoal,
                    unit: "kcal",
                    range: 1000...5000,
                    step: 50
                )
                
                // Protein Goal Card
                GoalCard(
                    icon: "leaf.fill",
                    iconColor: .blue,
                    title: "Protein Goal",
                    value: $proteinGoal,
                    unit: "g",
                    range: 50...300,
                    step: 5
                )
                
                // Info box
                InfoBox()
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Header Section
private struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .padding(.top, 8)
            
            Text("Set Your Daily Goals")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("These goals help track your daily nutrition progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Info Box
private struct InfoBox: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.title3)
            
            Text("Your goals are used on the Today screen to calculate your daily progress.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            CardHeader(icon: icon, iconColor: iconColor, title: title)
            
            // Value and controls
            ValueControls(value: $value, unit: unit, range: range, step: step)
            
            // Slider
            SliderSection(value: $value, unit: unit, range: range, step: step, iconColor: iconColor)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Card Header
private struct CardHeader: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            IconCircle(icon: icon, iconColor: iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Daily target")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Icon Circle
private struct IconCircle: View {
    let icon: String
    let iconColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 44, height: 44)
            
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
        }
    }
}

// MARK: - Value Controls
private struct ValueControls: View {
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        HStack {
            ValueDisplay(value: value, unit: unit)
            Spacer()
            StepperButtons(value: $value, range: range, step: step)
        }
    }
}

// MARK: - Value Display
private struct ValueDisplay: View {
    let value: Int
    let unit: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Stepper Buttons
private struct StepperButtons: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        HStack(spacing: 12) {
            StepperButton(
                icon: "minus",
                backgroundColor: Color.gray.opacity(0.3)
            ) {
                if value > range.lowerBound {
                    value = max(value - step, range.lowerBound)
                }
            }
            
            StepperButton(
                icon: "plus",
                backgroundColor: Color.blue
            ) {
                if value < range.upperBound {
                    value = min(value + step, range.upperBound)
                }
            }
        }
    }
}

// MARK: - Stepper Button
private struct StepperButton: View {
    let icon: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .cornerRadius(12)
        }
    }
}

// MARK: - Slider Section
private struct SliderSection: View {
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    let step: Int
    let iconColor: Color
    
    private var doubleValue: Binding<Double> {
        Binding(
            get: { Double(value) },
            set: { value = Int($0) }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Slider(
                value: doubleValue,
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: Double(step)
            )
            .accentColor(iconColor)
            
            SliderLabels(range: range, unit: unit)
        }
    }
}

// MARK: - Slider Labels
private struct SliderLabels: View {
    let range: ClosedRange<Int>
    let unit: String
    
    var body: some View {
        HStack {
            Text("\(range.lowerBound) \(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(range.upperBound) \(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
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
