//
//  PromptStyle.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2026-02-24.
//

import Foundation

enum PromptStyle: String, CaseIterable, Identifiable {
    case motivational
    case minimal
    case playful

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .motivational: "Motivational"
        case .minimal: "Minimal"
        case .playful: "Playful"
        }
    }

    var description: String {
        switch self {
        case .motivational: "Fired-up phrases to push you harder"
        case .minimal: "Short, clean, no fluff"
        case .playful: "Light-hearted and fun"
        }
    }

    var sampleTitle: String {
        switch self {
        case .motivational: "No excuses"
        case .minimal: "Not yet"
        case .playful: "Couch mode"
        }
    }

    var sampleSubtitle: String {
        switch self {
        case .motivational: "Just start."
        case .minimal: "Go move."
        case .playful: "Activate legs!"
        }
    }

    var sampleCompletedTitle: String {
        switch self {
        case .motivational: "Strong move"
        case .minimal: "Done"
        case .playful: "Nailed it!"
        }
    }
}

enum WidgetSettingsKeys {
    static let suiteName = "group.com.raulriera.WorkoutWidgets"
    static let promptStyle = "promptStyle"
}
