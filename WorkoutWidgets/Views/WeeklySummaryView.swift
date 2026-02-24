//
//  WeeklySummaryView.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2026-02-24.
//

import SwiftUI

struct WeeklySummaryView: View {
    @State private var service = WorkoutService()
    @State private var allWorkouts: [Workout] = []

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("This Week")
                    .font(.title3.bold())
                Spacer()
                if streak > 0 {
                    Label("\(streak)-day streak", systemImage: "flame.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                }
            }

            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        let hasWorkout = hasWorkouts(on: day)
                        let isToday = calendar.isDateInToday(day)
                        let isFuture = day > calendar.startOfDay(for: .now)
                        VStack(spacing: 8) {
                            Text(day, format: .dateTime.weekday(.narrow))
                                .font(.caption.bold())
                                .foregroundStyle(isToday ? .primary : .secondary)
                            ZStack {
                                Circle()
                                    .fill(hasWorkout ? Color.accentColor : Color.secondary.opacity(isFuture ? 0.1 : 0.2))
                                    .frame(width: 36, height: 36)
                                if hasWorkout {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundStyle(.background)
                                }
                                if isToday {
                                    Circle()
                                        .strokeBorder(.accent, lineWidth: 2)
                                        .frame(width: 36, height: 36)
                                }
                            }
                            Text(day, format: .dateTime.day())
                                .font(.caption2)
                                .foregroundStyle(isToday ? .primary : .tertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                if totalWorkoutsThisWeek > 0 {
                    HStack {
                        Text("\(totalWorkoutsThisWeek) workout\(totalWorkoutsThisWeek == 1 ? "" : "s") this week")
                        Spacer()
                        Text(Duration.seconds(totalDurationThisWeek), format: .time(pattern: .hourMinuteSecond))
                            .monospacedDigit()
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .task {
            allWorkouts = await service.fetchWeeklyWorkouts()
        }
    }

    private func hasWorkouts(on day: Date) -> Bool {
        allWorkouts.contains { calendar.isDate($0.startedAt, inSameDayAs: day) }
    }

    private func workouts(on day: Date) -> [Workout] {
        allWorkouts.filter { calendar.isDate($0.startedAt, inSameDayAs: day) }
    }

    private var days: [Date] {
        let today = calendar.startOfDay(for: .now)
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

    private var streak: Int {
        var count = 0
        var day = calendar.startOfDay(for: .now)

        while hasWorkouts(on: day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }

        return count
    }

    private var totalWorkoutsThisWeek: Int {
        days.reduce(0) { $0 + workouts(on: $1).count }
    }

    private var totalDurationThisWeek: TimeInterval {
        days.reduce(0) { total, day in
            total + workouts(on: day).reduce(0) { $0 + $1.duration }
        }
    }
}
