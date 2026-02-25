//
//  ContentView.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-10-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Activity", systemImage: "figure.run") {
                NavigationStack {
                    AppView()
                }
            }
            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .overlay {
            TaskContainer {
                HealthKitPermissionTask()
            }
        }
    }
}

#Preview { ContentView() }
