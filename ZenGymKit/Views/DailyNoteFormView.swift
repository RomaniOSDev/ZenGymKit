//
//  DailyNoteFormView.swift
//  ZenGym
//
//

import SwiftUI

struct DailyNoteFormView: View {
    @EnvironmentObject var notesManager: NotesManager
    let date: Date
    
    @State private var note: DailyNote
    @FocusState private var focusedField: FocusedField?
    @State private var showingSaveConfirmation = false
    
    enum FocusedField {
        case nutrition, workoutNotes, generalNotes, weight, bodyFat, muscleMass
    }
    
    init(date: Date) {
        self.date = date
        self._note = State(initialValue: DailyNote(date: date))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Mood and Energy Section
            moodAndEnergySection
            
            // Sleep and Water Section
            sleepAndWaterSection
            
            // Body Metrics Section
            bodyMetricsSection
            
            // Notes Section
            notesSection
            
            // Save Button
            saveButton
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
        .onAppear {
            note = notesManager.getNote(for: date)
        }
        .onChange(of: date) { _ in
            note = notesManager.getNote(for: date)
        }
        .dismissKeyboardOnTapAndScrollAggressive()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Previous") {
                    moveToPreviousField()
                }
                .disabled(isFirstField())
                
                Button("Next") {
                    moveToNextField()
                }
                .disabled(isLastField())
                
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .background(
            Color.appGradient
                .ignoresSafeArea()
        )
    }
    
    private var moodAndEnergySection: some View {
        VStack(spacing: 16) {
            Text("Mood & Energy")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Mood Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("How are you feeling today?")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                
                HStack(spacing: 12) {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button(action: {
                            note.mood = mood
                            notesManager.updateNote(note)
                        }) {
                            VStack(spacing: 4) {
                                Text(mood.emoji)
                                    .font(.title2)
                                
                                Text(mood.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(note.mood == mood ? Color.appAccentOpacity(0.2) : Color.appSurfaceSoft)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(note.mood == mood ? Color.appAccent : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Energy Level
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Energy Level")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    Spacer()
                    
                    Text("\(note.energyLevel)/10")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appAccent)
                }
                
                Slider(value: Binding(
                    get: { Double(note.energyLevel) },
                    set: { 
                        note.energyLevel = Int($0)
                        notesManager.updateNote(note)
                    }
                ), in: 1...10, step: 1)
                .accentColor(.appAccent)
            }
        }
    }
    
    private var sleepAndWaterSection: some View {
        VStack(spacing: 16) {
            Text("Sleep & Hydration")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // Sleep Hours
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sleep Hours")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    HStack {
                        Text(String(format: "%.1f", note.sleepHours))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appAccentSecondary)
                        
                        Text("hrs")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Slider(value: Binding(
                        get: { note.sleepHours },
                        set: { 
                            note.sleepHours = $0
                            notesManager.updateNote(note)
                        }
                    ), in: 0...12, step: 0.5)
                    .accentColor(.appAccentSecondary)
                }
                
                // Water Intake
                VStack(alignment: .leading, spacing: 8) {
                    Text("Water Intake")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    HStack {
                        Text("\(note.waterIntake)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appAccentTertiary)
                        
                        Text("glasses")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            if note.waterIntake > 0 {
                                note.waterIntake -= 1
                                notesManager.updateNote(note)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.appAccentTertiary)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(note.waterIntake) },
                            set: { 
                                note.waterIntake = Int($0)
                                notesManager.updateNote(note)
                            }
                        ), in: 0...20, step: 1)
                        .accentColor(.appAccentTertiary)
                        
                        Button(action: {
                            note.waterIntake += 1
                            notesManager.updateNote(note)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.appAccentTertiary)
                        }
                    }
                }
            }
        }
    }
    
    private var bodyMetricsSection: some View {
        VStack(spacing: 16) {
            Text("Body Metrics")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    TextField("kg", value: Binding(
                        get: { note.weight ?? 0 },
                        set: { 
                            note.weight = $0
                            notesManager.updateNote(note)
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weight)
                }
                
                // Body Fat
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body Fat %")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    TextField("%", value: Binding(
                        get: { note.bodyFat ?? 0 },
                        set: { 
                            note.bodyFat = $0
                            notesManager.updateNote(note)
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .bodyFat)
                }
                
                // Muscle Mass
                VStack(alignment: .leading, spacing: 8) {
                    Text("Muscle Mass")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    TextField("kg", value: Binding(
                        get: { note.muscleMass ?? 0 },
                        set: { 
                            note.muscleMass = $0
                            notesManager.updateNote(note)
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .muscleMass)
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(spacing: 16) {
            Text("Notes")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Nutrition Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nutrition")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    TextField("What did you eat today?", text: Binding(
                        get: { note.nutrition },
                        set: { 
                            note.nutrition = $0
                            notesManager.updateNote(note)
                        }
                    ), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .focused($focusedField, equals: .nutrition)
                }
                
                // Workout Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Notes")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    TextField("How was your workout?", text: Binding(
                        get: { note.workoutNotes },
                        set: { 
                            note.workoutNotes = $0
                            notesManager.updateNote(note)
                        }
                    ), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .focused($focusedField, equals: .workoutNotes)
                }
                
                // General Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("General Notes")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    TextField("Any other thoughts for today?", text: Binding(
                        get: { note.generalNotes },
                        set: { 
                            note.generalNotes = $0
                            notesManager.updateNote(note)
                        }
                    ), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .focused($focusedField, equals: .generalNotes)
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            notesManager.updateNote(note)
            showingSaveConfirmation = true
            
            // Hide confirmation after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingSaveConfirmation = false
            }
        }) {
            HStack {
                if showingSaveConfirmation {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appAccent)
                }
                
                Text(showingSaveConfirmation ? "Saved!" : "Save Note")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: showingSaveConfirmation ? [Color.appAccentSecondary, Color.appAccentTertiary] : [Color.appAccent, Color.appAccentSecondary]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: showingSaveConfirmation ? Color.appAccentOpacity(0.28) : Color.appAccentOpacity(0.32), radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.3), value: showingSaveConfirmation)
        }
        .disabled(showingSaveConfirmation)
    }
    
    // MARK: - Keyboard Navigation
    
    private func moveToPreviousField() {
        switch focusedField {
        case .nutrition:
            focusedField = .muscleMass
        case .workoutNotes:
            focusedField = .nutrition
        case .generalNotes:
            focusedField = .workoutNotes
        case .weight:
            focusedField = .generalNotes
        case .bodyFat:
            focusedField = .weight
        case .muscleMass:
            focusedField = .bodyFat
        case .none:
            focusedField = .generalNotes
        }
    }
    
    private func moveToNextField() {
        switch focusedField {
        case .nutrition:
            focusedField = .workoutNotes
        case .workoutNotes:
            focusedField = .generalNotes
        case .generalNotes:
            focusedField = .weight
        case .weight:
            focusedField = .bodyFat
        case .bodyFat:
            focusedField = .muscleMass
        case .muscleMass:
            focusedField = .nutrition
        case .none:
            focusedField = .nutrition
        }
    }
    
    private func isFirstField() -> Bool {
        focusedField == .nutrition
    }
    
    private func isLastField() -> Bool {
        focusedField == .muscleMass
    }
}

#Preview {
    DailyNoteFormView(date: Date())
        .environmentObject(NotesManager())
} 