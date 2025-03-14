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
    
    private var soonerTodos: [Todo]
    private var laterTodos: [Todo]
    private var finishedTodos: [Todo]
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
        
        let storedData = coreDataManager.obtainTodos()
        soonerTodos = storedData.sooner
        laterTodos = storedData.later
        finishedTodos = storedData.finished
    }
    
    func getFinishedTodosFetchedResultsController() -> NSFetchedResultsController<TodoEntity> {
        coreDataManager.obtaingFinishedTodosFetchedResultsController()
    }
    
    func restoreFinishedTodoFromStorage(todo: Todo, withRestoring: Bool) {
        coreDataManager.removeFinishedTodo(withId: todo.id, withRestoring: withRestoring)
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
        coreDataManager.saveData(sooner: sooner, later: later)
    }
    
    func saveFinishedTodo(finishedTodo: Todo) {
        guard finishedTodo.finishedAt != nil else { return }
        coreDataManager.saveFinishedTodo(todo: finishedTodo)
    }
    
    func updateTitle(todo: Todo, updateTitle: String) {
        coreDataManager.resaveEditedTodo(todo, updatedTitle: updateTitle)
    }
}
