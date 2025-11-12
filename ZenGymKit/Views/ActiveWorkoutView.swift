//
//  ActiveWorkoutView.swift
//  ZenGym
//
//

import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss

    @State private var currentExerciseIndex = 0
    @State private var currentSet = 1
    @State private var timeRemaining = 0
    @State private var isResting = false
    @State private var showingCompleteAlert = false
    @Namespace private var animation
    @State private var isWorkoutStarted = false
    @State private var workoutTimer: Timer?
    @State private var elapsedTime: Int = 0
    @State private var workoutNotes: String = ""
    @FocusState private var isNotesFocused: Bool

    private var currentWorkout: Workout? { workoutManager.currentWorkout }
    private var currentExercise: Exercise? {
        guard let workout = currentWorkout,
              currentExerciseIndex < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex]
    }

    var body: some View {
        ZStack {
            // Фон
            Color.appGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button("Exit") {
                        showingCompleteAlert = true
                    }
                    .foregroundColor(Color.appAccentOpacity(0.5))
                    .font(.headline)
                    Spacer()
                    Text("Active Workout")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Название и прогресс
                VStack(spacing: 8) {
                    Text(currentWorkout?.name ?? "Workout")
                        .font(.title)
                        .fontWeight(.bold)
                        .matchedGeometryEffect(id: "workoutName", in: animation)

                    Text("Exercise \(currentExerciseIndex + 1) of \(currentWorkout?.exercises.count ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    ProgressView(value: Double(currentExerciseIndex + (currentSet > 1 ? 1 : 0)), total: Double(currentWorkout?.exercises.count ?? 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: .appAccent))
                        .scaleEffect(y: 1.5)
                        .padding(.horizontal)
                }
                .padding(.top, 8)

                Spacer(minLength: 0)

                // Карточка упражнения с анимацией
                if let exercise = currentExercise {
                    ExerciseCardView(
                        exercise: exercise,
                        set: currentSet,
                        isResting: isResting,
                        timeRemaining: timeRemaining,
                        animation: animation
                    )
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    .id("\(currentExerciseIndex)-\(currentSet)-\(isResting)")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }

                Spacer(minLength: 0)

                // Время тренировки и заметки
                HStack(spacing: 16) {
                    // Время тренировки
                    VStack(spacing: 4) {
                        Text("Workout Time")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text(formatTime(elapsedTime))
                            .font(.title2.monospacedDigit())
                            .fontWeight(.bold)
                            .foregroundColor(.appAccent)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appSurfaceStrong)
                            .shadow(color: Color.appAccentOpacity(0.12), radius: 8, x: 0, y: 4)
                    )
                    
                    // Заметки
                    VStack(spacing: 4) {
                        Text("Notes")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        TextField("Add notes...", text: $workoutNotes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .focused($isNotesFocused)
                            .lineLimit(1...3)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                // Панель управления
                controlsSection
            }
            .padding(.bottom, 8)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentExerciseIndex)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentSet)
        .onDisappear {
            stopWorkoutTimer()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isNotesFocused = false
                }
            }
        }
        .alert("Exit Workout?", isPresented: $showingCompleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                stopWorkoutTimer()
                workoutManager.currentWorkout = nil
                workoutManager.isWorkoutActive = false
            }
        } message: {
            Text("Are you sure you want to exit? Your progress will be lost.")
        }
        .dismissKeyboardOnTapAndScrollAggressive()
    }

    private var controlsSection: some View {
        VStack(spacing: 16) {
            // Кнопка Start/Pause
            Button(action: toggleWorkout) {
                Text(isWorkoutStarted ? "Pause" : "Start")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: isWorkoutStarted ? [Color.appSurfaceMedium, Color.appSurfaceSoft] : [Color.appAccent, Color.appAccentSecondary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: (isWorkoutStarted ? Color.appSurfaceSoft : Color.appAccentOpacity(0.4)), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            
            // Панель с кнопками управления
            if isWorkoutStarted {
                HStack(spacing: 24) {
                    // Левая стрелка
                    if currentExerciseIndex > 0 {
                        Button(action: previousExercise) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .foregroundColor(.appTextPrimary)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                                .shadow(color: Color.appAccentOpacity(0.12), radius: 4, x: 0, y: 2)
                        }
                        .transition(.scale)
                    }

                    // Главная кнопка
                    Button(action: {
                        print("Main action button tapped. canFinishWorkout: \(canFinishWorkout)")
                        if canFinishWorkout {
                            print("Finishing workout...")
                            completeWorkout()
                        } else {
                            print("Next set...")
                            nextSet()
                        }
                    }) {
                        Text(mainActionTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                            gradient: Gradient(colors: canFinishWorkout ? [Color.appAccentSecondary, Color.appAccentTertiary] : [Color.appAccent, Color.appAccentSecondary]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                    .shadow(color: (canFinishWorkout ? Color.appAccentOpacity(0.28) : Color.appAccentOpacity(0.35)), radius: 8, x: 0, y: 4)
                    }
                    .frame(maxWidth: 220)

                    // Правая стрелка
                    if currentExerciseIndex < (currentWorkout?.exercises.count ?? 0) - 1 {
                        Button(action: nextExercise) {
                            Image(systemName: "chevron.right")
                                .font(.title2.bold())
                                .foregroundColor(.appTextPrimary)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                                .shadow(color: Color.appAccentOpacity(0.12), radius: 4, x: 0, y: 2)
                        }
                        .transition(.scale)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    BlurView(style: .systemMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.appAccentOpacity(0.12), radius: 12, x: 0, y: -2)
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.bottom, 12)
        .animation(.easeInOut, value: currentExerciseIndex)
        .animation(.easeInOut, value: currentSet)
        .animation(.easeInOut, value: isWorkoutStarted)
    }

    private var mainActionTitle: String {
        if let exercise = currentExercise {
            if currentSet < exercise.sets {
                return "Complete Set"
            } else if currentExerciseIndex < (currentWorkout?.exercises.count ?? 0) - 1 {
                return "Next Exercise"
            } else {
                return "Finish Workout"
            }
        }
        return "Complete"
    }
    
    private var canFinishWorkout: Bool {
        guard let exercise = currentExercise else { 
            print("canFinishWorkout: No current exercise")
            return false 
        }
        let canFinish = currentSet >= exercise.sets && currentExerciseIndex >= (currentWorkout?.exercises.count ?? 0) - 1
        print("canFinishWorkout: currentSet=\(currentSet), exercise.sets=\(exercise.sets), currentExerciseIndex=\(currentExerciseIndex), totalExercises=\(currentWorkout?.exercises.count ?? 0), canFinish=\(canFinish)")
        return canFinish
    }

    private func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return String(format: "%d:%02d", hours, remainingMinutes)
        } else {
            return String(format: "%d:%02d", remainingMinutes, 0)
        }
    }

    // --- Логика переходов и таймеров оставь как было ---
    private func nextSet() {
        guard let exercise = currentExercise else { return }
        if isResting {
            // Skip rest
            isResting = false
            timeRemaining = 0
        } else {
            if currentSet < exercise.sets {
                currentSet += 1
                startRestTimer()
            } else {
                nextExercise()
            }
        }
    }

    private func nextExercise() {
        guard let workout = currentWorkout else { return }
        if currentExerciseIndex < workout.exercises.count - 1 {
            currentExerciseIndex += 1
            currentSet = 1
            isResting = false
            timeRemaining = 0
        } else {
            // Тренировка завершена
            completeWorkout()
        }
    }

    private func previousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSet = 1
            isResting = false
            timeRemaining = 0
        }
    }

    private func startRestTimer() {
        guard let exercise = currentExercise else { return }
        isResting = true
        timeRemaining = exercise.restTime
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                isResting = false
            }
        }
    }

    private func completeWorkout() {
        print("ActiveWorkoutView: completeWorkout() called")
        stopWorkoutTimer()
        print("ActiveWorkoutView: Calling workoutManager.completeWorkout()")
        workoutManager.completeWorkout()
        print("ActiveWorkoutView: completeWorkout() finished")
    }

    private func toggleWorkout() {
        isWorkoutStarted.toggle()
        if isWorkoutStarted {
            if let firstTemplate = workoutManager.availableWorkouts.first {
                workoutManager.startWorkout(firstTemplate)
                if elapsedTime == 0 {
                    elapsedTime = 0
                }
                startWorkoutTimer()
            }
        } else {
            workoutManager.pauseWorkout()
            stopWorkoutTimer()
        }
    }
    
    private func startWorkoutTimer() {
        if workoutTimer == nil {
            workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedTime += 1
            }
        }
    }
    
    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
}

struct ExerciseCardView: View {
    let exercise: Exercise
    let set: Int
    let isResting: Bool
    let timeRemaining: Int
    var animation: Namespace.ID

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.appAccentOpacity(0.2))
                    .frame(width: 100, height: 100)
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.appAccent)
            }
            .matchedGeometryEffect(id: "icon", in: animation)

            Text(exercise.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .matchedGeometryEffect(id: "name", in: animation)

            VStack(spacing: 4) {
                Text("Set \(set) of \(exercise.sets)")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                Text("\(exercise.reps) reps")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.appAccentSecondary)
            }

            if isResting {
                VStack(spacing: 4) {
                    Text("Rest Time")
                        .font(.headline)
                        .foregroundColor(.appTextSecondary)
                    Text("\(timeRemaining)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                    Text("seconds")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                .transition(.opacity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.appAccentOpacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.16), radius: 10, x: 0, y: 6)
        )
        .animation(.easeInOut, value: isResting)
    }
}

#Preview {
    ActiveWorkoutView()
        .environmentObject(WorkoutManager())
        .environmentObject(ProgressManager())
        .environmentObject(SettingsManager())
} 
