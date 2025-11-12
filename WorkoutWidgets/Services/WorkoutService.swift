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
    private let cache = CacheService<Workout>(suiteName: "group.com.raulriera.WorkoutWidgets", key: "lastWorkout")
    
    private func loadCachedWorkout() -> Workout? {
        cache.load()
    }

    private func saveCachedWorkout(_ workout: Workout) {
        cache.save(workout)
    }

    private func clearCachedWorkout() {
        cache.clear()
    }

    private func isDateToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

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
        if lastWorkout == nil {
            lastWorkout = loadCachedWorkout()
        }

        if let workout = lastWorkout, isDateToday(workout.startedAt) {
            return true
        }

        lastWorkout = try? await fetchLatestWorkout()
        if let workout = lastWorkout {
            saveCachedWorkout(workout)
            return true
        } else {
            clearCachedWorkout()
            return false
        }
    }
}

