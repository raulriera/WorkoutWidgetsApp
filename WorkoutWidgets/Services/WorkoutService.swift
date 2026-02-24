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
    private(set) var workouts: [Workout] = []
    private let cache = CacheService<[Workout]>(suiteName: "group.com.raulriera.WorkoutWidgets", key: "workouts")

    private func loadCachedWorkouts() -> [Workout]? {
        cache.load()
    }

    private func saveCachedWorkouts(_ workouts: [Workout]) {
        cache.save(workouts)
    }

    private func clearCachedWorkouts() {
        cache.clear()
    }

    private func isDateToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func fetchWorkouts(from start: Date, to end: Date) async throws -> [Workout] {
        try await withCheckedThrowingContinuation { continuation in
            let workoutType = HKObjectType.workoutType()
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [.strictStartDate])

            let query = HKSampleQuery(sampleType: workoutType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sort]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let hkWorkouts = samples as? [HKWorkout], !hkWorkouts.isEmpty else {
                    continuation.resume(returning: [])
                    return
                }

                let workouts = hkWorkouts.map { workout in
                    Workout(startedAt: workout.startDate,
                            endedAt: workout.endDate,
                            type: workout.workoutActivityType)
                }
                continuation.resume(returning: workouts)
            }

            store.execute(query)
        }
    }

    private func fetchTodaysWorkouts() async throws -> [Workout] {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        return try await fetchWorkouts(from: startOfToday, to: .now)
    }

    func didWorkoutToday() async -> Bool {
        // Always try to fetch fresh data from HealthKit
        if let fetched = try? await fetchTodaysWorkouts() {
            workouts = fetched
            if !fetched.isEmpty {
                saveCachedWorkouts(fetched)
                return true
            } else {
                clearCachedWorkouts()
                return false
            }
        }

        // Fall back to cache when HealthKit is unavailable (e.g. device locked)
        if let cached = loadCachedWorkouts(), !cached.isEmpty, isDateToday(cached[0].startedAt) {
            workouts = cached
            return true
        }

        return false
    }

    /// Convenience for one-shot callers (intents, entity queries) that just need today's data.
    static func fetchToday() async -> (didWorkout: Bool, workouts: [Workout]) {
        let service = WorkoutService()
        let didWorkout = await service.didWorkoutToday()
        return (didWorkout, service.workouts)
    }

    /// Returns all workouts from the past 7 days.
    func fetchWeeklyWorkouts() async -> [Workout] {
        let calendar = Calendar.current
        let endOfToday = Date.now
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: endOfToday)) else {
            return []
        }

        return (try? await fetchWorkouts(from: sevenDaysAgo, to: endOfToday)) ?? []
    }
}
