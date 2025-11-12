//
//  StartView.swift
//  ZenGymKit
//
//  Created by Роман Главацкий on 10.11.2025.
//

import SwiftUI

struct StartView: View {
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var progressManager = ProgressManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var notesManager = NotesManager()
    var body: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .environmentObject(workoutManager)
            .environmentObject(progressManager)
            .environmentObject(settingsManager)
            .environmentObject(notesManager)
            
    }
}

#Preview {
    StartView()
}
