//
//  Todo.swift
//  TaskFlow
//
//  Created by Данил Забинский on 05.02.2025.
//

import Foundation

struct Todo: Identifiable, Hashable {
    
    let id: UUID
    let title: String
    var section: MainTableSections = .sooner
    let createdAt: Date = .now
    var finishedAt: Date?
    
    mutating func changeSection() { section = (section == .sooner) ? .later : .sooner }
    mutating func finishTask() { finishedAt = .now }
}
