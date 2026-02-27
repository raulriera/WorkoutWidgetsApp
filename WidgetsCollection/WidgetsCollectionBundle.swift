//
//  WidgetsCollectionBundle.swift
//  WidgetsCollection
//
//  Created by Raul Riera on 2025-10-31.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsCollectionBundle: WidgetBundle {
    var body: some Widget {
        WidgetsCollection()
        WeeklyStreakWidget()
        LockScreenInlineWidget()
    }
}
