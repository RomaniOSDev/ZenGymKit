//
//  ProgressManager.swift
//  ZenGym
//
//

import Foundation
import Combine

class ProgressManager: ObservableObject {
    @Published var weeklyStats: WeeklyStats = WeeklyStats()
    @Published var monthlyStats: MonthlyStats = MonthlyStats()
    @Published var totalWorkouts: Int = 0
    @Published var totalWorkoutTime: Int = 0 // in minutes
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    private var workoutManager: WorkoutManager?
    private var cancellables = Set<AnyCancellable>()
    
    func setWorkoutManager(_ manager: WorkoutManager) {
        workoutManager = manager
        updateStats()
        
        // Subscribe to workout history changes
        manager.$workoutHistory
            .sink { [weak self] _ in
                self?.updateStats()
            }
            .store(in: &cancellables)
    }
    
    func updateStats() {
        guard let workoutManager = workoutManager else { return }
        
        let completedWorkouts = workoutManager.workoutHistory.filter { $0.isCompleted }
        totalWorkouts = completedWorkouts.count
        totalWorkoutTime = completedWorkouts.reduce(0) { $0 + $1.actualDuration }
        
        calculateStreaks(from: completedWorkouts)
        calculateWeeklyStats(from: completedWorkouts)
        calculateMonthlyStats(from: completedWorkouts)
    }
    
    private func calculateStreaks(from workouts: [Workout]) {
        let sortedWorkouts = workouts.sorted { $0.startTime > $1.startTime }
        var currentStreakCount = 0
        var longestStreakCount = 0
        var tempStreak = 0
        
        let calendar = Calendar.current
        var currentDate = Date()
        
        for workout in sortedWorkouts {
            let workoutDate = calendar.startOfDay(for: workout.startTime)
            let currentDay = calendar.startOfDay(for: currentDate)
            
            if calendar.isDate(workoutDate, inSameDayAs: currentDay) {
                tempStreak += 1
                currentStreakCount = max(currentStreakCount, tempStreak)
            } else if calendar.dateInterval(of: .day, for: currentDate)?.contains(workoutDate) == true {
                // Workout was yesterday, continue streak
                tempStreak += 1
                currentStreakCount = max(currentStreakCount, tempStreak)
            } else {
                // Streak broken
                longestStreakCount = max(longestStreakCount, tempStreak)
                tempStreak = 0
            }
            
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        longestStreakCount = max(longestStreakCount, tempStreak)
        currentStreak = currentStreakCount
        longestStreak = longestStreakCount
    }
    
    private func calculateWeeklyStats(from workouts: [Workout]) {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        let weeklyWorkouts = workouts.filter { workout in
            workout.startTime >= weekStart
        }
        
        weeklyStats = WeeklyStats(
            workoutsCompleted: weeklyWorkouts.count,
            totalTime: weeklyWorkouts.reduce(0) { $0 + $1.actualDuration },
            averageTime: weeklyWorkouts.isEmpty ? 0 : weeklyWorkouts.reduce(0) { $0 + $1.actualDuration } / weeklyWorkouts.count
        )
    }
    
    private func calculateMonthlyStats(from workouts: [Workout]) {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let monthlyWorkouts = workouts.filter { workout in
            workout.startTime >= monthStart
        }
        
        monthlyStats = MonthlyStats(
            workoutsCompleted: monthlyWorkouts.count,
            totalTime: monthlyWorkouts.reduce(0) { $0 + $1.actualDuration },
            averageTime: monthlyWorkouts.isEmpty ? 0 : monthlyWorkouts.reduce(0) { $0 + $1.actualDuration } / monthlyWorkouts.count
        )
    }
}

struct WeeklyStats {
    var workoutsCompleted: Int = 0
    var totalTime: Int = 0 // in minutes
    var averageTime: Int = 0 // in minutes
}

struct MonthlyStats {
    var workoutsCompleted: Int = 0
    var totalTime: Int = 0 // in minutes
    var averageTime: Int = 0 // in minutes
} 
