//
//  StatisticViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 07.03.2025.
//

import Foundation
import CoreData

final class StatisticViewModel: NSObject {
    
    private lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = .current
        calendar.firstWeekday = 2
        return calendar
    }()
    private let currentDate = Date()
    
    var onContentWillChange: (() -> Void)?
    var onContentDidChange: (() -> Void)?
    var onDeletingRowAt: ((IndexPath) -> Void)?
    var onInsertingRowAt: ((IndexPath) -> Void)?
    var onUpdateTableHeight: ((CGFloat) -> Void)?
    var onUpdateViewModelData: ((Todo) -> Void)?
    
    private var todoService: TodoService
    private var finishedTodosFethedResultsController: NSFetchedResultsController<TodoEntity>
    private var onTodoRestoring: ((Todo, Bool) -> Void)
    private(set) var finishedData: [Todo]
    
    init(todoService: TodoService,
         onTodoRestoringCompletion: @escaping ((Todo, Bool) -> Void),
         finishedData: [Todo]
    ) {
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
        finishedData.removeAll { $0.id == todo.id }
        onUpdateViewModelData?(todo)
        let validatedHeight = !finishedData.isEmpty ? getHeight() : 0
        onUpdateTableHeight?(validatedHeight)
    }
    
    func getHeight() -> CGFloat {
        (TodoCellSize.default.value + 2.5) * CGFloat(finishedData.count)
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

// MARK: Calendar methods
extension StatisticViewModel {
    
    func getTodaysTodos() -> [Todo] {
        finishedData.compactMap { calendar.isDate($0.finishedAt!, inSameDayAs: currentDate) ? $0 : nil }
    }
    
    func getWeeksTodos() -> [Todo] {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start else { return [] }
        guard let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else { return [] }
        
        return finishedData.compactMap { todo in
            return (todo.finishedAt! >= startOfWeek && todo.finishedAt! < endOfWeek) ? todo : nil
        }
    }
    
    func getThisMonthsTodos() -> [Todo] {
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        return finishedData.compactMap { todo in
            
            let taskYear = calendar.component(.year, from: todo.finishedAt!)
            let taskMonth = calendar.component(.month, from: todo.finishedAt!)
            return (taskYear == currentYear && taskMonth == currentMonth) ? todo : nil
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
