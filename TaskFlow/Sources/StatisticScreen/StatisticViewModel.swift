//
//  StatisticViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 07.03.2025.
//

import Foundation
import CoreData

final class StatisticViewModel: NSObject {
    
    var onContentWillChange: (() -> Void)?
    var onContentDidChange: (() -> Void)?
    var onDeletingRowAt: ((IndexPath) -> Void)?
    var onInsertingRowAt: ((IndexPath) -> Void)?
    
    private var todoService: TodoService
    private var finishedTodosFethedResultsController: NSFetchedResultsController<TodoEntity>
    private var onTodoRestoring: ((Todo, Bool) -> Void)
    private var finishedData: [Todo]
    
    init(todoService: TodoService,
         onTodoRestoringCompletion: @escaping ((Todo, Bool) -> Void),
         finishedData: [Todo]) {
        self.todoService = todoService
        self.finishedTodosFethedResultsController = todoService.getFinishedTodosFetchedResultsController()
        self.onTodoRestoring = onTodoRestoringCompletion
        self.finishedData = finishedData
        super.init()
        
        finishedTodosFethedResultsController.delegate = self
        self.obtainData()
    }
    
    func obtainData() {
        do {
            try finishedTodosFethedResultsController.performFetch()
        } catch {
            print("Error of obtaining finished tasks: \(error.localizedDescription)")
        }
    }
    
    func getNumberOfSections() -> Int { finishedTodosFethedResultsController.sections?.count ?? 0 }
    func getNumberOfRowsInSection(section: Int) -> Int {
        finishedTodosFethedResultsController.sections?[section].numberOfObjects ?? 0
    }
    func getTodo(at indexPath: IndexPath) -> Todo {
        castTodoEntityIntoTodo(entity: finishedTodosFethedResultsController.object(at: indexPath))
    }
    func onTodoRestore(todo: Todo, shouldRestore: Bool) {
        onTodoRestoring(todo, shouldRestore)
    }
}

extension StatisticViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onContentWillChange?()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onContentDidChange?()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath {
                onInsertingRowAt?(newIndexPath)
            }
        case .delete:
            if let indexPath {
                onDeletingRowAt?(indexPath)
            }
        case .move, .update:
            break
        @unknown default:
            fatalError("Unhandled NSFetchedResultsChangeType")
        }
    }
}

private extension StatisticViewModel {
    
    func castTodoEntityIntoTodo(entity todoEntity: TodoEntity) -> Todo {
        Todo(id: todoEntity.id,
             title: todoEntity.title,
             section: MainTableSections(rawValue: todoEntity.section) ?? .sooner,
             createdAt: todoEntity.createdAt,
             finishedAt: todoEntity.finishedAt)
    }
}
