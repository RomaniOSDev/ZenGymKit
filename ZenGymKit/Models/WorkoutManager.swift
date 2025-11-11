//
//  WorkoutManager.swift
//  ZenGym
//
//

import Foundation
import Combine

class WorkoutManager: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var workoutHistory: [Workout] = []
    @Published var availableWorkouts: [WorkoutTemplate] = []
    @Published var isWorkoutActive = false
    
    private var workoutTimer: Timer?
    
    init() {
        loadWorkoutTemplates()
        loadWorkoutHistory()
    }
    
    func startWorkout(_ template: WorkoutTemplate) {
        currentWorkout = Workout(
            id: UUID(),
            name: template.name,
            exercises: template.exercises,
            startTime: Date(),
            estimatedDuration: template.estimatedDuration
        )
        isWorkoutActive = true
        
        // Запускаем таймер для обновления времени
        startWorkoutTimer()
    }
    
    func completeWorkout() {
        guard var workout = currentWorkout else { 
            print("No current workout to complete")
            return 
        }
        
        print("Completing workout: \(workout.name)")
        stopWorkoutTimer()
        workout.endTime = Date()
        workout.isCompleted = true
        
        print("Adding workout to history. Total workouts before: \(workoutHistory.count)")
        workoutHistory.append(workout)
        print("Total workouts after: \(workoutHistory.count)")
        
        currentWorkout = nil
        isWorkoutActive = false
        saveWorkoutHistory()
        
        // Notify observers that data changed
        objectWillChange.send()
    }
    
    func pauseWorkout() {
        stopWorkoutTimer()
        // Implementation for pausing workout
    }
    
    func resumeWorkout() {
        startWorkoutTimer()
        // Implementation for resuming workout
    }
    
    private func startWorkoutTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }
    
    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    func loadWorkoutTemplates() {
        availableWorkouts = [
            WorkoutTemplate(
                id: UUID(),
                name: "Zen Strength",
                description: "Full body strength training",
                exercises: [
                    Exercise(name: "Push-ups", sets: 3, reps: 12, restTime: 60),
                    Exercise(name: "Squats", sets: 3, reps: 15, restTime: 60),
                    Exercise(name: "Plank", sets: 3, reps: 30, restTime: 45),
                    Exercise(name: "Lunges", sets: 3, reps: 10, restTime: 60)
                ],
                estimatedDuration: 30,
                difficulty: .beginner
            ),
            WorkoutTemplate(
                id: UUID(),
                name: "Core Zen",
                description: "Focus on core strength",
                exercises: [
                    Exercise(name: "Crunches", sets: 3, reps: 20, restTime: 45),
                    Exercise(name: "Russian Twists", sets: 3, reps: 15, restTime: 45),
                    Exercise(name: "Leg Raises", sets: 3, reps: 12, restTime: 60),
                    Exercise(name: "Mountain Climbers", sets: 3, reps: 20, restTime: 45)
                ],
                estimatedDuration: 25,
                difficulty: .intermediate
            ),
            WorkoutTemplate(
                id: UUID(),
                name: "Zen Cardio",
                description: "High intensity cardio",
                exercises: [
                    Exercise(name: "Burpees", sets: 3, reps: 10, restTime: 90),
                    Exercise(name: "Jumping Jacks", sets: 3, reps: 30, restTime: 60),
                    Exercise(name: "High Knees", sets: 3, reps: 20, restTime: 60),
                    Exercise(name: "Mountain Climbers", sets: 3, reps: 25, restTime: 60)
                ],
                estimatedDuration: 35,
                difficulty: .advanced
            ),
            WorkoutTemplate(
                id: UUID(),
                name: "Upper Body Zen",
                description: "Focus on arms and chest",
                exercises: [
                    Exercise(name: "Push-ups", sets: 4, reps: 15, restTime: 60),
                    Exercise(name: "Diamond Push-ups", sets: 3, reps: 8, restTime: 75),
                    Exercise(name: "Tricep Dips", sets: 3, reps: 12, restTime: 60),
                    Exercise(name: "Arm Circles", sets: 3, reps: 20, restTime: 45)
                ],
                estimatedDuration: 28,
                difficulty: .intermediate
            ),
            WorkoutTemplate(
                id: UUID(),
                name: "Lower Body Zen",
                description: "Focus on legs and glutes",
                exercises: [
                    Exercise(name: "Squats", sets: 4, reps: 20, restTime: 60),
                    Exercise(name: "Lunges", sets: 3, reps: 12, restTime: 60),
                    Exercise(name: "Wall Sit", sets: 3, reps: 45, restTime: 60),
                    Exercise(name: "Calf Raises", sets: 3, reps: 25, restTime: 45)
                ],
                estimatedDuration: 32,
                difficulty: .beginner
            ),
            WorkoutTemplate(
                id: UUID(),
                name: "Zen HIIT",
                description: "High intensity interval training",
                exercises: [
                    Exercise(name: "Burpees", sets: 4, reps: 15, restTime: 90),
                    Exercise(name: "Mountain Climbers", sets: 4, reps: 30, restTime: 60),
                    Exercise(name: "Jump Squats", sets: 3, reps: 20, restTime: 75),
                    Exercise(name: "Plank Jacks", sets: 3, reps: 25, restTime: 60)
                ],
                estimatedDuration: 40,
                difficulty: .advanced
            ),
            WorkoutTemplate(
                id: UUID(),
                name: "Morning Zen",
                description: "Quick morning energizer",
                exercises: [
                    Exercise(name: "Sun Salutation", sets: 3, reps: 5, restTime: 30),
                    Exercise(name: "Jumping Jacks", sets: 2, reps: 20, restTime: 45),
                    Exercise(name: "Arm Circles", sets: 2, reps: 15, restTime: 30),
                    Exercise(name: "Deep Breathing", sets: 2, reps: 10, restTime: 30)
                ],
                estimatedDuration: 15,
                difficulty: .beginner
            ),
            WorkoutTemplate(
                id: UUID(),
                name: "Evening Zen",
                description: "Relaxing evening routine",
                exercises: [
                    Exercise(name: "Gentle Stretches", sets: 3, reps: 10, restTime: 30),
                    Exercise(name: "Cat-Cow Stretch", sets: 2, reps: 8, restTime: 30),
                    Exercise(name: "Child's Pose", sets: 2, reps: 30, restTime: 45),
                    Exercise(name: "Meditation", sets: 1, reps: 300, restTime: 0)
                ],
                estimatedDuration: 20,
                difficulty: .beginner
            )
        ]
    }
    
    private func loadWorkoutHistory() {
        print("Loading workout history...")
        if let data = UserDefaults.standard.data(forKey: "WorkoutHistory"),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workoutHistory = decoded
            print("Workout history loaded successfully. Count: \(workoutHistory.count)")
        } else {
            workoutHistory = []
            print("No saved workout history found, starting with empty history")
        }
    }
    
    func saveWorkoutHistory() {
        print("Saving workout history...")
        if let encoded = try? JSONEncoder().encode(workoutHistory) {
            UserDefaults.standard.set(encoded, forKey: "WorkoutHistory")
            print("Workout history saved successfully. Count: \(workoutHistory.count)")
        } else {
            print("Failed to save workout history")
        }
    }
}

struct WorkoutTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let exercises: [Exercise]
    let estimatedDuration: Int // in minutes
    let difficulty: WorkoutDifficulty
}

struct Workout: Identifiable, Codable {
    let id: UUID
    let name: String
    let exercises: [Exercise]
    let startTime: Date
    let estimatedDuration: Int
    var endTime: Date?
    var isCompleted: Bool = false
    
    var actualDuration: Int {
        if let endTime = endTime {
            let durationInSeconds = endTime.timeIntervalSince(startTime)
            // Если тренировка длилась меньше минуты, считаем её как 1 минуту
            return max(1, Int(durationInSeconds / 60))
        } else {
            let durationInSeconds = Date().timeIntervalSince(startTime)
            return max(1, Int(durationInSeconds / 60))
        }
    }
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: Int
    let restTime: Int // in seconds
    var completedSets: Int = 0
    var isCompleted: Bool = false
    
    init(name: String, sets: Int, reps: Int, restTime: Int) {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restTime = restTime
        self.completedSets = 0
        self.isCompleted = false
    }
}

enum WorkoutDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
} 
