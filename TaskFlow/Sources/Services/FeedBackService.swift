//
//  FeedBackService.swift
//  TaskFlow
//
//  Created by Данил Забинский on 02.03.2025.
//

import UIKit

enum VibrationTypes {
    case light, medium, heavy
}

class FeedBackService {
    
    static func occurreVibration(type: VibrationTypes) {
        
        switch type {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
