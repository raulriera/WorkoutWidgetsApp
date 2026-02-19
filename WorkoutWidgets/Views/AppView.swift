//
//  AppView.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-10-30.
//

import SwiftUI
import HealthKit
import WidgetKit

struct AppView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var service = WorkoutService()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Worked out today?")
                .font(.system(size: 56, weight: .bold))
            Text(!service.workouts.isEmpty ? "Yes" : "No")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.accent)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            guard newValue == .active else { return }
            Task {
                _ = await service.didWorkoutToday()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

#Preview {
    AppView()
}
