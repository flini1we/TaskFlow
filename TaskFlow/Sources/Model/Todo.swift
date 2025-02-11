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
    
    mutating func changeToLaterSection() {
        self.section = .later
    }
    
    mutating func backToSoonerSection() {
        self.section = .sooner
    }
}
