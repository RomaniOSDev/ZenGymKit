//
//  ProgressView.swift
//  ZenGym
//
//

import SwiftUI

struct ProgressTrackingView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var refreshTrigger = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time frame selector
                timeFrameSelector
                
                // Overview stats
                overviewSection
                
                // Progress charts
                chartsSection
                
                // Achievements
                achievementsSection
                
                // Workout history
                historySection
            }
            .padding()
        }
        .background(Color.appGradient)
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            progressManager.setWorkoutManager(workoutManager)
        }
        .onChange(of: workoutManager.workoutHistory.count) { _ in
            progressManager.updateStats()
        }
        .onReceive(workoutManager.$workoutHistory) { _ in
            // Force refresh when workout history changes
            refreshTrigger.toggle()
        }
    }
    
    private var timeFrameSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    selectedTimeFrame = timeFrame
                }) {
                    Text(timeFrame.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeFrame == timeFrame ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTimeFrame == timeFrame ? Color.appAccent : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appSurfaceSoft)
        )
    }
    
    private var overviewSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ProgressStatCard(
                title: "Workouts",
                value: "\(selectedTimeFrameStats.workoutsCompleted)",
                subtitle: "completed",
                icon: "dumbbell.fill",
                color: .appAccent
            )
            
            ProgressStatCard(
                title: "Time",
                value: "\(selectedTimeFrameStats.totalTime)",
                subtitle: "minutes",
                icon: "clock.fill",
                color: .appAccentSecondary
            )
            
            ProgressStatCard(
                title: "Average",
                value: "\(selectedTimeFrameStats.averageTime)",
                subtitle: "min/workout",
                icon: "chart.bar.fill",
                color: .appAccentTertiary
            )
            
            ProgressStatCard(
                title: "Streak",
                value: "\(progressManager.currentStreak)",
                subtitle: "days",
                icon: "flame.fill",
                color: Color.appAccentOpacity(0.45)
            )
        }
    }
    
    private var chartsSection: some View {
        VStack(spacing: 16) {
            Text("Progress Charts")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Weekly progress chart
                SimpleWeeklyChart(workoutManager: workoutManager, refreshTrigger: refreshTrigger)
                
                // Workout frequency chart
                SimpleFrequencyChart(workoutManager: workoutManager, refreshTrigger: refreshTrigger)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appAccentOpacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
    
    private var achievementsSection: some View {
        VStack(spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AchievementCard(
                    title: "First Workout",
                    description: "Complete your first workout",
                    isUnlocked: progressManager.totalWorkouts > 0,
                    icon: "star.fill"
                )
                
                AchievementCard(
                    title: "Week Warrior",
                    description: "Complete 5 workouts in a week",
                    isUnlocked: progressManager.weeklyStats.workoutsCompleted >= 5,
                    icon: "calendar.badge.clock"
                )
                
                AchievementCard(
                    title: "Streak Master",
                    description: "Maintain a 7-day streak",
                    isUnlocked: progressManager.currentStreak >= 7,
                    icon: "flame.fill"
                )
                
                AchievementCard(
                    title: "Time Champion",
                    description: "Complete 10 hours of workouts",
                    isUnlocked: progressManager.totalWorkoutTime >= 600,
                    icon: "clock.badge.checkmark"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appAccentOpacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
    
    private var historySection: some View {
        VStack(spacing: 12) {
            Text("Recent History")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if workoutManager.workoutHistory.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No workout history yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSurfaceSoft)
                )
            } else {
                ForEach(Array(workoutManager.workoutHistory.prefix(5)), id: \.id) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appAccentOpacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
    
    private var selectedTimeFrameStats: (workoutsCompleted: Int, totalTime: Int, averageTime: Int) {
        switch selectedTimeFrame {
        case .week:
            return (progressManager.weeklyStats.workoutsCompleted, progressManager.weeklyStats.totalTime, progressManager.weeklyStats.averageTime)
        case .month:
            return (progressManager.monthlyStats.workoutsCompleted, progressManager.monthlyStats.totalTime, progressManager.monthlyStats.averageTime)
        case .year:
            return (progressManager.totalWorkouts, progressManager.totalWorkoutTime, progressManager.totalWorkouts > 0 ? progressManager.totalWorkoutTime / progressManager.totalWorkouts : 0)
        }
    }
    

}

// MARK: - Simple Chart Components

struct SimpleWeeklyChart: View {
    let workoutManager: WorkoutManager
    let refreshTrigger: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Progress (minutes)")
                .font(.subheadline)
                .fontWeight(.medium)
            
            let data = getWeeklyData()
            
            if data.allSatisfy({ $0 == 0 }) {
                Text("No workouts this week")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 80)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.appAccentOpacity(0.8))
                                .frame(width: 30, height: max(20, CGFloat(value * 0.6)))
                                .animation(.easeInOut(duration: 0.3), value: value)
                            
                            if value > 0 {
                                Text("\(Int(value))m")
                                    .font(.caption2)
                                    .foregroundColor(.appAccent)
                                    .fontWeight(.medium)
                            }
                            
                            Text("D\(index + 1)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 120)
            }
        }
    }
    
    private func getWeeklyData() -> [Double] {
        let calendar = Calendar.current
        let now = Date()
        var dailyData: [Double] = []
        
        print("SimpleWeeklyChart: Calculating data. Total workouts: \(workoutManager.workoutHistory.count)")
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayStart = calendar.startOfDay(for: date)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
                
                let dayWorkouts = workoutManager.workoutHistory.filter { workout in
                    workout.isCompleted && 
                    workout.startTime >= dayStart && 
                    workout.startTime < dayEnd
                }
                

                
                let totalTime = dayWorkouts.reduce(0) { $0 + $1.actualDuration }
                dailyData.append(Double(totalTime))
                
                print("Day \(i+1): \(dayWorkouts.count) workouts, \(totalTime) minutes")
            }
        }
        
        print("Weekly data result: \(dailyData)")
        return dailyData.reversed()
    }
}

struct SimpleFrequencyChart: View {
    let workoutManager: WorkoutManager
    let refreshTrigger: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workout Frequency (count)")
                .font(.subheadline)
                .fontWeight(.medium)
            
            let data = getWeeklyFrequency()
            
            if data.allSatisfy({ $0 == 0 }) {
                Text("No workouts in the last 7 weeks")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 80)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.appAccentOpacity(0.7))
                                .frame(width: 30, height: max(20, CGFloat(value * 15)))
                                .animation(.easeInOut(duration: 0.3), value: value)
                            
                            if value > 0 {
                                Text("\(value)")
                                    .font(.caption2)
                                    .foregroundColor(.appAccentSecondary)
                                    .fontWeight(.medium)
                            }
                            
                            Text("W\(index + 1)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 120)
            }
        }
    }
    
    private func getWeeklyFrequency() -> [Int] {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [Int] = []
        
        print("SimpleFrequencyChart: Calculating data. Total workouts: \(workoutManager.workoutHistory.count)")
        
        for i in 0..<7 {
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: now) {
                let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart)
                let weekEnd = weekInterval?.end ?? weekStart
                
                let weekWorkouts = workoutManager.workoutHistory.filter { workout in
                    workout.isCompleted && 
                    workout.startTime >= weekStart && 
                    workout.startTime < weekEnd
                }
                
                weeklyData.append(weekWorkouts.count)
                
                if weekWorkouts.count > 0 {
                    print("Week \(i+1): \(weekWorkouts.count) workouts")
                }
            }
        }
        
        print("Frequency data result: \(weeklyData)")
        return weeklyData.reversed()
    }
}

enum TimeFrame: CaseIterable {
    case week, month, year
    
    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurfaceMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appAccentOpacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.08), radius: 6, x: 0, y: 4)
        )
    }
}

struct AchievementCard: View {
    let title: String
    let description: String
    let isUnlocked: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .appAccent : Color.appAccentOpacity(0.35))
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.appAccentOpacity(0.18) : Color.appSurfaceSoft)
        )
    }
}

struct WorkoutHistoryRow: View {
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
                .fill(Color.appSurfaceSoft)
        )
    }
}

#Preview {
    ProgressTrackingView()
        .environmentObject(ProgressManager())
        .environmentObject(WorkoutManager())
        .environmentObject(SettingsManager())
} 
