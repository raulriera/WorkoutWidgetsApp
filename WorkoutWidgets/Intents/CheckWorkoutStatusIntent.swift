//
//  CheckWorkoutStatusIntent.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2026-02-20.
//

import AppIntents

struct CheckWorkoutStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Did I Work Out Today?"
    static var description = IntentDescription("Checks whether you've completed a workout today")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let (didWorkout, _) = await WorkoutService.fetchToday()
        return .result(value: didWorkout)
    }
}
