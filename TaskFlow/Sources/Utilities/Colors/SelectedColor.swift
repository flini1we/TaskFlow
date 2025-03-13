//
//  CurrentSelectedColor.swift
//  TaskFlow
//
//  Created by Данил Забинский on 06.02.2025.
//

import UIKit

class SelectedColor {
    
    private static let colorMap: [String : UIColor] = [
        "label"        : .label,
        "systemRed"    : .systemRed,
        "systemOrange" : .systemOrange,
        "systemYellow" : .systemYellow,
        "systemGreen"  : .systemGreen,
        "systemBlue"   : .systemBlue,
        "systemPurple" : .systemPurple,
        "systemTeal"   : .systemTeal,
        "systemGray"   : .systemGray,
        "systemPink"   : .systemPink,
        "systemBrown"  : .systemBrown,
        "systemIndigo" : .systemIndigo,
    ]
    
    static var backgroundColor: UIColor = {
        if let colorName = UserDefaults.standard.string(forKey: UserDefaultsKeys.accentColor.getKey) {
            return colorMap[colorName] ?? .label
        }
        return .label
    }() {
        didSet {
            notifyColorChanges()
        }
    }
    
    static func changeColor(_ newColor: UIColor) {
        SelectedColor.backgroundColor = newColor
        UserDefaults.standard.set(UserDefaultsKeys.colorKey(newColor).getKey, forKey: UserDefaultsKeys.accentColor.getKey)
    }
    
    private static func notifyColorChanges() {
        let notificationName = Notification.Name(NotificationName.updateAccentColorNotification.getName)
        NotificationCenter.default.post(name: notificationName,
                                        object: nil,
                                        userInfo: ["updatedColor" : backgroundColor])
    }
    
    static func getAvailableColors() -> [UIColor] {
        [
            .label,
            .systemRed,
            .systemOrange,
            .systemYellow,
            .systemGreen,
            .systemBlue,
            .systemPurple,
            .systemTeal,
            .systemGray,
            .systemPink,
            .systemBrown,
            .systemIndigo,
        ]
    }
}
