//
//  WeeklyStreakWidget.swift
//  WidgetsCollection
//
//  Created by Claude on 2026-02-27.
//

import WidgetKit
import SwiftUI
import HealthKit

// MARK: - Provider

struct WeeklyProvider: AppIntentTimelineProvider {
    let service = WorkoutService()

    func placeholder(in context: Context) -> WeeklyEntry {
        WeeklyEntry(date: .now, configuration: ConfigurationAppIntent(), weeklyWorkouts: [], didWorkoutToday: false)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WeeklyEntry {
        if context.isPreview {
            return WeeklyEntry(date: .now, configuration: configuration, weeklyWorkouts: [], didWorkoutToday: false)
        }

        let didWorkout = await service.didWorkoutToday()
        let weekly = await service.fetchWeeklyWorkouts()
        return WeeklyEntry(date: .now, configuration: configuration, weeklyWorkouts: weekly, didWorkoutToday: didWorkout)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WeeklyEntry> {
        let didWorkout = await service.didWorkoutToday()
        let weekly = await service.fetchWeeklyWorkouts()

        // Floor current time to the previous 5-minute boundary
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        if let minute = components.minute {
            components.minute = (minute / 5) * 5
        }
        components.second = 0
        components.nanosecond = 0
        let currentDate = calendar.date(from: components) ?? now

        let entry = WeeklyEntry(date: currentDate, configuration: configuration, weeklyWorkouts: weekly, didWorkoutToday: didWorkout)
        let fiveMinutesFromNow = calendar.date(byAdding: .minute, value: 5, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(fiveMinutesFromNow))
    }
}

// MARK: - Entry

struct WeeklyEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let weeklyWorkouts: [Workout]
    let didWorkoutToday: Bool

    private let calendar = Calendar.current

    var days: [Date] {
        let today = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: today)
        let firstWeekday = calendar.firstWeekday
        let daysToSubtract = (weekday - firstWeekday + 7) % 7
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
            return []
        }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    func hasWorkouts(on day: Date) -> Bool {
        weeklyWorkouts.contains { calendar.isDate($0.startedAt, inSameDayAs: day) }
    }

    var streak: Int {
        var count = 0
        var day = calendar.startOfDay(for: date)
        while hasWorkouts(on: day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    var totalWorkoutsThisWeek: Int {
        days.reduce(0) { total, day in
            total + weeklyWorkouts.filter { calendar.isDate($0.startedAt, inSameDayAs: day) }.count
        }
    }

    var totalDurationThisWeek: TimeInterval {
        days.reduce(0) { total, day in
            total + weeklyWorkouts.filter { calendar.isDate($0.startedAt, inSameDayAs: day) }.reduce(0) { $0 + $1.duration }
        }
    }
}

// MARK: - System Medium View

struct WeeklyStreakWidgetEntryView: View {
    var entry: WeeklyEntry

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("This Week")
                    .font(.headline)
                Spacer()
                if entry.streak > 0 {
                    Label("\(entry.streak)", systemImage: "flame.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                }
            }

            HStack(spacing: 0) {
                ForEach(entry.days, id: \.self) { day in
                    let hasWorkout = entry.hasWorkouts(on: day)
                    let isToday = calendar.isDateInToday(day)
                    let isFuture = day > calendar.startOfDay(for: .now)

                    VStack(spacing: 4) {
                        Text(day, format: .dateTime.weekday(.narrow))
                            .font(.caption2.bold())
                            .foregroundStyle(isToday ? .primary : .secondary)
                        ZStack {
                            Circle()
                                .fill(hasWorkout ? Color.accentColor : Color.secondary.opacity(isFuture ? 0.15 : 0.25))
                                .frame(width: 28, height: 28)
                            if hasWorkout {
                                Image(systemName: "checkmark")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.background)
                            }
                            if isToday {
                                Circle()
                                    .strokeBorder(.accent, lineWidth: 2)
                                    .frame(width: 28, height: 28)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if entry.totalWorkoutsThisWeek > 0 {
                HStack {
                    Text("\(entry.totalWorkoutsThisWeek) workout\(entry.totalWorkoutsThisWeek == 1 ? "" : "s")")
                    Spacer()
                    Text(Duration.seconds(entry.totalDurationThisWeek), format: .time(pattern: .hourMinuteSecond))
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .foregroundStyle(.white)
    }
}

// MARK: - Widget Configuration

struct WeeklyStreakWidget: Widget {
    let kind: String = "WeeklyStreakWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: WeeklyProvider()) { entry in
            WeeklyStreakWidgetEntryView(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
        }
                .supportedFamilies([.systemMedium])
                .configurationDisplayName("Weekly Streak")
                .description("Track your workout streak this week.")
                .contentMarginsDisabled()
    }
}

// MARK: - Previews

#Preview(as: .systemMedium) {
    WeeklyStreakWidget()
} timeline: {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)

    // No workouts
    WeeklyEntry(date: .now, configuration: ConfigurationAppIntent(), weeklyWorkouts: [], didWorkoutToday: false)

    // A few workouts across the week
    let monday = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: today) - calendar.firstWeekday + 7) % 7, to: today)!
    let workouts = [
        Workout(startedAt: monday, endedAt: calendar.date(byAdding: .minute, value: 45, to: monday)!, type: .running),
        Workout(startedAt: calendar.date(byAdding: .day, value: 1, to: monday)!, endedAt: calendar.date(byAdding: .minute, value: 30, to: calendar.date(byAdding: .day, value: 1, to: monday)!)!, type: .traditionalStrengthTraining),
        Workout(startedAt: today, endedAt: calendar.date(byAdding: .minute, value: 25, to: today)!, type: .yoga),
    ]
    WeeklyEntry(date: .now, configuration: ConfigurationAppIntent(), weeklyWorkouts: workouts, didWorkoutToday: true)
}
