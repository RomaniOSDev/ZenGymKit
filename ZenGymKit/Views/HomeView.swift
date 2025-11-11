//
//  HomeView.swift
//  ZenGym
//
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with greeting
                headerSection
                
                // Quick stats cards
                statsSection
                
                // Current streak
                streakSection
                
                // Quick start workout
                quickStartSection
                
                // Recent workouts
                recentWorkoutsSection
            }
            .padding()
        }
        .background(Color.appGradient)
        .navigationTitle("WinZenGyn Ascend")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            progressManager.setWorkoutManager(workoutManager)
        }
        .dismissKeyboardOnTapAndScroll()
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Ready to achieve your fitness goals?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceOpacity(0.9))
                .shadow(color: Color.appAccentOpacity(0.2), radius: 12, x: 0, y: 8)
        )
    }
    
    private var statsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            StatCard(
                title: "Total Workouts",
                value: "\(progressManager.totalWorkouts)",
                icon: "dumbbell.fill",
                color: .appAccent
            )
            
            StatCard(
                title: "Total Time",
                value: "\(progressManager.totalWorkoutTime) min",
                icon: "clock.fill",
                color: Color.appAccentOpacity(0.85)
            )
            
            StatCard(
                title: "This Week",
                value: "\(progressManager.weeklyStats.workoutsCompleted)",
                icon: "calendar",
                color: Color.appAccentOpacity(0.7)
            )
            
            StatCard(
                title: "This Month",
                value: "\(progressManager.monthlyStats.workoutsCompleted)",
                icon: "chart.bar.fill",
                color: Color.appAccentOpacity(0.55)
            )
        }
    }
    
    private var streakSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.appAccent)
                    .font(.title2)
                
                Text("Current Streak")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(progressManager.currentStreak)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                    
                    Text("days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Best: \(progressManager.longestStreak)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceOpacity(0.85))
                .shadow(color: Color.appAccentOpacity(0.2), radius: 12, x: 0, y: 8)
        )
    }
    
    private var quickStartSection: some View {
        NavigationLink(destination: WorkoutSelectionView()
            .environmentObject(workoutManager)
            .environmentObject(progressManager)
            .environmentObject(settingsManager)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Start")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Begin your workout journey")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.appAccent, Color.appAccentOpacity(0.6)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Workouts")
                .font(.headline)
                .fontWeight(.semibold)
            
            if workoutManager.workoutHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "dumbbell")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No workouts yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Start your first workout to see your progress here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appSurfaceOpacity(0.3))
                )
            } else {
                ForEach(Array(workoutManager.workoutHistory.prefix(3)), id: \.id) { workout in
                    RecentWorkoutRow(workout: workout)
                }
            }
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceOpacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appAccentOpacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.15), radius: 10, x: 0, y: 6)
        )
    }
}

struct RecentWorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(workout.startTime, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(workout.actualDuration) min")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(workout.startTime, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurfaceOpacity(0.25))
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutManager())
        .environmentObject(ProgressManager())
        .environmentObject(SettingsManager())
} 
