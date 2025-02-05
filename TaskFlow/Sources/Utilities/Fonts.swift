//
//  Fonts.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import Foundation

enum Fonts: CGFloat {
    
    case tiny,
         small,
         `default`,
         title,
         big
    
    var value: CGFloat {
        switch self {
        case .tiny:
            return 10
        case .small:
            return 14
        case .default:
            return 16
        case .title:
            return 20
        case .big:
            return 22
        }
    }
}
