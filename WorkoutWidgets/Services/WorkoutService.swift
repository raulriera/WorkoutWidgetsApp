//
//  WorkoutService.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-10-30.
//

import Foundation
import HealthKit

@Observable
final class WorkoutService {
    private let store = HKHealthStore()
    private(set) var lastWorkout: HKWorkout?
        
    private func fetchLatestWorkout() async throws -> HKWorkout? {
        try await withCheckedThrowingContinuation { continuation in
            let workoutType = HKObjectType.workoutType()
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            // Only sort and query from today
            let now = Date()
            let startOfToday = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfToday, end: now, options: [.strictEndDate])

            let query = HKSampleQuery(sampleType: workoutType,
                                      predicate: predicate,
                                      limit: 1,
                                      sortDescriptors: [sort]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let workout = (samples as? [HKWorkout])?.first
                continuation.resume(returning: workout)
            }

            store.execute(query)
        }
    }
    
    func didWorkoutToday() async -> Bool {
        lastWorkout = try? await fetchLatestWorkout()
        return lastWorkout != nil
    }
}

