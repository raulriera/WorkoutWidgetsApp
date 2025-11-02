//
//  TaskContainer.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-11-01.
//

import SwiftUI

extension ContainerValues {
    @Entry var taskCompleted: Bool = false
}

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
//                                .transition(.asymmetric(
//                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
//                                    removal: .scale(scale: 0.95).combined(with: .opacity)
//                                ))
                        }
                    }
                }
            }
        }
    }
}

struct TaskView<Content: View>: View {
    @State private var completed = false
    let content: (_ complete: @escaping () -> Void) -> Content

    init(@ViewBuilder content: @escaping (_ complete: @escaping () -> Void) -> Content) {
        self.content = content
    }

    var body: some View {
        content {
            //withAnimation(.easeInOut) {
                completed = true
            //}
        }
            .containerValue(\.taskCompleted, completed)
    }
}
