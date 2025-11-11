//
//  WorkoutDetailView.swift
//  ZenGym
//
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutTemplate
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Workout info
                infoSection
                
                // Exercises list
                exercisesSection
                
                // Start button
                startButton
            }
            .padding()
        }
        .background(
            Color.appGradient
                .ignoresSafeArea()
        )
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .dismissKeyboardOnTapAndScroll()
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 60))
                .foregroundColor(.appAccent)
            
            VStack(spacing: 8) {
                Text(workout.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(workout.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appAccentOpacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
    
    private var infoSection: some View {
        HStack(spacing: 20) {
            InfoCard(
                title: "Duration",
                value: "\(workout.estimatedDuration) min",
                icon: "clock.fill",
                color: .appAccentSecondary
            )
            
            InfoCard(
                title: "Exercises",
                value: "\(workout.exercises.count)",
                icon: "dumbbell.fill",
                color: .appAccent
            )
            
            InfoCard(
                title: "Difficulty",
                value: workout.difficulty.rawValue,
                icon: "chart.bar.fill",
                color: difficultyColor
            )
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercises")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                ExerciseRow(exercise: exercise, index: index + 1)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appAccentOpacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
    
    private var startButton: some View {
        Button(action: {
            workoutManager.startWorkout(workout)
        }) {
            HStack {
                Image(systemName: "play.fill")
                    .font(.title2)
                
                Text("Start Workout")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.appAccent, Color.appAccentSecondary]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var difficultyColor: Color {
        switch workout.difficulty {
        case .beginner: return .appAccentTertiary
        case .intermediate: return .appAccentSecondary
        case .advanced: return .appAccent
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.12), radius: 8, x: 0, y: 4)
        )
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Exercise number
            ZStack {
                Circle()
                    .fill(Color.appAccentOpacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.appAccent)
            }
            
            // Exercise details
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(exercise.sets) sets × \(exercise.reps) reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Rest time
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(exercise.restTime)s")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("rest")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    WorkoutDetailView(workout: WorkoutTemplate(
        id: UUID(),
        name: "Zen Strength",
        description: "Full body strength training",
        exercises: [
            Exercise(name: "Push-ups", sets: 3, reps: 12, restTime: 60),
            Exercise(name: "Squats", sets: 3, reps: 15, restTime: 60)
        ],
        estimatedDuration: 30,
        difficulty: .beginner
    ))
    .environmentObject(WorkoutManager())
    .environmentObject(ProgressManager())
    .environmentObject(SettingsManager())
} 
