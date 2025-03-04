//
//  CoreDataManager.swift
//  TaskFlow
//
//  Created by Данил Забинский on 23.02.2025.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private lazy var viewContext: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    private lazy var backgroundContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskFlow")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() { }
    
    func obtainActiveTodosInSelectedSection(in section: MainTableSections) -> Result<[Todo], CoreDataErrors> {
        let todosInSectionFetchRequest = TodoEntity.fetchRequest()
        todosInSectionFetchRequest.predicate = NSPredicate(format: "section == %@ AND finishedAt == nil", section.rawValue)
        
        do {
            let todoEntities = try viewContext.fetch(todosInSectionFetchRequest)
            let todos = todoEntities.compactMap { castTodoEntityIntoTodo(entity: $0) }
            print("\(section.rawValue)")
            todos.forEach { print($0.title) }
            print("---")
            return .success(todos)
        } catch {
            print(CoreDataErrors.failedToObtainActiveTodosFromSection(section).errorDescription)
        }
        return .failure(CoreDataErrors.failedToObtainActiveTodosFromSection(section))
    }
    
    func obtainFinishedTodos() -> Result<[Todo], CoreDataErrors> {
        let finishedTodosFetchRequest = TodoEntity.fetchRequest()
        finishedTodosFetchRequest.predicate = NSPredicate(format: "finishedAt != nil")
        
        do {
            let todoEntities = try viewContext.fetch(finishedTodosFetchRequest)
            let todos = todoEntities.compactMap { castTodoEntityIntoTodo(entity: $0) }
            print("Finished")
            todos.forEach { print($0.title) }
            print("---")
            return .success(todos)
        } catch {
            print(CoreDataErrors.failedToObtainFinishedTodos.errorDescription)
        }
        return .failure(CoreDataErrors.failedToObtainFinishedTodos)
    }
    
    func replaceTodosInSection(todos: [Todo], at section: TodoTypes) {
        let bgContext = backgroundContext
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        bgContext.perform { [weak viewContext] in
            
            let deleteTodosFetchRequest = TodoEntity.fetchRequest()
            deleteTodosFetchRequest.predicate = NSPredicate(format: "section == %@ AND finishedAt == nil", section.rawValue)
            
            do {
                let soonerTodoEntities = try bgContext.fetch(deleteTodosFetchRequest)
                soonerTodoEntities.forEach { bgContext.delete($0) }
                
                do {
                    try bgContext.save()
                    
                    viewContext?.performAndWait {
                        do {
                            try viewContext?.save()
                            dispatchGroup.leave()
                        } catch {
                            print("Error of deleting soonerTodos from viewContext: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                } catch {
                    print("Error of deleting soonerTodos from bgContext: \(error.localizedDescription)")
                    dispatchGroup.leave()
                }
            } catch {
                print("Error during fetch soonerTodos from data: \(error.localizedDescription)")
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                self.saveTodos(todos: todos)
            }
        }
    }
    
    private func saveTodos(todos: [Todo]) {
        
        let bgContext = backgroundContext
        bgContext.perform { [weak viewContext] in
            
            for todo in todos {
                let todoEntity = TodoEntity(context: bgContext)
                todoEntity.id = todo.id
                todoEntity.title = todo.title
                todoEntity.createdAt = todo.createdAt
                todoEntity.section = todo.section.rawValue
                todoEntity.finishedAt = nil
            }
            
            do {
                try bgContext.save()
                
                viewContext?.performAndWait {
                    do {
                        try viewContext?.save()
                    } catch {
                        print("Error during saving in viewContext: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("Error during saving in backgroundContext: \(error.localizedDescription)")
            }
        }
    }
    
    func saveFinishedTodo(todo: Todo) -> Result<Bool, CoreDataErrors> {
        guard todo.finishedAt != nil else { return .failure(.failedToObtainFinishedTodosDueToTodoFinishedAtFieldIsNil(todo))
        }
        let bgContext = backgroundContext
        
        bgContext.perform { [weak viewContext] in
            let finishedTodoEntity = TodoEntity(context: bgContext)
            finishedTodoEntity.id = todo.id
            finishedTodoEntity.title = todo.title
            finishedTodoEntity.createdAt = todo.createdAt
            finishedTodoEntity.finishedAt = todo.finishedAt
            finishedTodoEntity.section = todo.section.rawValue
            
            do {
                try bgContext.save()
                viewContext?.performAndWait {
                    do {
                        try viewContext?.save()
                    } catch {
                        print(CoreDataErrors.failedToSaveDataInContext(.viewContext).errorDescription)
                    }
                }
            } catch {
                print(CoreDataErrors.failedToSaveDataInContext(.someBackgroundContext).errorDescription)
            }
        }
        return .failure(CoreDataErrors.failedToObtainFinishedTodos)
    }
    
    func removeFinishedTodo() {
        // TODO: remove finished todo from storage and append it into previous section
    }
}

private extension CoreDataManager {
    
    func castTodoEntityIntoTodo(entity todoEntity: TodoEntity) -> Todo {
        Todo(id: todoEntity.id,
             title: todoEntity.title,
             section: MainTableSections(rawValue: todoEntity.section) ?? .sooner,
             createdAt: todoEntity.createdAt,
             finishedAt: todoEntity.finishedAt)
    }
}
