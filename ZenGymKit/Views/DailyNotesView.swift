//
//  DailyNotesView.swift
//  ZenGym
//
//

import SwiftUI

struct DailyNotesView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Date selector
                    dateSelectorSection
                    
                    // Quick stats
                    quickStatsSection
                    
                    // Main note form
                    noteFormSection
                    
                    // Analytics
                    analyticsSection
                }
                .padding()
            }
            .background(Color.appGradient)
            .navigationTitle("Daily Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: NotesHistoryView()
                        .environmentObject(notesManager)
                        .environmentObject(settingsManager)) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.appAccent)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDate: $selectedDate)
            }
                    .onChange(of: selectedDate) { _ in
            notesManager.selectedDate = selectedDate
        }
        .dismissKeyboardOnTapAndScrollAggressive()
        .background(
            Color.appGradient
                .ignoresSafeArea()
        )
        }
    }
    
    private var dateSelectorSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.appAccent)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(selectedDate, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(selectedDate, format: .dateTime.weekday())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    if tomorrow <= Date() {
                        selectedDate = tomorrow
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate <= Date() ? .appAccent : Color.appSurfaceSoft)
                }
                .disabled(Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate > Date())
            }
            .padding(.horizontal)
            
            // Quick navigation buttons
            HStack(spacing: 12) {
                ForEach([-7, -3, -1, 0], id: \.self) { days in
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
                    }) {
                        Text(days == 0 ? "Today" : "\(days > 0 ? "+" : "")\(days)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()) ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()) ? Color.appAccent : Color.appSurfaceSoft)
                            )
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
    
    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            DailyNotesStatCard(
                title: "Mood",
                value: notesManager.getNote(for: selectedDate).mood.emoji,
                subtitle: notesManager.getNote(for: selectedDate).mood.rawValue,
                color: .appAccent
            )
            
            DailyNotesStatCard(
                title: "Sleep",
                value: String(format: "%.1f", notesManager.getNote(for: selectedDate).sleepHours),
                subtitle: "hours",
                color: .appAccentSecondary
            )
            
            DailyNotesStatCard(
                title: "Water",
                value: "\(notesManager.getNote(for: selectedDate).waterIntake)",
                subtitle: "glasses",
                color: .appAccentTertiary
            )
        }
    }
    
    private var noteFormSection: some View {
        DailyNoteFormView(date: selectedDate)
            .environmentObject(notesManager)
    }
    
    private var analyticsSection: some View {
        VStack(spacing: 16) {
            Text("Weekly Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                DailyNotesAnalyticsCard(
                    title: "Avg Mood",
                    value: String(format: "%.1f", notesManager.getWeeklyMoodAverage()),
                    icon: "face.smiling",
                    color: .appAccent
                )
                
                DailyNotesAnalyticsCard(
                    title: "Avg Sleep",
                    value: String(format: "%.1f", notesManager.getWeeklySleepAverage()),
                    icon: "bed.double",
                    color: .appAccentSecondary
                )
                
                DailyNotesAnalyticsCard(
                    title: "Avg Water",
                    value: String(format: "%.0f", notesManager.getWeeklyWaterAverage()),
                    icon: "drop",
                    color: .appAccentTertiary
                )
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(notesManager.getCurrentStreak()) days")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.appAccent)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appAccentOpacity(0.18))
            )
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

struct DailyNotesStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.35), lineWidth: 1)
                )
        )
    }
}

struct DailyNotesAnalyticsCard: View {
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
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurfaceSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct DatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .tint(.appAccent)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .dismissKeyboardOnTapAndScrollAggressive()
            .background(
                Color.appGradient
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    DailyNotesView()
        .environmentObject(NotesManager())
        .environmentObject(SettingsManager())
} 