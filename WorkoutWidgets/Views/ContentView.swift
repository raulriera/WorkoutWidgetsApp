//
//  ContentView.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-10-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            AppView()
        }
        .overlay {
            TaskContainer {
                HealthKitPermissionTask()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview { ContentView() }
