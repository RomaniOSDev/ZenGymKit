//
//  ContentView.swift
//  ZenGym
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                WorkoutView()
            }
            .tabItem {
                Image(systemName: "dumbbell.fill")
                Text("Workouts")
            }
            
            NavigationStack {
                ProgressTrackingView()
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Progress")
            }
            
            NavigationStack {
                DailyNotesView()
            }
            .tabItem {
                Image(systemName: "note.text")
                Text("Notes")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .accentColor(.appAccent)
        .sheet(isPresented: $workoutManager.isWorkoutActive) {
            NavigationStack {
                ActiveWorkoutView()
                    .environmentObject(workoutManager)
                    .environmentObject(progressManager)
                    .environmentObject(settingsManager)
                    .environmentObject(notesManager)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
        .environmentObject(ProgressManager())
        .environmentObject(SettingsManager())
        .environmentObject(NotesManager())
}
