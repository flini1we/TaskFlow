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
    let createdAt: Date?
    var finishedAt: Date?
    
    init(id: UUID, title: String, section: MainTableSections, createdAt: Date = .now, finishedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.section = section
        self.createdAt = createdAt
        self.finishedAt = finishedAt
    }
    
    mutating func changeSection() { section = (section == .sooner) ? .later : .sooner }
    mutating func finishTask() { finishedAt = .now }
    
    static func getTodos() -> [Todo] {
        [Todo(id: UUID(), title: "Later", section: .later),
//         Todo(id: UUID(), title: "Sooner", section: .sooner),
         Todo(id: UUID(), title: "q3", section: .later),
         Todo(id: UUID(), title: "JKLDSJFKLSJDFLKSJDLKFJSDLKFJDSLKFJSKLDJFLSDJF", section: .later),]
    }
}
