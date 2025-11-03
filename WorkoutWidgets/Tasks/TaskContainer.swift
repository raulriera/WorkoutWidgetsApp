//
//  TaskContainer.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-11-01.
//

import SwiftUI

/// A container value indicating whether a task-like subview is completed.
///
/// Views can opt-in to this convention by writing a boolean with
/// `.containerValue(\\.taskCompleted, true/false)`. Parent views can then
/// query the value from subviews to drive presentation logic.
extension ContainerValues {
    @Entry var taskCompleted: Bool = false
}

/// A container that displays only the first subview that has not been marked
/// as completed via the `\\.taskCompleted` container value.
///
/// This is a teaching example that shows how to:
/// - Walk the view hierarchy using `Group(sections:)` and `Group(subviews:)`
/// - Read per-subview container values to make layout decisions
///
/// Usage:
/// ```swift
/// TaskContainer {
///     TaskView { complete in
///         Button("Do step 1") { complete() }
///     }
///     TaskView { complete in
///         // Some Non UI View performing a .task
///     }
/// }
/// ```
/// Only the first `TaskView` whose `taskCompleted` value is `false` will be shown.
struct TaskContainer<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Group(sections: content) { sections in
                ForEach(sections) { section in
                    Group(subviews: section.content) { subviews in
                        if let firstIncomplete = subviews.first(where: { !$0.containerValues.taskCompleted }) {
                            firstIncomplete
                                .id(firstIncomplete.id)
                                // Optional: Add transitions if you want animated insert/remove effects.
                        }
                    }
                }
            }
        }
    }
}

/// A helper view that exposes a `complete()` callback to its content and
/// writes the `\\.taskCompleted` container value when invoked.
///
/// Call `complete()` to mark this task as finished. Parent containers like
/// `TaskContainer` can then detect completion and advance to the next task.
struct TaskView<Content: View>: View {
    @State private var completed = false
    let content: (_ complete: @escaping () -> Void) -> Content

    init(@ViewBuilder content: @escaping (_ complete: @escaping () -> Void) -> Content) {
        self.content = content
    }

    var body: some View {
        content {
            // You could animate this state change; left disabled to reduce noise in widgets.
            // withAnimation(.easeInOut) {
            completed = true
            // }
        }
            .containerValue(\.taskCompleted, completed)
    }
}

