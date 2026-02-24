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

struct WidgetsCollectionEntryView : View {
    var entry: Provider.Entry

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

struct WidgetsCollection: Widget {
    let kind: String = "WidgetsCollection"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: Provider()) { entry in
            WidgetsCollectionEntryView(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
        }
                .supportedFamilies([.systemSmall])
                .contentMarginsDisabled()
    }
}

extension ConfigurationAppIntent {
    fileprivate static var `default`: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

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

