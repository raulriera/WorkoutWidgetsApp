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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Weekly summary at the top
                WeeklySummaryView()

                // Today's section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today")
                        .font(.title3.bold())

                    if service.workouts.isEmpty {
                        emptyState
                    } else {
                        workoutList
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Activity")
        .onChange(of: scenePhase) { oldValue, newValue in
            guard newValue == .active else { return }
            Task {
                _ = await service.didWorkoutToday()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No workouts yet")
                .font(.headline)
            Text("Your workouts from Apple Health\nwill show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var workoutList: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 0) {
                ForEach(Array(service.workouts.enumerated()), id: \.element.id) { index, workout in
                    WorkoutRowView(workout: workout)
                        .padding(.vertical, 12)
                    if index < service.workouts.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack {
                Text("\(service.workouts.count) workout\(service.workouts.count == 1 ? "" : "s")")
                Spacer()
                Text(Duration.seconds(totalDuration), format: .time(pattern: .hourMinuteSecond))
                    .monospacedDigit()
            }
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
        }
    }

    private var totalDuration: TimeInterval {
        service.workouts.reduce(0) { $0 + $1.duration }
    }
}

#Preview {
    NavigationStack {
        AppView()
    }
}
