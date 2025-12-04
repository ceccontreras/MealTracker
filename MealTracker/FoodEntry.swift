//
//  FoodEntry.swift
//  MealTracker
//
//  Created by Carlos Campos on 12/3/25.
//

import Foundation

enum MealType: String, CaseIterable, Codable {
    case breakfast
    case lunch
    case dinner
    case snack
    
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .dinner:    return "Dinner"
        case .snack:     return "Snack"
        }
    }
}

struct FoodEntry: Identifiable, Codable, Equatable{
    let id: UUID
    var name: String
    var calories: Int
    var protein: Int
    var mealType: MealType
    var date: Date
}
