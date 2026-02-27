//
//  LockScreenInlineWidget.swift
//  WidgetsCollection
//
//  Created by Claude on 2026-02-27.
//

import WidgetKit
import SwiftUI
import HealthKit

// MARK: - View

struct LockScreenInlineWidgetEntryView: View {
    var entry: WeeklyEntry

    var body: some View {
        if entry.didWorkoutToday {
            let minutes = Int(entry.weeklyWorkouts.filter {
                Calendar.current.isDateInToday($0.startedAt)
            }.reduce(0) { $0 + $1.duration } / 60)
            Label("Done — \(minutes)min", systemImage: "checkmark.circle.fill")
        } else if entry.streak > 0 {
            Label("\(entry.streak)-day streak", systemImage: "flame.fill")
        } else {
            Label("Not yet today", systemImage: "figure.fall")
        }
    }
}

// MARK: - Widget Configuration

struct LockScreenInlineWidget: Widget {
    let kind: String = "LockScreenInlineWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: WeeklyProvider()) { entry in
            LockScreenInlineWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
                .supportedFamilies([.accessoryInline])
                .configurationDisplayName("Workout Streak")
                .description("Your workout streak in one line.")
    }
}

// MARK: - Previews

#Preview(as: .accessoryInline) {
    LockScreenInlineWidget()
} timeline: {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)

    // No workout, no streak
    WeeklyEntry(date: .now, configuration: ConfigurationAppIntent(), weeklyWorkouts: [], didWorkoutToday: false)

    // Has streak but no workout today
    let pastWorkouts = [
        Workout(startedAt: calendar.date(byAdding: .day, value: -1, to: today)!, endedAt: calendar.date(byAdding: .minute, value: 30, to: calendar.date(byAdding: .day, value: -1, to: today)!)!, type: .running),
        Workout(startedAt: calendar.date(byAdding: .day, value: -2, to: today)!, endedAt: calendar.date(byAdding: .minute, value: 45, to: calendar.date(byAdding: .day, value: -2, to: today)!)!, type: .yoga),
    ]
    WeeklyEntry(date: .now, configuration: ConfigurationAppIntent(), weeklyWorkouts: pastWorkouts, didWorkoutToday: false)

    // Worked out today
    let todayWorkout = Workout(startedAt: today, endedAt: calendar.date(byAdding: .minute, value: 25, to: today)!, type: .running)
    WeeklyEntry(date: .now, configuration: ConfigurationAppIntent(), weeklyWorkouts: [todayWorkout], didWorkoutToday: true)
}
