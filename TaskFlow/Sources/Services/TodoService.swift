//
//  TodoService.swift
//  TaskFlow
//
//  Created by Данил Забинский on 01.03.2025.
//

import Foundation

class TodoService {
    
    private var coreDataManager: CoreDataManager
    
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
    
    private var soonerTodos: [Todo] {
        didSet {
            print("Saved to coreData: Sooner")
            soonerTodos.forEach { print($0.title) }
        }
    }
    private var laterTodos: [Todo] {
        didSet {
            print("Saved to coreData: Later")
            laterTodos.forEach { print($0.title) }
        }
    }
    private var finishedTodos: [Todo] {
        didSet {
            // save to core data instantly
            print("Saved to coreData: Finished")
            finishedTodos.forEach {
                print($0.title)
            }
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
    
    func saveFinishedTodo(finishedTodo: Todo) {
        guard finishedTodo.finishedAt != nil else { return }
        // TODO: save to core data
    }
}
