//
//  TodoCellSize.swift
//  TaskFlow
//
//  Created by Данил Забинский on 09.02.2025.
//

import UIKit

enum TodoCellSize {
    
    case `default`
    
    var value: CGFloat {
        switch self {
        case .default:
            return 49
        }
    }
}
