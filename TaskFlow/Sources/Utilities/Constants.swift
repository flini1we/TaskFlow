//
//  Constants.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

enum Constants {
    
    case paddingSmall,
         paddingMedium,
         paddingLarge,
         paddingMax
    
    var value: CGFloat {
        switch self {
        case .paddingSmall:
            return 10
        case .paddingMedium:
            return 25
        case .paddingLarge:
            return 50
        case .paddingMax:
            return 100
        }
    }
}
