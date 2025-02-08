//
//  ElementsSize.swift
//  TaskFlow
//
//  Created by Данил Забинский on 06.02.2025.
//

import UIKit

enum ElementsSize {
    
    case searchBarInToolBar
    
    var value: CGFloat {
        switch self {
        case .searchBarInToolBar:
            return 35
        }
    }
}
