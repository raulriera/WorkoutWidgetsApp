//
//  HealthKitPermissionTask.swift
//  WorkoutWidgets
//
//  Created by Raul Riera on 2025-10-30.
//

import SwiftUI
import HealthKit
import HealthKitUI

struct HealthKitPermissionTask: View {
    @State private var trigger: Bool = false
    @AppStorage("authenticated") private var authenticated: Bool = false
    let store = HKHealthStore()
    
    var body: some View {
        TaskView { complete in
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 42))
                    .foregroundStyle(.red)
                    .symbolRenderingMode(.multicolor)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Health Access")
                        .font(.title.bold())
                    Text("We use your workouts to display the latest one in your widget.You stay in control and can change this anytime in the Health app.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Button {
                    trigger = true
                } label: {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.red)
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.thinMaterial)
            }
            .healthDataAccessRequest(store: store, readTypes: [.workoutType()], trigger: trigger) { result in
                switch result {
                    case .success(_):
                        authenticated = true
                    case .failure(let error):
                        fatalError("*** An error occurred while requesting authentication: \(error) ***")
                }
                
                complete()
            }
            .task {
                if authenticated { complete() }
            }
        }
        .padding()
    }
}

#Preview {
    HealthKitPermissionTask()
}
