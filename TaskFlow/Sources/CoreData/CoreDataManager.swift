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
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
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
    
    func obtainTodos() -> (sooner: [Todo], later: [Todo], finished: [Todo]) {
        let fetchRequest = TodoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            let todoEntities = try viewContext.fetch(fetchRequest)
            var todosToople: ([Todo], [Todo], [Todo]) = (sooner: [], later: [], finished: [])
            
            todoEntities.forEach {
                let todo = castTodoEntityIntoTodo(entity: $0)
                if todo.finishedAt != nil {
                    todosToople.2.append(todo)
                } else if todo.section == .sooner {
                    todosToople.0.append(todo)
                } else {
                    todosToople.1.append(todo)
                }
            }
            return todosToople
        } catch {
            print("Error of obtaining data from storage: \(error.localizedDescription)")
        }
        return ([], [], [])
    }
    
    func saveData(sooner: [Todo], later: [Todo]) {
        let fetchRequest = TodoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "finishedAt == nil")
        
        do {
            let todoEntities = try viewContext.fetch(fetchRequest)
            let todoDictionary = Dictionary(uniqueKeysWithValues: todoEntities.map { ($0.id, $0) })
            
            for soonerTodo in sooner {
                if let soonerTodoEntity = todoDictionary[soonerTodo.id] {
                    
                    if soonerTodoEntity.section != "sooner" {
                        soonerTodoEntity.section = "sooner"
                    }
                    
                    if soonerTodoEntity.title != soonerTodo.title {
                        soonerTodoEntity.title = soonerTodo.title
                    }
                } else {
                    self.castTodoToTodoEntity(in: viewContext, with: soonerTodo)
                }
            }
            
            for laterTodo in later {
                if let laterTodoEntity = todoDictionary[laterTodo.id] {
                    
                    if laterTodoEntity.section != "later" {
                        laterTodoEntity.section = "later"
                    }
                    
                    if laterTodoEntity.title != laterTodo.title {
                        laterTodoEntity.title = laterTodo.title
                    }
                } else {
                    self.castTodoToTodoEntity(in: viewContext, with: laterTodo)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print(CoreDataErrors.failedToSaveDataInContext(.viewContext).errorDescription)
            }
        } catch {
            print(CoreDataErrors.failedToSaveDataInContext(.viewContext).errorDescription)
        }
    }
    
    func saveFinishedTodo(todo: Todo) {
        guard todo.finishedAt != nil else { return }
        let bgContext = backgroundContext
        var shouldCreate = true
        // if already exists
        let fetchRquest = TodoEntity.fetchRequest()
        fetchRquest.predicate = NSPredicate(format: "finishedAt == nil AND id == %@", todo.id.uuidString)
        do {
            if let activeTodo = try bgContext.fetch(fetchRquest).first {
                activeTodo.finishedAt = Date()
                do {
                    shouldCreate = false
                    try bgContext.save()
                } catch {
                    print(CoreDataErrors.failedToSaveDataInContext(.viewContext).errorDescription)
                }
            }
        } catch {
            print(CoreDataErrors.failedToSaveDataInContext(.viewContext).errorDescription)
        }
        if shouldCreate {
            bgContext.perform {
                self.castTodoToTodoEntity(in: bgContext, with: todo)
                
                do {
                    try bgContext.save()
                } catch {
                    print(CoreDataErrors.failedToSaveDataInContext(.someBackgroundContext).errorDescription)
                }
            }
        }
    }
    
    func resaveEditedTodo(_ todo: Todo, updatedTitle: String) {
        let bgContext = backgroundContext
        
        let fetchRquest = TodoEntity.fetchRequest()
        fetchRquest.predicate = NSPredicate(format: "finishedAt == nil AND id == %@", todo.id.uuidString)
        
        do {
            if let todoEntity = try bgContext.fetch(fetchRquest).first {
                todoEntity.title = updatedTitle
                do {
                    try bgContext.save()
                } catch {
                    print(CoreDataErrors.failedToSaveDataInContext(.someBackgroundContext).errorDescription)
                }
            }
        } catch {
            print(CoreDataErrors.failedToObtainData(.someBackgroundContext).errorDescription)
        }
    }
    
    func removeFinishedTodo(withId id: UUID, withRestoring: Bool) {
        let finishedTodosFetchRequest = TodoEntity.fetchRequest()
        finishedTodosFetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        finishedTodosFetchRequest.fetchLimit = 1
        let bgContext = backgroundContext
        bgContext.perform {
            do {
                if let finishedTodoEntity = try bgContext.fetch(finishedTodosFetchRequest).first {
                    if withRestoring {
                        finishedTodoEntity.finishedAt = nil
                    } else {
                        bgContext.delete(finishedTodoEntity)
                    }
                    do {
                        try bgContext.save()
                    } catch {
                        print(CoreDataErrors.failedToSaveDataInContext(.someBackgroundContext).errorDescription)
                    }
                }
            } catch {
                print("Error of finding todo with such id in storage: \(error.localizedDescription)")
            }
        }
    }
    
    func obtaingFinishedTodosFetchedResultsController() -> NSFetchedResultsController<TodoEntity> {
        
        let finishedTodosFetchRequest = TodoEntity.fetchRequest()
        finishedTodosFetchRequest.predicate = NSPredicate(format: "finishedAt != nil")
        finishedTodosFetchRequest.sortDescriptors = [NSSortDescriptor(key: "finishedAt", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: finishedTodosFetchRequest,
                                          managedObjectContext: viewContext,
                                          sectionNameKeyPath: nil, cacheName: nil)
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
    
    func castTodoToTodoEntity(in context: NSManagedObjectContext, with todo: Todo) {
        let todoEntity = TodoEntity(context: context)
        todoEntity.id = todo.id
        todoEntity.title = todo.title
        todoEntity.createdAt = todo.createdAt
        todoEntity.section = todo.section.rawValue
        todoEntity.finishedAt = todo.finishedAt
    }
}

/*
 //
 //  CoreDataManager.swift
 //  ToDo
 //
 //  Created by Тагир Файрушин on 01.03.2025.
 //

 import Foundation
 import CoreData

 class CoreDataManager {
     
     static var shared: CoreDataManager = CoreDataManager()
     
     lazy var persistentContainer: NSPersistentContainer = {
         
         let container = NSPersistentContainer(name: "ToDo")
         container.loadPersistentStores(completionHandler: { (storeDescription, error) in
             if let error = error as NSError? {
                 
                 fatalError("Unresolved error \(error), \(error.userInfo)")
             }
         })
         return container
     }()
     
     lazy var viewContext: NSManagedObjectContext = {
         let context = persistentContainer.viewContext
         context.automaticallyMergesChangesFromParent = true
         return context
     }()
     
     private init() {}
     
     func saveCompletedTodo(todo: Todo) {
         let backgroundContext = persistentContainer.newBackgroundContext()
         backgroundContext.perform {
             do {
                 let fetchRequest = TodoEntity.fetchRequest()
                 fetchRequest.predicate = NSPredicate(format: "id == %@", todo.id.uuidString)
                 
                 let results = try backgroundContext.fetch(fetchRequest)
                 
                 let entity: TodoEntity
                 if let existingEntity = results.first {
                     entity = existingEntity
                 } else {
                     entity = TodoEntity(context: backgroundContext)
                 }
                 
                 entity.merge(todo: todo)
                 entity.finishedDate = Date()
                 
                 try backgroundContext.save()
             } catch {
                 print("Error save completed todo: \(error)")
             }
         }
     }
     
     func createFetchResultController() -> NSFetchedResultsController<TodoEntity> {
         let fetchRequest = TodoEntity.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "finishedDate != nil")
         fetchRequest.sortDescriptors = []
         
         let fetchResultController = NSFetchedResultsController(
             fetchRequest: fetchRequest,
             managedObjectContext: viewContext,
             sectionNameKeyPath: nil,
             cacheName: nil)
         
         return fetchResultController
     }
     
     func obtainTodos() -> (sooner: [Todo], later: [Todo]) {
         let fetchRequest = TodoEntity.fetchRequest()
         
         do {
             let result = try viewContext.fetch(fetchRequest)
             var soonerTodos: [Todo] = []
             var laterTodos: [Todo] = []
             
             for entity in result  {
                 if entity.finishedDate == nil {
                     
                     let todo = Todo(id: entity.id,
                                     title: entity.title,
                                     section: entity.section == "soon" ? .soon : .later,
                                     creationData: entity.createdDate)
                     
                     switch todo.section {
                     case .soon: soonerTodos.append(todo)
                     case .later: laterTodos.append(todo)
                     }
                     
                 }
             }
             return (sooner: soonerTodos, later: laterTodos)
         } catch {
             print(" Fetch error: \(error.localizedDescription)")
             return (sooner: [], later: [])
         }
     }
 
 func saveTodos(soonerTodos: [Todo], laterTodos: [Todo]) {
         let fetchRequest = TodoEntity.fetchRequest()
         do {
             let results = try viewContext.fetch(fetchRequest)
             let dictionaryTodos = Dictionary(uniqueKeysWithValues: results.map { ($0.id, $0) })
             
             var processedIds: Set<UUID> = []
             
             for todo in soonerTodos {
                 if let entity = dictionaryTodos[todo.id] {
                     
                     if entity.section != "soon" {
                         entity.section = "soon"
                     }
                     
                     if entity.title != todo.title {
                         entity.title = todo.title
                     }
                     
                 } else {
                     let newTodo = TodoEntity(context: viewContext)
                     newTodo.merge(todo: todo)
                 }
                 processedIds.insert(todo.id)
             }
             
             for todo in laterTodos {
                 if let entity = dictionaryTodos[todo.id] {
                     
                     if entity.section != "later" {
                         entity.section = "later"
                     }
                     
                     if entity.title != todo.title {
                         entity.title = todo.title
                     }
                     
                 } else {
                     let newTodo = TodoEntity(context: viewContext)
                     newTodo.merge(todo: todo)
                 }
                 
                 processedIds.insert(todo.id)
             }
             
             for (id, entity) in dictionaryTodos where !processedIds.contains(id) {
                 if entity.finishedDate == nil {
                     viewContext.delete(entity)
                 }
             }
             
             try viewContext.save()
         } catch {
             print("Error save context")
         }
         
     }
 }
 `
 */
