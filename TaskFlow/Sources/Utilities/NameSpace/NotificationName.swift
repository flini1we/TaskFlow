//
//  NotificationName.swift
//  TaskFlow
//
//  Created by Данил Забинский on 13.03.2025.
//

import Foundation

enum NotificationName {
    
    case updateAccentColorKey,
        updateAccentColorNotification
    
    var getName: String {
        switch self {
        case .updateAccentColorKey:
            return "updatedColor"
        case .updateAccentColorNotification:
            return "SelectedColorDidChange"
        }
    }
}
