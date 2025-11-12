//
//  WorkoutSelectionView.swift
//  ZenGym
//
//

import SwiftUI

struct WorkoutSelectionView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
                            // Workouts grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(workoutManager.availableWorkouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)
                                .environmentObject(workoutManager)
                                .environmentObject(progressManager)
                                .environmentObject(settingsManager)) {
                                QuickWorkoutCard(workout: workout)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
        }
        .background(
            Color.appGradient
                .ignoresSafeArea()
        )
        .navigationTitle("Choose Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .dismissKeyboardOnTapAndScroll()
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Select Your Workout")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Choose from our curated collection of workouts designed for all fitness levels")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
}

struct QuickWorkoutCard: View {
    let workout: WorkoutTemplate
    
    var body: some View {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(workoutColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: workoutIcon)
                        .font(.title2)
                        .foregroundColor(workoutColor)
                }
                
                // Title
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Duration
                Text("\(workout.estimatedDuration) min")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                
                // Difficulty badge
                Text(workout.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(difficultyColor)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurfaceStrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(workoutColor.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.appAccentOpacity(0.12), radius: 10, x: 0, y: 6)
            )
    }
    
    private var workoutColor: Color {
        switch workout.name {
        case let name where name.contains("Strength"):
            return .appAccent
        case let name where name.contains("Core"):
            return .appAccentSecondary
        case let name where name.contains("Cardio"):
            return .appAccentTertiary
        default:
            return Color.appAccentOpacity(0.45)
        }
    }
    
    private var workoutIcon: String {
        switch workout.name {
        case let name where name.contains("Strength"):
            return "dumbbell.fill"
        case let name where name.contains("Core"):
            return "figure.core.training"
        case let name where name.contains("Cardio"):
            return "heart.fill"
        default:
            return "figure.run"
        }
    }
    
    private var difficultyColor: Color {
        switch workout.difficulty {
        case .beginner: return .appAccentTertiary
        case .intermediate: return .appAccentSecondary
        case .advanced: return .appAccent
        }
    }
}

#Preview {
    WorkoutSelectionView()
        .environmentObject(WorkoutManager())
        .environmentObject(ProgressManager())
        .environmentObject(SettingsManager())
} 
