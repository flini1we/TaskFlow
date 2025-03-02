//
//  CurrentSelectedColor.swift
//  TaskFlow
//
//  Created by Данил Забинский on 06.02.2025.
//

import UIKit

protocol ColorUpdatable {
    func updateBackgroundColor()
}

class SelectedColor {
    
    static var backgroundColor: UIColor = .label {
        didSet {
            updateUI()
        }
    }
    
    static func changeColor(_ newColor: UIColor) {
        SelectedColor.backgroundColor = newColor 
    }
    
    private static func updateUI() {
        if let scenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in scenes {
                for window in scene.windows {
                    if let rootViewController = window.rootViewController {
                        for viewController in rootViewController.children {
                            if let updatable = viewController as? ColorUpdatable {
                                updatable.updateBackgroundColor()
                            }
                        }
                    }
                }
            }
        }
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
