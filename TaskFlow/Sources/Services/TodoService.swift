//
//  TodoService.swift
//  TaskFlow
//
//  Created by Данил Забинский on 01.03.2025.
//

import Foundation
import CoreData

class TodoService {
    
    private var coreDataManager: CoreDataManager
    
    private var soonerTodos: [Todo] {
        didSet {
            coreDataManager.replaceTodosInSection(todos: soonerTodos, at: .sooner)
        }
    }
    private var laterTodos: [Todo] {
        didSet {
            coreDataManager.replaceTodosInSection(todos: laterTodos, at: .later)
        }
    }
    
    private var finishedTodos: [Todo]
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
        
        let soonerTodosFetchRequestResult = coreDataManager.obtainActiveTodosInSelectedSection(in: .sooner)
        switch soonerTodosFetchRequestResult {
        case .success(let todos):
            self.soonerTodos = todos
        case .failure(let failure):
            print(failure.errorDescription)
            self.soonerTodos = []
        }
        
        let laterTodosFetchRequestResult = coreDataManager.obtainActiveTodosInSelectedSection(in: .later)
        switch laterTodosFetchRequestResult {
        case .success(let todos):
            self.laterTodos = todos
        case .failure(let failure):
            print(failure.errorDescription)
            self.laterTodos = []
        }
        
        let finishedFetchRequestResult = coreDataManager.obtainFinishedTodos()
        switch finishedFetchRequestResult {
        case .success(let todos):
            self.finishedTodos = todos
        case .failure(let failure):
            print(failure.errorDescription)
            self.finishedTodos = []
        }
    }
    
    func getFinishedTodosFetchedResultsController() -> NSFetchedResultsController<TodoEntity> {
        coreDataManager.obtaingFinishedTodosFetchedResultsController()
    }
    
    func restoreFinishedTodoFromStorage(todo: Todo) {
        coreDataManager.removeFinishedTodo(withId: todo.id)
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
    
    func saveUpdatedData(sooner: [Todo], later: [Todo]) {
        
        self.soonerTodos = sooner
        self.laterTodos = later
    }
    
    func saveFinishedTodo(finishedTodo: Todo) {
        guard finishedTodo.finishedAt != nil else { return }
        coreDataManager.saveFinishedTodo(todo: finishedTodo)
    }
}
