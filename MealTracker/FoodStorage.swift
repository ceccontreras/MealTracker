//
//  FoodStorage.swift
//  MealTracker
//
//  Created by Carlos Campos on 12/3/25.
//

import Foundation

final class FoodStorage {
    static let shared = FoodStorage()
    
    private let fileURL: URL
    
    private init() {
        let manager = FileManager.default
        let docs = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent("food_log.json")
    }
    
    // Load all entries from disk
    func loadEntries() -> [FoodEntry] {
        let fm = FileManager.default
        
        // If file doesn't exist yet, return empty list
        guard fm.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([FoodEntry].self, from: data)
        } catch {
            print("❌ Failed to load entries:", error)
            return []
        }
    }
    
    // Save entries to disk
    func saveEntries(_ entries: [FoodEntry]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Failed to save entries:", error)
        }
    }
}
