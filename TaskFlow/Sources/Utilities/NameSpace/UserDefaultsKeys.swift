//
//  UserDefaultsKeys.swift
//  TaskFlow
//
//  Created by Данил Забинский on 13.03.2025.
//

import UIKit

enum UserDefaultsKeys {
    
    case accentColor,
         colorKey(UIColor),
         tableState
    
    var getKey: String {
        switch self {
        case .accentColor:
            return "accentColor"
        case .colorKey(let color):
            let colorString = "\(color.self)"
            let splitedColor = colorString.split(separator: "name = ")
            // dropLast(6) to avoid " ...Color" in UIColor signature
            return String(describing: splitedColor.last!.dropLast(6))
        case .tableState:
            return "tableState"
        }
    }
}
