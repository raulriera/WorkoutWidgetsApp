//
//  Workout.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-11-09.
//

import HealthKit

struct Workout: Codable, Identifiable {
    let startedAt: Date
    let endedAt: Date
    let type: HKWorkoutActivityType

    var id: Date { startedAt }

    var duration: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }
}

extension HKWorkoutActivityType: @retroactive Decodable {}
extension HKWorkoutActivityType: @retroactive Encodable {}

// MARK: - Display Helpers

extension HKWorkoutActivityType {
    nonisolated var iconSystemName: String {
        switch self {
        case .running: "figure.run"
        case .walking: "figure.walk"
        case .functionalStrengthTraining, .traditionalStrengthTraining: "figure.strengthtraining.traditional"
        case .coreTraining: "figure.flexibility"
        case .cooldown: "figure.cooldown"
        case .flexibility, .yoga: "figure.yoga"
        case .golf: "figure.golf"
        default: "figure.highintensity.intervaltraining"
        }
    }

    nonisolated var displayName: String {
        switch self {
        case .running: "Running"
        case .walking: "Walking"
        case .functionalStrengthTraining, .traditionalStrengthTraining: "Strength Training"
        case .coreTraining: "Core Training"
        case .cooldown: "Cooldown"
        case .flexibility: "Flexibility"
        case .yoga: "Yoga"
        case .golf: "Golf"
        default: "Workout"
        }
    }
}
