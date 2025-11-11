//
//  SettingsView.swift
//  ZenGym
//
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var notesManager: NotesManager
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // App Settings
                Section("App Settings") {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.appAccentSecondary)
                            .frame(width: 24)
                        
                        Text("Dark mode always on")
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }

                }
                
                // Support & Actions
                Section("Support & Actions") {
                    Button(action: {
                        settingsManager.rateApp()
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.appAccent)
                                .frame(width: 24)
                            
                            Text("Rate App")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        settingsManager.openPrivacyPolicy()
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.appAccentTertiary)
                                .frame(width: 24)
                            
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    

                }
                
                // Data Management
                Section("Data Management") {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(Color.appAccentOpacity(0.5))
                                .frame(width: 24)
                            
                            Text("Reset All Data")
                                .foregroundColor(Color.appAccentOpacity(0.5))
                            
                            Spacer()
                        }
                    }
                }
                
                // App Info
                Section("App Info") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.appAccentTertiary)
                            .frame(width: 24)
                        
                        Text("Version")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.appAccentSecondary)
                            .frame(width: 24)
                        
                        Text("Total Workouts")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(workoutManager.workoutHistory.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.appAccent)
                            .frame(width: 24)
                        
                        Text("Current Streak")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(progressManager.currentStreak) days")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .background(
            Color.appGradient
                .ignoresSafeArea()
        )

        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will reset all your settings and data. This action cannot be undone.")
        }
    }
    
    private func resetAllData() {
        print("Resetting all data...")
        
        // Reset settings
        settingsManager.resetAllData(
            workoutManager: workoutManager,
            progressManager: progressManager,
            notesManager: notesManager
        )
        
        print("All data reset successfully!")
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(ProgressManager())
        .environmentObject(WorkoutManager())
        .environmentObject(NotesManager())
} 
