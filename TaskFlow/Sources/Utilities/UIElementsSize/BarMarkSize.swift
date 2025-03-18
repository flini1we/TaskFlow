//
//  BarMark.swift
//  TaskFlow
//
//  Created by Данил Забинский on 17.03.2025.
//

import UIKit

enum BarMarkSize {
    case withTimeRange(TimeRange)
    
    var getVal: CGFloat {
        switch self {
        case .withTimeRange(let timeRange):
            switch timeRange {
            case .day, .week:
                return UIScreen.main.bounds.width / 10
            case .month:
                return UIScreen.main.bounds.width / 40
            }
        }
    }
}
