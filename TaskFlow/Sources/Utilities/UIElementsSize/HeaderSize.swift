//
//  HeaderSize.swift
//  TaskFlow
//
//  Created by Данил Забинский on 05.02.2025.
//

import Foundation

enum HeaderSize {
    
    case `default`
    
    var value: CGFloat {
        switch self {
        case .default:
            return 44
        }
    }
}
