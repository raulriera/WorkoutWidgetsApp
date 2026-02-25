//
//  WorkoutRowView.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2026-02-24.
//

import SwiftUI
import HealthKit

struct WorkoutRowView: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.type.iconSystemName)
                .font(.title2)
                .foregroundStyle(.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.type.displayName)
                    .font(.body.bold())
                Text(workout.startedAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(Duration.seconds(workout.duration), format: .time(pattern: .hourMinuteSecond))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}
