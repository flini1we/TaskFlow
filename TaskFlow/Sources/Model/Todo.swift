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
    
    mutating func changeSection() {
        section = (section == .sooner) ? .later : .sooner
    }
}
