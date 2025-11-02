//
//  WorkoutMotivationPrompt.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-11-02.
//

struct WorkoutMotivationPrompt {
    let title: String
    let subtitle: String
}

func randomWorkoutPrompt() -> WorkoutMotivationPrompt {
    let prompts: [WorkoutMotivationPrompt] = [
        .init(title: "Not yet?", subtitle: "Make today count."),
        .init(title: "One set away", subtitle: "From momentum."),
        .init(title: "Still quiet", subtitle: "Break the sweat."),
        .init(title: "Discipline calls", subtitle: "Answer it."),
        .init(title: "No excuses", subtitle: "Just start.")
    ]
    
    return prompts.randomElement()!
}

func randomCompletedPrompt() -> String {
    let titles = [
        "Done & dusted",
        "You showed up",
        "Strong move",
        "Workout locked",
        "Momentum built"
    ]
    
    return titles.randomElement()!
}
