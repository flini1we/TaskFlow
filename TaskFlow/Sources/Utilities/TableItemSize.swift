//
//  TableItemSizw.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

enum HeaderSize {
    
    case `default`
    
    var value: CGFloat {
        switch self {
        case .default:
            return 20
        }
    }
}

enum TableItemSize {
    
    case `default`,
         fullScreen,
         none
    
    var value: CGFloat {
        switch self {
        case .default:
            return UIScreen.main.bounds.height / 2 - HeaderSize.default.value * 2
        case .fullScreen:
            return UIScreen.main.bounds.height - 2 * HeaderSize.default.value * 2
        case .none:
            return 0
        }
    }
         
}
