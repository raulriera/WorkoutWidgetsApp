//
//  WorkoutMotivationPrompt.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-11-02.
//

import FoundationModels

@Generable()
struct WorkoutMotivationPrompt {
    @Guide(description: "A short motivational title, not more than 2 words")
    let title: String
    @Guide(description: "A complementary subtitle for the previous title. No more than 3 words")
    let subtitle: String
}

func randomWorkoutPrompt(style: PromptStyle = .motivational) -> WorkoutMotivationPrompt {
    let prompts: [WorkoutMotivationPrompt] = switch style {
    case .motivational:
        [
            .init(title: "Not yet?", subtitle: "Make today count."),
            .init(title: "One set away", subtitle: "From momentum."),
            .init(title: "Still quiet", subtitle: "Break the sweat."),
            .init(title: "Discipline calls", subtitle: "Answer it."),
            .init(title: "No excuses", subtitle: "Just start.")
        ]
    case .minimal:
        [
            .init(title: "Not yet", subtitle: "Go move."),
            .init(title: "Waiting", subtitle: "On you."),
            .init(title: "Zero reps", subtitle: "Change that."),
            .init(title: "Rest day?", subtitle: "Your call."),
            .init(title: "Idle", subtitle: "Move soon.")
        ]
    case .playful:
        [
            .init(title: "Couch mode", subtitle: "Activate legs!"),
            .init(title: "Muscles miss", subtitle: "You already."),
            .init(title: "Plot twist:", subtitle: "You work out."),
            .init(title: "Gym misses", subtitle: "Its favorite."),
            .init(title: "Snack first?", subtitle: "Then sweat!")
        ]
    }

    return prompts.randomElement()!
}

func randomCompletedPrompt(style: PromptStyle = .motivational) -> String {
    let titles: [String] = switch style {
    case .motivational:
        [
            "Done & dusted",
            "You showed up",
            "Strong move",
            "Workout locked",
            "Momentum built"
        ]
    case .minimal:
        [
            "Done",
            "Checked off",
            "Complete",
            "Logged",
            "Finished"
        ]
    case .playful:
        [
            "Nailed it!",
            "Sweat unlocked",
            "Beast mode!",
            "Crushed it!",
            "Level up!"
        ]
    }

    return titles.randomElement()!
}
