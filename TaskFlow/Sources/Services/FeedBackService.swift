//
//  FeedBackService.swift
//  TaskFlow
//
//  Created by Данил Забинский on 02.03.2025.
//

import UIKit

class FeedBackService {
    
    static func occurreVibration(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
