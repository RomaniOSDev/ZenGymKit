//
//  SettingsManager.swift
//  ZenGym
//
//

import Foundation
import Combine
import UIKit
import StoreKit

class SettingsManager: ObservableObject {
    @Published var units: MeasurementUnit {
        didSet {
            UserDefaults.standard.set(units.rawValue, forKey: "units")
        }
    }
    
    init() {
        self.units = MeasurementUnit(rawValue: UserDefaults.standard.string(forKey: "units") ?? "metric") ?? .metric
    }
    
    func resetAllData(workoutManager: WorkoutManager? = nil, progressManager: ProgressManager? = nil, notesManager: NotesManager? = nil) {
        // Reset all UserDefaults
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }
        
        // Reset settings to defaults
        units = .metric
        
        // Reset workout data
        if let workoutManager = workoutManager {
            workoutManager.workoutHistory.removeAll()
            workoutManager.availableWorkouts.removeAll()
            workoutManager.currentWorkout = nil
            workoutManager.isWorkoutActive = false
            
            // Reload default workout templates
            workoutManager.loadWorkoutTemplates()
        }
        
        // Reset progress data
        if let progressManager = progressManager {
            progressManager.weeklyStats = WeeklyStats()
            progressManager.monthlyStats = MonthlyStats()
            progressManager.totalWorkouts = 0
            progressManager.totalWorkoutTime = 0
            progressManager.currentStreak = 0
            progressManager.longestStreak = 0
        }
        
        // Reset notes data
        if let notesManager = notesManager {
            notesManager.dailyNotes.removeAll()
            notesManager.saveNotes()
        }
    }
    
    func rateApp() {
        print("Rating app...")
        // Use Apple's standard rating popup
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            print("Requesting review in scene")
            SKStoreReviewController.requestReview(in: scene)
        } else if let url = URL(string: "https://apps.apple.com/app/id1234567890") {
            // Fallback to App Store
            print("Opening App Store URL: \(url)")
            UIApplication.shared.open(url) { success in
                print("App Store opened: \(success)")
            }
        } else {
            print("No valid scene or URL found for rating")
        }
    }
    
    func openPrivacyPolicy() {
        print("Opening Privacy Policy...")
        // Implementation for privacy policy
        if let url = URL(string: "https://zengym.app/privacy") {
            print("Opening URL: \(url)")
            UIApplication.shared.open(url) { success in
                print("Privacy Policy opened: \(success)")
            }
        } else if let url = URL(string: "https://www.apple.com/legal/privacy/") {
            // Fallback to a generic privacy policy
            print("Opening fallback URL: \(url)")
            UIApplication.shared.open(url) { success in
                print("Fallback Privacy Policy opened: \(success)")
            }
        } else {
            print("No valid URL found for Privacy Policy")
        }
    }
}

enum MeasurementUnit: String, CaseIterable {
    case metric = "metric"
    case imperial = "imperial"
    
    var displayName: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        }
    }
} 
