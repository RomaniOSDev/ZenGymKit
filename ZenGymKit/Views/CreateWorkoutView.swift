//
//  CreateWorkoutView.swift
//  ZenGym
//
//

import SwiftUI

struct CreateWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var notesManager: NotesManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName: String = ""
    @State private var workoutDescription: String = ""
    @State private var selectedDifficulty: WorkoutDifficulty = .beginner
    @State private var exercises: [Exercise] = []
    @State private var showingAddExercise = false
    
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case name, description
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section("Workout Details") {
                        TextField("Workout Name", text: $workoutName)
                            .focused($focusedField, equals: .name)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .description
                            }
                        
                        TextField("Description", text: $workoutDescription, axis: .vertical)
                            .focused($focusedField, equals: .description)
                            .lineLimit(2...4)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .onSubmit {
                                focusedField = nil
                            }
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(WorkoutDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue.capitalized)
                                    .tag(difficulty)
                            }
                        }
                    }
                    
                    Section("Exercises") {
                        if exercises.isEmpty {
                            Text("No exercises added yet")
                                .foregroundColor(.appTextSecondary)
                                .italic()
                        } else {
                            ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                                CreateWorkoutExerciseRow(exercise: exercise, index: index) { updatedExercise in
                                    exercises[index] = updatedExercise
                                } onDelete: {
                                    exercises.remove(at: index)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                
                // Add Exercise button outside of Form
                VStack {
                    Button(action: {
                        print("Add Exercise button tapped")
                        showingAddExercise = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.appAccent)
                            Text("Add Exercise")
                                .foregroundColor(.appAccent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .background(Color.appAccentOpacity(0.18))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color.appSurfaceSoft)
            }
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || exercises.isEmpty)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Previous") {
                        switch focusedField {
                        case .description:
                            focusedField = .name
                        default:
                            focusedField = nil
                        }
                    }
                    .disabled(focusedField == .name)
                    
                    Button("Next") {
                        switch focusedField {
                        case .name:
                            focusedField = .description
                        case .description:
                            focusedField = nil
                        default:
                            break
                        }
                    }
                    .disabled(focusedField == .description)
                    
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView { exercise in
                    exercises.append(exercise)
                    showingAddExercise = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .dismissKeyboardOnTap()
        }
        .background(
            Color.appGradient
                .ignoresSafeArea()
        )
    }
    
    private func saveWorkout() {
        let newWorkout = WorkoutTemplate(
            id: UUID(),
            name: workoutName,
            description: workoutDescription,
            exercises: exercises,
            estimatedDuration: calculateDuration(),
            difficulty: selectedDifficulty
        )
        
        workoutManager.availableWorkouts.append(newWorkout)
        dismiss()
    }
    
    private func calculateDuration() -> Int {
        let exerciseTime = exercises.reduce(0) { total, exercise in
            total + (exercise.sets * 2) // 2 minutes per set
        }
        let restTime = exercises.reduce(0) { total, exercise in
            total + (exercise.sets - 1) * exercise.restTime / 60 // Convert rest time to minutes
        }
        return max(10, exerciseTime + restTime) // Minimum 10 minutes
    }
}

struct CreateWorkoutExerciseRow: View {
    let exercise: Exercise
    let index: Int
    let onUpdate: (Exercise) -> Void
    let onDelete: () -> Void
    
    @State private var showingEdit = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                Text("\(exercise.sets) sets × \(exercise.reps) reps")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            Button(action: {
                showingEdit = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.appAccent)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(Color.appAccentOpacity(0.5))
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditExerciseView(exercise: exercise) { updatedExercise in
                onUpdate(updatedExercise)
            }
        }
    }
}

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Exercise) -> Void
    
    @State private var exerciseName: String = ""
    @State private var sets: Int = 3
    @State private var reps: Int = 10
    @State private var restTime: Int = 60
    
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $exerciseName)
                        .focused($isNameFocused)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit {
                            isNameFocused = false
                        }
                    
                    Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                    Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                    Stepper("Rest: \(restTime)s", value: $restTime, in: 30...300, step: 15)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let exercise = Exercise(
                            name: exerciseName,
                            sets: sets,
                            reps: reps,
                            restTime: restTime
                        )
                        onAdd(exercise)
                        dismiss()
                    }
                    .disabled(exerciseName.isEmpty)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNameFocused = false
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
            .dismissKeyboardOnTap()
        }
    }
}

struct EditExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    let onUpdate: (Exercise) -> Void
    
    @State private var exerciseName: String
    @State private var sets: Int
    @State private var reps: Int
    @State private var restTime: Int
    
    @FocusState private var isNameFocused: Bool
    
    init(exercise: Exercise, onUpdate: @escaping (Exercise) -> Void) {
        self.exercise = exercise
        self.onUpdate = onUpdate
        self._exerciseName = State(initialValue: exercise.name)
        self._sets = State(initialValue: exercise.sets)
        self._reps = State(initialValue: exercise.reps)
        self._restTime = State(initialValue: exercise.restTime)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $exerciseName)
                        .focused($isNameFocused)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit {
                            isNameFocused = false
                        }
                    
                    Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                    Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                    Stepper("Rest: \(restTime)s", value: $restTime, in: 30...300, step: 15)
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedExercise = Exercise(
                            name: exerciseName,
                            sets: sets,
                            reps: reps,
                            restTime: restTime
                        )
                        onUpdate(updatedExercise)
                        dismiss()
                    }
                    .disabled(exerciseName.isEmpty)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNameFocused = false
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
            .dismissKeyboardOnTap()
        }
    }
}

#Preview {
    CreateWorkoutView()
        .environmentObject(WorkoutManager())
        .environmentObject(NotesManager())
} 