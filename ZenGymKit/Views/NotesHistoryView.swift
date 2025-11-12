//
//  NotesHistoryView.swift
//  ZenGym
//
//

import SwiftUI

struct NotesHistoryView: View {
    @EnvironmentObject var notesManager: NotesManager
    @State private var searchText = ""
    @State private var selectedMood: Mood? = nil
    @State private var showingFilters = false
    @FocusState private var isSearchFocused: Bool
    
    var filteredNotes: [DailyNote] {
        var notes = notesManager.dailyNotes.sorted { $0.date > $1.date }
        
        // Filter by search text
        if !searchText.isEmpty {
            notes = notes.filter { note in
                note.nutrition.localizedCaseInsensitiveContains(searchText) ||
                note.workoutNotes.localizedCaseInsensitiveContains(searchText) ||
                note.generalNotes.localizedCaseInsensitiveContains(searchText) ||
                note.mood.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by mood
        if let mood = selectedMood {
            notes = notes.filter { $0.mood == mood }
        }
        
        return notes
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filter bar
                searchAndFilterSection
                
                if filteredNotes.isEmpty {
                    emptyStateView
                } else {
                    // Notes list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredNotes) { note in
                                NavigationLink(destination: NoteDetailView(note: note)) {
                                    NoteCardView(note: note)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.appGradient)
            .navigationTitle("Notes History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(selectedMood: $selectedMood)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isSearchFocused = false
                    }
                }
            }
            .hideKeyboardOnInteraction()
            .background(
                Color.appGradient
                    .ignoresSafeArea()
            )
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.appTextSecondary)
                    
                    TextField("Search notes...", text: $searchText)
                        .textFieldStyle(.plain)
                        .focused($isSearchFocused)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
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
            
            // Active filters
            if selectedMood != nil {
                HStack {
                    Text("Filters:")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                    
                    if let mood = selectedMood {
                        HStack(spacing: 4) {
                            Text(mood.emoji)
                            Text(mood.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appAccentOpacity(0.2))
                        )
                    }
                    
                    Spacer()
                    
                    Button("Clear") {
                        selectedMood = nil
                    }
                    .font(.caption)
                    .foregroundColor(.appAccent)
                }
                .padding(.horizontal)
            }
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
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("No Notes Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start adding daily notes to see them here")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
            
            if !searchText.isEmpty || selectedMood != nil {
                Button("Clear Filters") {
                    searchText = ""
                    selectedMood = nil
                }
                .foregroundColor(.appAccent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoteCardView: View {
    let note: DailyNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.date, style: .date)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(note.date, format: .dateTime.weekday())
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(note.mood.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(note.energyLevel)/10")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.appAccent)
                        
                        Text("Energy")
                            .font(.caption2)
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            
            // Quick stats
            HStack(spacing: 16) {
                StatItem(icon: "bed.double", value: String(format: "%.1f", note.sleepHours), unit: "hrs", color: .appAccentSecondary)
                StatItem(icon: "drop", value: "\(note.waterIntake)", unit: "glasses", color: .appAccentTertiary)
                if let weight = note.weight {
                    StatItem(icon: "scalemass", value: String(format: "%.1f", weight), unit: "kg", color: Color.appAccentOpacity(0.5))
                }
            }
            
            // Notes preview
            if !note.nutrition.isEmpty || !note.workoutNotes.isEmpty || !note.generalNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    if !note.nutrition.isEmpty {
                        NotePreviewRow(icon: "fork.knife", text: note.nutrition, color: .appAccent)
                    }
                    if !note.workoutNotes.isEmpty {
                        NotePreviewRow(icon: "dumbbell", text: note.workoutNotes, color: .appAccentSecondary)
                    }
                    if !note.generalNotes.isEmpty {
                        NotePreviewRow(icon: "note.text", text: note.generalNotes, color: Color.appAccentOpacity(0.4))
                    }
                }
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

struct StatItem: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
        }
    }
}

struct NotePreviewRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 12)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
        }
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMood: Mood?
    
    var body: some View {
        NavigationStack {
            List {
                Section("Mood Filter") {
                    Button("All Moods") {
                        selectedMood = nil
                        dismiss()
                    }
                    .foregroundColor(selectedMood == nil ? .appAccent : .appTextPrimary)
                    
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            dismiss()
                        }) {
                            HStack {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                                Spacer()
                                if selectedMood == mood {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.appAccent)
                                }
                            }
                        }
                        .foregroundColor(selectedMood == mood ? .appAccent : .appTextPrimary)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .dismissKeyboardOnTapAndScrollAggressive()
            .scrollContentBackground(.hidden)
            .background(
                Color.appGradient
                    .ignoresSafeArea()
            )
        }
    }
}

struct NoteDetailView: View {
    let note: DailyNote
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(note.date, style: .date)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(note.date, format: .dateTime.weekday())
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                
                // Mood and Energy
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text(note.mood.emoji)
                            .font(.title)
                        Text(note.mood.rawValue)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(note.energyLevel)/10")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appAccent)
                        Text("Energy")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                
                // Stats
                HStack(spacing: 16) {
                    DetailStatCard(title: "Sleep", value: String(format: "%.1f", note.sleepHours), unit: "hours", icon: "bed.double", color: .appAccentSecondary)
                    DetailStatCard(title: "Water", value: "\(note.waterIntake)", unit: "glasses", icon: "drop", color: .appAccentTertiary)
                }
                
                // Body metrics
                if note.weight != nil || note.bodyFat != nil || note.muscleMass != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Body Metrics")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 16) {
                            if let weight = note.weight {
                                DetailStatCard(title: "Weight", value: String(format: "%.1f", weight), unit: "kg", icon: "scalemass", color: Color.appAccentOpacity(0.5))
                            }
                            if let bodyFat = note.bodyFat {
                                DetailStatCard(title: "Body Fat", value: String(format: "%.1f", bodyFat), unit: "%", icon: "chart.pie", color: Color.appAccentOpacity(0.45))
                            }
                            if let muscleMass = note.muscleMass {
                                DetailStatCard(title: "Muscle", value: String(format: "%.1f", muscleMass), unit: "kg", icon: "figure.strengthtraining.traditional", color: Color.appAccentOpacity(0.35))
                            }
                        }
                    }
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 16) {
                    if !note.nutrition.isEmpty {
                        NoteDetailSection(title: "Nutrition", icon: "fork.knife", text: note.nutrition, color: .appAccent)
                    }
                    
                    if !note.workoutNotes.isEmpty {
                        NoteDetailSection(title: "Workout Notes", icon: "dumbbell", text: note.workoutNotes, color: .appAccentSecondary)
                    }
                    
                    if !note.generalNotes.isEmpty {
                        NoteDetailSection(title: "General Notes", icon: "note.text", text: note.generalNotes, color: Color.appAccentOpacity(0.35))
                    }
                }
            }
            .padding()
        }
        .background(
            Color.appGradient
                .ignoresSafeArea()
        )
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailStatCard: View {
    let title: String
    let value: String
    let unit: String
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
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct NoteDetailSection: View {
    let title: String
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(text)
                .font(.body)
                .foregroundColor(.appTextPrimary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: Color.appAccentOpacity(0.12), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    NotesHistoryView()
        .environmentObject(NotesManager())
} 