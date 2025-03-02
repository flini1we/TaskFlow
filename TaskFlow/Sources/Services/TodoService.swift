//
//  TodoService.swift
//  TaskFlow
//
//  Created by Данил Забинский on 01.03.2025.
//

import Foundation

class TodoService {
    
    private var soonerTodos: [Todo] = Todo.getTodos().filter { $0.section == .sooner && $0.finishedAt == nil } {
        didSet {
            print(soonerTodos)
        }
    }
    private var laterTodos: [Todo] = Todo.getTodos().filter { $0.section == .later && $0.finishedAt == nil } {
        didSet {
            print(laterTodos)
        }
    }
    private var finishedTodos: [Todo] = Todo.getTodos().filter { $0.finishedAt != nil } {
        didSet {
            print(finishedTodos)
        }
    }
}

extension TodoService {
    
    func getTodos(type: TodoTypes) -> [Todo] {
        
        switch type {
        case .sooner:
            return soonerTodos
        case .later:
            return laterTodos
        case .finished:
            return finishedTodos
        }
    }
    
    func saveUpdatedData(sooner: [Todo], later: [Todo], finished: [Todo]) {
        
        self.soonerTodos = sooner
        self.laterTodos = later
        self.finishedTodos = finished
    }
}
