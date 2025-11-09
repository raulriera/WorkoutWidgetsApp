//
//  WorkoutService.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-10-30.
//

import Foundation
import HealthKit
import Observation

@Observable
final class WorkoutService {
    private let store = HKHealthStore()
    private(set) var lastWorkout: Workout?
    
    private func fetchLatestWorkout() async throws -> Workout? {
        try await withCheckedThrowingContinuation { continuation in
            let workoutType = HKObjectType.workoutType()
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            // Only sort and query from today
            let startOfToday = Calendar.current.startOfDay(for: .now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfToday, end: nil, options: [.strictStartDate])

            let query = HKSampleQuery(sampleType: workoutType,
                                      predicate: predicate,
                                      limit: 1,
                                      sortDescriptors: [sort]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let workout = (samples as? [HKWorkout])?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: Workout(startedAt: workout.startDate,
                                                       endedAt: workout.endDate,
                                                       type: workout.workoutActivityType))
            }

            store.execute(query)
        }
    }
    
    func didWorkoutToday() async -> Bool {
        lastWorkout = try? await fetchLatestWorkout()
        return lastWorkout != nil
    }
}

