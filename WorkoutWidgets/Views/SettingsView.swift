//
//  SettingsView.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2026-02-24.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(WidgetSettingsKeys.promptStyle, store: UserDefaults(suiteName: WidgetSettingsKeys.suiteName))
    private var promptStyle: PromptStyle = .motivational

    var body: some View {
        List {
            Section {
                WidgetPreview(style: promptStyle)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Widget Prompt Style") {
                ForEach(PromptStyle.allCases) { style in
                    Button {
                        withAnimation {
                            promptStyle = style
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(style.displayName)
                                    .font(.body)
                                Text(style.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if promptStyle == style {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                    .tint(.primary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Widget Preview

private struct WidgetPreview: View {
    let style: PromptStyle

    var body: some View {
        HStack(spacing: 16) {
            widgetFace(didWorkout: false)
            widgetFace(didWorkout: true)
        }
        .padding(.vertical, 8)
    }

    private func widgetFace(didWorkout: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: didWorkout ? "figure.run" : "figure.fall")
                .font(.system(size: 52))
                .foregroundStyle(.accent)
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                if didWorkout {
                    Text(style.sampleCompletedTitle)
                        .font(.caption.bold())
                    Text("0:45:00")
                        .font(.caption2.bold())
                        .foregroundStyle(.accent)
                } else {
                    Text(style.sampleTitle)
                        .font(.caption.bold())
                    Text(style.sampleSubtitle)
                        .font(.caption2.bold())
                        .foregroundStyle(.accent)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
        .frame(height: 150)
        .background(Color(white: 0.11), in: RoundedRectangle(cornerRadius: 20))
        .foregroundStyle(.white)
    }
}
