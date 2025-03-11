//
//  MainViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import Foundation

final class MainViewModel: KeyboardObservable {
    
    // MARK: MainTableDelegateData
    var keyboardObserver: KeyboardObserver?
    var lastSectionTapped: MainTableSections?
    
    var tableState: TableState = .default {
        didSet {
            tableStateOnChange?()
        }
    }
    var tableStateOnChange: (() -> Void)?
    var reloadButtonImage: ((MainTableSections) -> Void)?
    
    init(todoService: TodoService) {
        self.todoService = todoService
    }

    func handleHeaderButtonTapped(for section: MainTableSections, isHalfScreen: Bool) {
        
        if section == .sooner {
            if lastSectionTapped == .later {
                reloadButtonImage?(.later)
            }
            if isHalfScreen {
                tableState = .upperOpened
            } else {
                tableState = .default
            }
        } else {
            if lastSectionTapped == .sooner {
                reloadButtonImage?(.sooner)
            }
            if isHalfScreen {
                tableState = .lowerOpened
            } else {
                tableState = .default
            }
        }
        lastSectionTapped = section
    }
    
    func calculateCellsHeight(at indexPath: IndexPath) -> CGFloat {
        let devider: CGFloat = (keyboardObserver!.isKeyboardEnabled) ? 2 : 1
        
        switch tableState {
        case .default:
            return (TableItemSize.default.value - 1) / devider
        case .upperOpened:
            if indexPath.section == 0 {
                return (TableItemSize.fullScreen.value - 2) / devider
            } else {
                return TableItemSize.none.value
            }
        case .lowerOpened:
            if indexPath.section == 0 {
                return TableItemSize.none.value
            } else {
                return (TableItemSize.fullScreen.value - 2) / devider
            }
        case .addingTask:
            return TableItemSize.default.value / 2
        }
    }
    
    func setupObserver(onShowKeyboard: ((CGRect) -> Void)?, onHideKeyboard: (() -> Void)?) {
        keyboardObserver = KeyboardObserver(onShow: { [weak self] keyboardFrame in
            onShowKeyboard?(keyboardFrame)
            self?.tableState = .addingTask
        }, onHide: { [weak self] in
            onHideKeyboard?()
            self?.tableState = .default
        })
    }
    
    func controllScrollingValue(_ value: CGFloat) -> CGFloat {
        
        if value > 10 {
            return 10
        } else if value < -10 {
            return -10
        }
        return value
    }
    
    func changeStateAccordingToDragging(scrolledValue: CGFloat) -> Bool {
        
        let didSectionChanged = false
        if scrolledValue >= 10 {
            switch tableState {
            case .default:
                tableState = .lowerOpened
                self.lastSectionTapped = .later
            case .upperOpened:
                tableState = .default
                self.lastSectionTapped = .later
            case .addingTask:
                tableState = .lowerOpened
                self.lastSectionTapped = .later
            case .lowerOpened: break }
            
            return !didSectionChanged
        } else if scrolledValue <= -10 {
            
            switch tableState {
            case .addingTask: fallthrough
            case .default:
                tableState = .upperOpened
                self.lastSectionTapped = .later
            case .upperOpened:
                tableState = .default
                self.lastSectionTapped = .later
            case .lowerOpened:
                tableState = .default
                self.lastSectionTapped = .later
            }
            
            return !didSectionChanged
        }
        return didSectionChanged
    }
    
    // MARK: MainTableDataSourceData
    private(set) var todoService: TodoService
    
    var updateBackground: ((MainTableSections) -> Void)?
    var updateCounter: ((MainTableSections) -> Void)?
    var updateDatoSourceWithEditedData: ((Todo, Todo) -> Void)?
    
    lazy var soonerTodos = todoService.getTodos(type: .sooner) {
        didSet {
            updateViewData(.sooner)
        }
    }
    
    lazy var laterTodos = todoService.getTodos(type: .later) {
        didSet {
            updateViewData(.later)
        }
    }
    
    lazy var finishedTodos = todoService.getTodos(type: .finished)
    
    func saveDataOnScreenDisappearing() {
        todoService.saveUpdatedData(sooner: soonerTodos, later: laterTodos)
    }
    
    func updateBothViewData() {
        
        updateViewData(.sooner)
        updateViewData(.later)
    }
    
    func getTodos(in section: MainTableSections) -> [Todo] {
        section == .sooner ? soonerTodos : laterTodos
    }
    
    func changeSection(from section: MainTableSections, with id: UUID) {
        FeedBackService.occurreVibration(style: .light)
        if section == .sooner {
        
            guard let index = soonerTodos.firstIndex(where: { $0.id == id }) else { return }
            
            var movedTodo = soonerTodos[index]
            movedTodo.changeSection()
            
            soonerTodos.remove(at: index)
            laterTodos.append(movedTodo)
        } else {
            
            guard let index = laterTodos.firstIndex(where: { $0.id == id }) else { return }
            
            var movedTodo = laterTodos[index]
            movedTodo.changeSection()
            
            laterTodos.remove(at: index)
            soonerTodos.append(movedTodo)
        }
    }
    
    func removeAndFinishTodo(from section: MainTableSections, with id: UUID) {
        
        if section == .sooner {
            guard let index = soonerTodos.firstIndex(where: { $0.id == id }) else { return }
            
            finishTodo(in: .sooner, at: index)
            soonerTodos.remove(at: index)
        } else {
            guard let index = laterTodos.firstIndex(where: { $0.id == id }) else { return }
            
            finishTodo(in: .later, at: index)
            laterTodos.remove(at: index)
        }
    }
    
    func editTodo(todo: Todo, updatedTitle title: String) {
        
        if let index = soonerTodos.firstIndex(where: { $0 == todo }) {
            soonerTodos[index].editTitle(updatedTitle: title)
            updateDatoSourceWithEditedData?(todo, soonerTodos[index])
        } else {
            guard let index = laterTodos.firstIndex(where: { $0 == todo }) else { return }
            laterTodos[index].editTitle(updatedTitle: title)
            updateDatoSourceWithEditedData?(todo, laterTodos[index])
        }
    }
    
    func restoreTodo(todo: Todo, shouldRestore: Bool) {
        todoService.restoreFinishedTodoFromStorage(todo: todo)
        var todo = todo
        todo.restoreTodo()
        if shouldRestore {
            if todo.section == .sooner { soonerTodos.append(todo) } else { laterTodos.append(todo) }
        }
    }
}

// MARK: Private Methods
private extension MainViewModel {
    
    func updateViewData(_ section: MainTableSections) {
        
        updateBackground?(section)
        updateCounter?(section)
    }
    
    func finishTodo(in section: MainTableSections, at index: Int) {
        
        var finishedTodo = (section == .sooner) ? soonerTodos[index] : laterTodos[index]
        finishedTodo.finishTask()
        finishedTodos.append(finishedTodo)
        
        todoService.saveFinishedTodo(finishedTodo: finishedTodo)
    }
    
    func updateBothButtonImages() {
        
        reloadButtonImage?(.sooner)
        reloadButtonImage?(.later)
    }
}
