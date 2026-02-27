//
//  WidgetsCollection.swift
//  WidgetsCollection
//
//  Created by Raul Riera on 2025-10-31.
//

import WidgetKit
import SwiftUI
import HealthKit

struct Provider: AppIntentTimelineProvider {
    let service = WorkoutService()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), workouts: [], didWorkoutToday: false)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        if context.isPreview {
            // Gallery / preview experience
            return SimpleEntry(date: .now,
                               configuration: configuration,
                               workouts: [],
                               didWorkoutToday: false)
        }

        let didWorkout = await service.didWorkoutToday()
        return SimpleEntry(date: .now,
                           configuration: configuration,
                           workouts: service.workouts,
                           didWorkoutToday: didWorkout)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let didWorkout = await service.didWorkoutToday()

        // Floor current time to the previous 5-minute boundary (e.g., 1:07 -> 1:05)
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        if let minute = components.minute {
            components.minute = (minute / 5) * 5
        }
        components.second = 0
        components.nanosecond = 0
        let currentDate = calendar.date(from: components) ?? now

        // Create the entry, and regenerate the timeline every 5 minutes
        let entry = SimpleEntry(date: currentDate,
                                configuration: configuration,
                                workouts: service.workouts,
                                didWorkoutToday: didWorkout)
        entries.append(entry)

        let fiveMinutesFromNow = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        return Timeline(entries: entries, policy: .after(fiveMinutesFromNow))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent

    let workouts: [Workout]
    let didWorkoutToday: Bool

    var totalDuration: TimeInterval {
        workouts.reduce(0) { $0 + $1.duration }
    }
}

// MARK: - System Small View

struct SmallWidgetView: View {
    var entry: SimpleEntry

    private var promptStyle: PromptStyle {
        guard let raw = UserDefaults(suiteName: WidgetSettingsKeys.suiteName)?.string(forKey: WidgetSettingsKeys.promptStyle),
              let style = PromptStyle(rawValue: raw) else {
            return .motivational
        }
        return style
    }

    var body: some View {
        let prompt = randomWorkoutPrompt(style: promptStyle)

        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: entry.didWorkoutToday ? (entry.workouts.first?.type.iconSystemName ?? "figure.run") : "figure.fall")
                .font(.system(size: 52))
                .foregroundStyle(.accent)
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                if entry.didWorkoutToday {
                    Text(randomCompletedPrompt(style: promptStyle))
                        .font(.body.bold())
                    HStack(spacing: 4) {
                        Text(Duration.seconds(entry.totalDuration), format: .time(pattern: .hourMinuteSecond))
                        if entry.workouts.count > 1 {
                            Text("(\(entry.workouts.count))")
                        }
                    }
                    .font(.footnote.bold())
                    .foregroundStyle(.accent)
                } else {
                    Text(prompt.title)
                        .font(.body.bold())
                    Text(prompt.subtitle)
                        .font(.footnote.bold())
                        .foregroundStyle(.accent)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .foregroundStyle(.white)
    }
}

// MARK: - Lock Screen Circular View

struct CircularWidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: entry.didWorkoutToday
                  ? (entry.workouts.first?.type.iconSystemName ?? "figure.run")
                  : "figure.fall")
                .font(.title2)
                .widgetAccentable()
        }
    }
}

// MARK: - Lock Screen Rectangular View

struct RectangularWidgetView: View {
    var entry: SimpleEntry

    private var promptStyle: PromptStyle {
        guard let raw = UserDefaults(suiteName: WidgetSettingsKeys.suiteName)?.string(forKey: WidgetSettingsKeys.promptStyle),
              let style = PromptStyle(rawValue: raw) else {
            return .motivational
        }
        return style
    }

    var body: some View {
        if entry.didWorkoutToday {
            VStack(alignment: .leading, spacing: 2) {
                Label(randomCompletedPrompt(style: promptStyle), systemImage: entry.workouts.first?.type.iconSystemName ?? "figure.run")
                    .font(.headline)
                    .widgetAccentable()
                Text(Duration.seconds(entry.totalDuration), format: .time(pattern: .hourMinuteSecond))
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            let prompt = randomWorkoutPrompt(style: promptStyle)
            VStack(alignment: .leading, spacing: 2) {
                Label(prompt.title, systemImage: "figure.fall")
                    .font(.headline)
                    .widgetAccentable()
                Text(prompt.subtitle)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Entry View Router

struct WidgetsCollectionEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct WidgetsCollection: Widget {
    let kind: String = "WidgetsCollection"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: Provider()) { entry in
            WidgetsCollectionEntryView(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
        }
                .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular])
                .configurationDisplayName("Today's Workout")
                .description("Quick check: did you work out today?")
                .contentMarginsDisabled()
    }
}

extension ConfigurationAppIntent {
    fileprivate static var `default`: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    WidgetsCollection()
} timeline: {
    let workout = Workout(
        startedAt: .now,
        endedAt: Calendar.current.date(byAdding: .minute, value: 30, to: .now)!,
        type: .running
    )
    let workout2 = Workout(
        startedAt: Calendar.current.date(byAdding: .hour, value: -3, to: .now)!,
        endedAt: Calendar.current.date(byAdding: .hour, value: -2, to: .now)!,
        type: .walking
    )

    SimpleEntry(date: .now, configuration: .default, workouts: [], didWorkoutToday: false)
    SimpleEntry(date: .now, configuration: .default, workouts: [workout], didWorkoutToday: true)
    SimpleEntry(date: .now, configuration: .default, workouts: [workout, workout2], didWorkoutToday: true)
}

#Preview(as: .accessoryCircular) {
    WidgetsCollection()
} timeline: {
    let workout = Workout(
        startedAt: .now,
        endedAt: Calendar.current.date(byAdding: .minute, value: 30, to: .now)!,
        type: .running
    )

    SimpleEntry(date: .now, configuration: .default, workouts: [], didWorkoutToday: false)
    SimpleEntry(date: .now, configuration: .default, workouts: [workout], didWorkoutToday: true)
}

#Preview(as: .accessoryRectangular) {
    WidgetsCollection()
} timeline: {
    let workout = Workout(
        startedAt: .now,
        endedAt: Calendar.current.date(byAdding: .minute, value: 30, to: .now)!,
        type: .running
    )

    SimpleEntry(date: .now, configuration: .default, workouts: [], didWorkoutToday: false)
    SimpleEntry(date: .now, configuration: .default, workouts: [workout], didWorkoutToday: true)
}
