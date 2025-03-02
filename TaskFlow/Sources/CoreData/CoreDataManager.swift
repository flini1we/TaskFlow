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
    
//    func obtainActiveTodos() -> [Todo] {
//        let todoFetchRequest = TodoEntity.fetchRequest()
//        todoFetchRequest.predicate = NSPredicate(format: "finishedAt != nil")
//        
//        do {
//            let todoEntity = try viewContext.fetch(todoFetchRequest)
//            let todos = todoEntity.map {
//                Todo(id: $0.id,
//                     title: $0.title,
//                     section: MainTableSections(rawValue: $0.section) ?? .sooner,
//                     createdAt: $0.createdAt,
//                     finishedAt: nil)
//            }
//        } catch {
//            print("Eror of obtaining todos")
//        }
//    }
    
//    func obtainTodos(isTodosActive: Bool) -> [Todo] {
//        let todoFetchRequest = TodoEntity.fetchRequest()
//        
//        if isTodosActive {
//            todoFetchRequest.predicate = NSPredicate(format: "finishedAt != nil")
//        } else {
//            todoFetchRequest.predicate = NSPredicate(format: "finishedAt == nil")
//        }
//        
//        do {
//            let todoEntities = try viewContext.fetch(todoFetchRequest)
//            let todos = todoEntities.map {
//                Todo(id: $0.id,
//                     title: $0.title,
//                     section: MainTableSections(rawValue: $0.section) ?? .sooner,
//                     createdAt: $0.createdAt,
//                     finishedAt: nil)
//            }
//            return todos
//        } catch {
//            print("Error of obtaining todos in view context: \(error.localizedDescription)")
//        }
//        
//        return []
//    }
//    
//    func changeSectionToExistingTodo(todoId id: UUID) {
//        let todoFetchReques = TodoEntity.fetchRequest()
//        todoFetchReques.predicate = NSPredicate(format: "id == %@", id.uuidString)
//    }
//    
//    func saveTodo(_ todo: Todo) {
//        
//    }
//    
//    func updateAndSaveTodos(_ todos: [Todo]) async {
//        let bgContext = backgroundContext
//        await bgContext.perform { [weak viewContext] in
//            
//            let todoEntities: [TodoEntity] = todos.compactMap { [weak self] todo in
//                self?.createAndFillEntity(todo: todo, in: bgContext)
//            }
//            
//            do {
//                try bgContext.save()
//                
//                viewContext?.performAndWait {
//                    do {
//                        try viewContext?.save()
//                    } catch {
//                        print("Error of saving data in view context: \(error.localizedDescription)")
//                    }
//                }
//            } catch {
//                print("Error of saving data in background context: \(error.localizedDescription)")
//            }
//        }
//    }
//    
////    func saveTodo(_ todo: Todo) {
////        
////    }
//    
//    private func castToTodo(_ todoEntities: [TodoEntity]) -> [Todo] {
//        todoEntities.compactMap { todoEntity in
//            Todo(id: todoEntity.id ?? UUID(),
//                 title: todoEntity.title ?? "No title",
//                 section: MainTableSections(rawValue: todoEntity.section ?? "sooner") ?? .sooner,
//                 createdAt: todoEntity.createdAt ?? .now,
//                 finishedAt: todoEntity.finishedAt)
//        }
//    }
//    
//    private func createAndFillEntity(todo: Todo, in context: NSManagedObjectContext) -> TodoEntity {
//        let todoEntity = TodoEntity(context: context)
//        
//        todoEntity.title = todo.title
//        todoEntity.id = todo.id
//        todoEntity.createdAt = todo.createdAt
//        todoEntity.finishedAt = todo.finishedAt
//        
//        return todoEntity
//    }
}
