//
//  AppIntent.swift
//  WidgetsCollection
//
//  Created by Raul Riera on 2025-10-31.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Last workout" }
    static var description: IntentDescription { "Display the latest workout from today." }
}
