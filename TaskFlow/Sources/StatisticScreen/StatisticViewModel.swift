//
//  StatisticViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 07.03.2025.
//

import Foundation
import CoreData
import SwiftUI

final class StatisticViewModel: NSObject, ObservableObject {
    
    @Published var selectedTimeRange: TimeRange = .day
    @Published var chartData: [ChartDataPoint] = []
    
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
    private lazy var finishedTodosCount: Int = { self.finishedTodosFethedResultsController.fetchedObjects?.count ?? 0 }()
    
    init(todoService: TodoService,
         onTodoRestoringCompletion: @escaping ((Todo, Bool) -> Void)
    ) {
        self.todoService = todoService
        self.finishedTodosFethedResultsController = todoService.getFinishedTodosFetchedResultsController()
        self.onTodoRestoring = onTodoRestoringCompletion
        super.init()
        
        finishedTodosFethedResultsController.delegate = self
        self.obtainData()
        self.updateChartData()
    }
    
    func obtainData() {
        do {
            try finishedTodosFethedResultsController.performFetch()
        } catch {
            print("Error of obtaining finished tasks: \(error.localizedDescription)")
        }
    }
    
    func updateChartData(for timeRange: TimeRange? = nil) {
        let range = timeRange ?? selectedTimeRange
        chartData = getPreparedTodos(for: range)
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
        finishedTodosCount -= 1
        onUpdateViewModelData?(todo)
        let validatedHeight = (finishedTodosCount != 0) ? getHeight() : 0
        onUpdateTableHeight?(validatedHeight)
    }
    
    func getHeight() -> CGFloat {
        guard finishedTodosCount != 0 else { return 0 }
        return (TodoCellSize.default.value) * CGFloat(finishedTodosCount) + 10
    }
    
    func getPreparedTodos(for timeRange: TimeRange) -> [ChartDataPoint] {
        switch timeRange {
        case .day:
            getTodaysTodos()
        case .week:
            getWeeksTodos()
        case .month:
            getThisMonthsTodos()
        }
    }
    
    func selectedUnit(from timeRange: TimeRange) -> Calendar.Component {
        switch timeRange {
        case .day: return .hour
        case .week: return .day
        case .month: return .day
        }
    }
    
    func getBarMarkHeight() -> CGFloat { BarMarkSize.withTimeRange(selectedTimeRange).getVal }
    
    func getAverage() -> Int {
        let avg = chartData.reduce(0) { sum, chartData in sum + chartData.count }
        
        if selectedTimeRange == .week { return avg / 7 }
        else { return avg / 30 }
    }
}

extension StatisticViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onContentWillChange?()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onContentDidChange?()
        
        updateChartData(for: self.selectedTimeRange)
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
private extension StatisticViewModel {
    
    func getTodaysTodos() -> [ChartDataPoint] {
        guard let fetchedObjects = finishedTodosFethedResultsController.fetchedObjects
        else { return [ChartDataPoint(date: currentDate, count: 0)] }
        
        let finishedTasks = Todo.castToTodos(entities: fetchedObjects)
        let data = finishedTasks.filter { todo in
            calendar.isDate(
                calendar.startOfDay(for: todo.finishedAt!), inSameDayAs: calendar.startOfDay(for: currentDate)
            )
        }
        return [ChartDataPoint(date: currentDate, count: data.isEmpty ? 0 : data.count)]
    }
    
    func getWeeksTodos() -> [ChartDataPoint] {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start else { return [] }
        guard let fetchedObjects = finishedTodosFethedResultsController.fetchedObjects
        else { return [ChartDataPoint(date: currentDate, count: 0)] }
        
        let finishedTasks = Todo.castToTodos(entities: fetchedObjects)
        
        var todosByDay: [Date : Int] = [ : ]
        for todo in finishedTasks {
            todosByDay[calendar.startOfDay(for: todo.finishedAt!), default: 0] += 1
        }
        
        var weekData: [ChartDataPoint] = []
        for dayOffset in 0 ..< 7 {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            let dayStart = calendar.startOfDay(for: day)
            
            let count = todosByDay[dayStart] ?? 0
            weekData.append(ChartDataPoint(date: dayStart, count: count))
        }
        return weekData
    }
    
    func getThisMonthsTodos() -> [ChartDataPoint] {
        guard let fetchedObjects = finishedTodosFethedResultsController.fetchedObjects
        else { return [ChartDataPoint(date: currentDate, count: 0)] }
        guard let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start
        else { return [] }
        
        let finishedTasks = Todo.castToTodos(entities: fetchedObjects)
        let dayQuantity = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 0
        var todosByDay: [Date : Int] = [ : ]
        
        for todo in finishedTasks {
            todosByDay[calendar.startOfDay(for: todo.finishedAt!), default: 0] += 1
        }
        
        var monthData: [ChartDataPoint] = []
        for dayOffset in 0 ..< dayQuantity {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth)!
            let dayStart = calendar.startOfDay(for: day)
            
            let count = todosByDay[dayStart] ?? 0
            monthData.append(ChartDataPoint(date: dayStart, count: count))
        }
        return monthData
    }
    
    func castTodoEntityIntoTodo(entity todoEntity: TodoEntity) -> Todo {
        Todo(id: todoEntity.id,
             title: todoEntity.title,
             section: MainTableSections(rawValue: todoEntity.section) ?? .sooner,
             createdAt: todoEntity.createdAt,
             finishedAt: todoEntity.finishedAt)
    }
}
