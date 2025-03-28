//
//  Todo.swift
//  TaskFlow
//
//  Created by Данил Забинский on 05.02.2025.
//

import Foundation

struct Todo: Identifiable, Hashable {
    
    let id: UUID
    var title: String
    var section: MainTableSections = .sooner
    let createdAt: Date
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
    mutating func editTitle(updatedTitle title: String) { self.title = title }
    mutating func restoreTodo() { self.finishedAt = nil }
}

extension Todo {
    static func castToTodos(entities: [TodoEntity]) -> [Todo] {
        entities.map { todo in
            Todo(id: todo.id,
                 title: todo.title,
                 section: MainTableSections(rawValue: todo.section) ?? .sooner,
                 createdAt: todo.createdAt,
                 finishedAt: todo.finishedAt)
        }
    }
}
