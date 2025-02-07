//
//  TableItemSizw.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

enum TableItemSize {
    
    case `default`,
         fullScreen,
         none
    
    var value: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaInsets = UIInsets.topInset + UIInsets.bottomInset
        let headerHeight = HeaderSize.default.value
        
        switch self {
        case .default:
            return (screenHeight - safeAreaInsets) / 2 - headerHeight - (ElementsSize.toolBar.value / 2) / 2
        case .fullScreen:
            return screenHeight - 2 * headerHeight - safeAreaInsets - (ElementsSize.toolBar.value / 2)
        case .none:
            return 0
        }
    }
}

/*
enum TableItemSize {
    
    case `default`,
         fullScreen,
         none
    
    var value: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaInsets = UIInsets.topInset + UIInsets.bottomInset
        let headerHeight = HeaderSize.default.value
        
        switch self {
        case .default:
            return (screenHeight - safeAreaInsets) / 2 - headerHeight
        case .fullScreen:
            return screenHeight - 2 * headerHeight - safeAreaInsets
        case .none:
            return 0
        }
    }
}
*/
