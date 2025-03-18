//
//  ChartDataPoint.swift
//  TaskFlow
//
//  Created by Данил Забинский on 17.03.2025.
//

import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
