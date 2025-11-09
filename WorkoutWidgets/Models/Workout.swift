//
//  Workout.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-11-09.
//

import HealthKit

struct Workout: Codable {
    let startedAt: Date
    let endedAt: Date
    let type: HKWorkoutActivityType
    
    var duration: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }
}

extension HKWorkoutActivityType: @retroactive Decodable {}
extension HKWorkoutActivityType: @retroactive Encodable {}
