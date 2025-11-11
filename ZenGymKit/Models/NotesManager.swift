//
//  NotesManager.swift
//  ZenGym
//
//

import Foundation
import Combine

struct DailyNote: Identifiable, Codable {
    let id: UUID
    let date: Date
    var mood: Mood
    var sleepHours: Double
    var energyLevel: Int
    var nutrition: String
    var workoutNotes: String
    var generalNotes: String
    var waterIntake: Int // glasses
    var weight: Double?
    var bodyFat: Double?
    var muscleMass: Double?
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.mood = .neutral
        self.sleepHours = 8.0
        self.energyLevel = 5
        self.nutrition = ""
        self.workoutNotes = ""
        self.generalNotes = ""
        self.waterIntake = 8
        self.weight = nil
        self.bodyFat = nil
        self.muscleMass = nil
    }
}

enum Mood: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case neutral = "Neutral"
    case bad = "Bad"
    case terrible = "Terrible"
    
    var emoji: String {
        switch self {
        case .excellent: return "😄"
        case .good: return "🙂"
        case .neutral: return "😐"
        case .bad: return "😕"
        case .terrible: return "😞"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .neutral: return "gray"
        case .bad: return "orange"
        case .terrible: return "red"
        }
    }
}

class NotesManager: ObservableObject {
    @Published var dailyNotes: [DailyNote] = []
    @Published var selectedDate: Date = Date()
    
    private let userDefaults = UserDefaults.standard
    private let notesKey = "DailyNotes"
    
    init() {
        loadNotes()
    }
    
    // MARK: - Data Management
    
    func saveNotes() {
        if let encoded = try? JSONEncoder().encode(dailyNotes) {
            userDefaults.set(encoded, forKey: notesKey)
        }
    }
    
    private func loadNotes() {
        if let data = userDefaults.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([DailyNote].self, from: data) {
            dailyNotes = decoded
        }
    }
    
    // MARK: - Note Operations
    
    func getNote(for date: Date) -> DailyNote {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if let existingNote = dailyNotes.first(where: { note in
            calendar.isDate(note.date, inSameDayAs: startOfDay)
        }) {
            return existingNote
        } else {
            let newNote = DailyNote(date: startOfDay)
            dailyNotes.append(newNote)
            saveNotes()
            return newNote
        }
    }
    
    func updateNote(_ note: DailyNote) {
        if let index = dailyNotes.firstIndex(where: { $0.id == note.id }) {
            dailyNotes[index] = note
        } else {
            dailyNotes.append(note)
        }
        saveNotes()
        objectWillChange.send()
    }
    
    func deleteNote(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        dailyNotes.removeAll { note in
            calendar.isDate(note.date, inSameDayAs: startOfDay)
        }
        saveNotes()
    }
    
    // MARK: - Analytics
    
    func getWeeklyMoodAverage() -> Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let recentNotes = dailyNotes.filter { note in
            note.date >= weekAgo
        }
        
        guard !recentNotes.isEmpty else { return 0 }
        
        let moodValues = recentNotes.map { note -> Int in
            switch note.mood {
            case .excellent: return 5
            case .good: return 4
            case .neutral: return 3
            case .bad: return 2
            case .terrible: return 1
            }
        }
        
        return Double(moodValues.reduce(0, +)) / Double(moodValues.count)
    }
    
    func getWeeklySleepAverage() -> Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let recentNotes = dailyNotes.filter { note in
            note.date >= weekAgo && note.sleepHours > 0
        }
        
        guard !recentNotes.isEmpty else { return 0 }
        
        let totalSleep = recentNotes.reduce(0) { $0 + $1.sleepHours }
        return totalSleep / Double(recentNotes.count)
    }
    
    func getWeeklyWaterAverage() -> Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let recentNotes = dailyNotes.filter { note in
            note.date >= weekAgo
        }
        
        guard !recentNotes.isEmpty else { return 0 }
        
        let totalWater = recentNotes.reduce(0) { $0 + $1.waterIntake }
        return Double(totalWater) / Double(recentNotes.count)
    }
    
    // MARK: - Streaks
    
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        var currentDate = Date()
        var streak = 0
        
        while true {
            let note = getNote(for: currentDate)
            if !note.generalNotes.isEmpty || !note.workoutNotes.isEmpty {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
} 