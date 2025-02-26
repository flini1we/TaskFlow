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
    
    private var tableState: TableState = .default {
        didSet {
            tableStateOnChange?(tableState)
        }
    }
    var tableStateOnChange: ((TableState) -> Void)?
    var reloadButtonImage: ((MainTableSections) -> Void)?

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
    
    func calculateCellsHeight(at indexPath: IndexPath, withState state: TableState) -> CGFloat {
        
        switch state {
        case .default:
            return TableItemSize.default.value - 1
        case .upperOpened:
            if indexPath.section == 0 {
                return TableItemSize.fullScreen.value - 2
            } else {
                return TableItemSize.none.value
            }
        case .lowerOpened:
            if indexPath.section == 0 {
                return TableItemSize.none.value
            } else {
                return TableItemSize.fullScreen.value - 2
            }
        case .addingTask:
            return TableItemSize.default.value / 2
        }
    }
    
    func setupObserver(onShowKeyboard: ((CGRect) -> Void)?,
                       onHideKeyboard: (() -> Void)?) {
        keyboardObserver = KeyboardObserver(onShow: { keyboardFrame in
            onShowKeyboard?(keyboardFrame)
        }, onHide: {
            onHideKeyboard?()
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
    
    func changeStateAccordingToDragging(scrolledValue: CGFloat, currentState: inout TableState) -> Bool {
        
        let didSectionChanged = false
        if scrolledValue >= 10 {
            if currentState == .default {
                currentState = .lowerOpened
                self.lastSectionTapped = .later
            } else if currentState == .upperOpened {
                currentState = .default
                self.lastSectionTapped = .later
            }
            return !didSectionChanged
        } else if scrolledValue <= -10 {
        
            if currentState == .default {
                currentState = .upperOpened
                self.lastSectionTapped = .later
            } else if currentState == .lowerOpened {
                currentState = .default
                self.lastSectionTapped = .later
            }
            return !didSectionChanged
        }
        return didSectionChanged
    }
    
    // MARK: MainTableDataSourceData
    var updateTodos: ((MainTableSections, [Todo]) -> Void)?
    var updateBackground: ((MainTableSections) -> Void)?
    var updateCounter: ((MainTableSections) -> Void)?
    
    lazy var soonerTodos = Todo.getTodos().filter { $0.section == .sooner } {
        didSet {
            updateTodos?(.sooner, soonerTodos)
            updateViewData(.sooner)
        }
    }
    
    lazy var laterTodos = Todo.getTodos().filter { $0.section == .later } {
        didSet {
            updateTodos?(.later, laterTodos)
            updateViewData(.later)
        }
    }
    
    func updateBothViewData() {
        
        updateViewData(.sooner)
        updateViewData(.later)
    }
    
    func getTodos(in section: MainTableSections) -> [Todo] {
        section == .sooner ? soonerTodos : laterTodos
    }
    
    func changeSection(from section: MainTableSections, with id: UUID) {
        
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
            
            soonerTodos[index].finishTask()
            soonerTodos.remove(at: index)
        } else {
            
            guard let index = laterTodos.firstIndex(where: { $0.id == id }) else { return }
            
            laterTodos[index].finishTask()
            laterTodos.remove(at: index)
        }
    }
}

private extension MainViewModel {
    
    func updateViewData(_ section: MainTableSections) {
        
        updateBackground?(section)
        updateCounter?(section)
    }
}
