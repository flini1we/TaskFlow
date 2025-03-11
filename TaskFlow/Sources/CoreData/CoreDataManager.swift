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
    
    func obtainActiveTodosInSelectedSection(in section: TodoTypes) -> Result<[Todo], CoreDataErrors> {
        let todosInSectionFetchRequest = TodoEntity.fetchRequest()
        todosInSectionFetchRequest.predicate = NSPredicate(format: "section == %@ AND finishedAt == nil", section.rawValue)
        todosInSectionFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            let todoEntities = try viewContext.fetch(todosInSectionFetchRequest)
            let todos = todoEntities.compactMap { castTodoEntityIntoTodo(entity: $0) }
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
            return .success(todos)
        } catch {
            print(CoreDataErrors.failedToObtainFinishedTodos.errorDescription)
        }
        return .failure(CoreDataErrors.failedToObtainFinishedTodos)
    }
    
    func replaceTodosInSection(todos: [Todo], at section: TodoTypes) {
        let bgContext = backgroundContext
        bgContext.performAndWait {
            
            let deleteTodosFetchRequest = TodoEntity.fetchRequest()
            deleteTodosFetchRequest.predicate = NSPredicate(format: "section == %@ AND finishedAt == nil", section.rawValue)
            
            do {
                let soonerTodoEntities = try bgContext.fetch(deleteTodosFetchRequest)
                soonerTodoEntities.forEach { bgContext.delete($0) }
                try bgContext.save()
                
                saveTodos(todos: todos, context: bgContext)
            } catch {
                print("Error during deleting entities from storage: \(error.localizedDescription)")
            }
        }
    }
    
    func saveFinishedTodo(todo: Todo) {
        guard todo.finishedAt != nil else { return }
        
        let bgContext = backgroundContext
        
        bgContext.performAndWait {
            self.castTodoToTodoEntity(in: bgContext, with: todo)
            
            do {
                try bgContext.save()
            } catch {
                print(CoreDataErrors.failedToSaveDataInContext(.someBackgroundContext).errorDescription)
            }
        }
    }
    
    func removeFinishedTodo(withId id: UUID) {
        let finishedTodosFetchRequest = TodoEntity.fetchRequest()
        finishedTodosFetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        finishedTodosFetchRequest.fetchLimit = 1
        let bgContext = backgroundContext
        bgContext.performAndWait {
            do {
                if let entitieToDelete = try bgContext.fetch(finishedTodosFetchRequest).first {
                    bgContext.delete(entitieToDelete)
                    do {
                        try bgContext.save()
                    } catch {
                        print("Error of saving data in bgContext: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("Entitie with such id is not located in storage: \(error.localizedDescription)")
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
    
    func saveTodos(todos: [Todo], context: NSManagedObjectContext) {
        
        return context.performAndWait {
            for todo in todos { castTodoToTodoEntity(in: context, with: todo) }
            
            do {
                try context.save()
            } catch {
                print("Error during saving data from backgroundContext: \(error.localizedDescription)")
            }
        }
    }
    
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
