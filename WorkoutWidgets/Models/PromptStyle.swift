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

}

enum WidgetSettingsKeys {
    static let suiteName = "group.com.raulriera.WorkoutWidgets"
    static let promptStyle = "promptStyle"
}
