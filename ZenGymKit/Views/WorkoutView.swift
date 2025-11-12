//
//  WorkoutView.swift
//  ZenGym
//
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notesManager: NotesManager
    @State private var selectedDifficulty: WorkoutDifficulty? = nil
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showingCreateWorkout = false
    
    var filteredWorkouts: [WorkoutTemplate] {
        var workouts = workoutManager.availableWorkouts
        
        // Filter by difficulty
        if let difficulty = selectedDifficulty {
            workouts = workouts.filter { $0.difficulty == difficulty }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            workouts = workouts.filter { workout in
                workout.name.localizedCaseInsensitiveContains(searchText) ||
                workout.description.localizedCaseInsensitiveContains(searchText) ||
                workout.exercises.contains { exercise in
                    exercise.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        return workouts
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchSection
                
                // Filter buttons
                filterSection
                
                // Workouts list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredWorkouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)
                                .environmentObject(workoutManager)
                                .environmentObject(progressManager)
                                .environmentObject(settingsManager)
                                .environmentObject(notesManager)) {
                                WorkoutCard(workout: workout)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .background(Color.appGradient)
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateWorkout = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appAccent)
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isSearchFocused = false
                    }
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
                    .environmentObject(workoutManager)
                    .environmentObject(notesManager)
            }
            .dismissKeyboardOnTapAndScrollAggressive()
            .background(
                Color.appGradient
                    .ignoresSafeArea()
            )
        }
    }
    
    private var searchSection: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appTextSecondary)
                
                TextField("Search workouts...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        isSearchFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSurfaceSoft)
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            Color.appSurfaceStrong
                .overlay(
                    Rectangle()
                        .fill(Color.appAccentOpacity(0.08))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(
                    title: "All",
                    isSelected: selectedDifficulty == nil
                ) {
                    selectedDifficulty = nil
                }
                
                ForEach(WorkoutDifficulty.allCases, id: \.self) { difficulty in
                    FilterButton(
                        title: difficulty.rawValue,
                        isSelected: selectedDifficulty == difficulty,
                        color: difficultyColor(for: difficulty)
                    ) {
                        selectedDifficulty = difficulty
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(
            Color.appSurfaceStrong
                .overlay(
                    Rectangle()
                        .fill(Color.appAccentOpacity(0.08))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
    
    private func difficultyColor(for difficulty: WorkoutDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .appAccentTertiary
        case .intermediate: return .appAccentSecondary
        case .advanced: return .appAccent
        }
    }
}

struct WorkoutCard: View {
    let workout: WorkoutTemplate
    
    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)
                        
                        Text(workout.description)
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(workout.estimatedDuration) min")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appAccent)
                        
                        Text("\(workout.exercises.count) exercises")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                
                HStack {
                    Label("\(workout.exercises.count) exercises", systemImage: "dumbbell")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                    
                    Spacer()
                    
                    DifficultyBadge(difficulty: workout.difficulty)
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
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = .appAccent
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : Color.appSurfaceSoft)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DifficultyBadge: View {
    let difficulty: WorkoutDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
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
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return .appAccentTertiary
        case .intermediate: return .appAccentSecondary
        case .advanced: return .appAccent
        }
    }
}

#Preview {
    WorkoutView()
        .environmentObject(WorkoutManager())
        .environmentObject(ProgressManager())
        .environmentObject(SettingsManager())
        .environmentObject(NotesManager())
} 
