//
//  MainTableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainTableDataSource: NSObject, UITableViewDataSource {
    
    private var mainViewModel: MainViewModel
    
    var soonerCell: MainTableViewCell!
    private var laterCell: MainTableViewCell!
    
    private(set) var soonerSectionDataSource: TodoTableDiffableDataSource
    private(set) var laterSectionDataSource: TodoTableDiffableDataSource
    
    private(set) lazy var soonerSectionDragDropDelegate: DragAndDropDelegate = {
        DragAndDropDelegate(data: mainViewModel.getTodos(in: .sooner), onDraggingDataChanged: { [weak self] todos in
            self?.updateViewModelAndDataSourceData(with: todos)
        })
    }()
    private(set) lazy var laterSectionDragDropDelegate: DragAndDropDelegate = {
        DragAndDropDelegate(data: mainViewModel.getTodos(in: .later), onDraggingDataChanged: { [weak self] todos in
            self?.updateViewModelAndDataSourceData(with: todos)
        })
    }()
    
    init(viewModel mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        soonerSectionDataSource = TodoTableDiffableDataSource(viewModel: mainViewModel)
        laterSectionDataSource = TodoTableDiffableDataSource(viewModel: mainViewModel)
        
        super.init()
        mainViewModel.updateDatoSourceWithEditedData = { [weak self] oldTodo, newTodo in
            let section = oldTodo.section
            switch section {
            case .sooner:
                self?.soonerSectionDataSource.replaceExistingElementWithUpdated(oldElement: oldTodo, newElementTodo: newTodo)
            case .later:
                self?.laterSectionDataSource.replaceExistingElementWithUpdated(oldElement: oldTodo, newElementTodo: newTodo)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        switch indexPath.section {
        case 0:
            soonerCell = cell
            soonerCell.tasksTable.dragDelegate = soonerSectionDragDropDelegate
            soonerCell.tasksTable.dropDelegate = soonerSectionDragDropDelegate
            configureCell(section: .sooner)
        case 1:
            laterCell = cell
            laterCell.tasksTable.dragDelegate = laterSectionDragDropDelegate
            laterCell.tasksTable.dropDelegate = laterSectionDragDropDelegate
            configureCell(section: .later)
            default: break }
        return cell
    }
    
    func checkTableBackground(_ section: MainTableSections, _ todos: [Todo]) {
        getCurrentCell(in: section).tasksTable.backgroundView?.isHidden = !todos.isEmpty
    }
    
    func updateDragTableDelegateData() {
        
        soonerSectionDragDropDelegate.updateData(mainViewModel.getTodos(in: .sooner))
        laterSectionDragDropDelegate.updateData(mainViewModel.getTodos(in: .later))
    }
    
    func updateCellsColor() {
        
        soonerSectionDataSource.updateColor()
        laterSectionDataSource.updateColor()
    }
    
    func confirmSnapshot(in section: MainTableSections, with todo: [Todo]) {
        let currenDataSource = getCurrentDataSource(in: section)
        currenDataSource.confirmSnapshot(todos: todo, animation: true)
    }
}

private extension MainTableDataSource {
    
    func updateViewModelAndDataSourceData(with todos: [Todo]) {
        guard let section = todos.first?.section else { return }
        switch section {
        case .sooner:
            mainViewModel.soonerTodos = todos
            soonerSectionDataSource.confirmSnapshot(todos: todos, animation: false)
        case .later:
            mainViewModel.laterTodos = todos
            laterSectionDataSource.confirmSnapshot(todos: todos, animation: false)
        }
    }
    
    func configureCell(section: MainTableSections) {
        let cell = getCurrentCell(in: section)
        let todos = mainViewModel.getTodos(in: section)
        let dataSource = getCurrentDataSource(in: section)
        
        dataSource.onTodoSectionChange = { [weak self] todo in self?.moveTodo(with: todo) }
        dataSource.onTodoFinishing = { [weak self] todo in self?.finishTodo(with: todo) }
        dataSource.onTodoRestoring = { [weak self] todo in self?.restoreTodo(with: todo) }
        dataSource.setupDataSource(table: cell.tasksTable, todos: todos)
    }
    
    func getCurrentCell(in section: MainTableSections) -> MainTableViewCell {
        (section == .sooner) ? soonerCell : laterCell
    }
    
    func getCurrentDataSource(in section: MainTableSections) -> TodoTableDiffableDataSource {
        (section == .sooner) ? soonerSectionDataSource : laterSectionDataSource
    }
    
    func finishTodo(with todo: Todo) {
        
        mainViewModel.removeAndFinishTodo(from: todo.section, with: todo.id)
        if todo.section == .sooner {
            soonerSectionDataSource.removeExistingElement(todo: todo)
        } else {
            laterSectionDataSource.removeExistingElement(todo: todo)
        }
        updateDragTableDelegateData()
    }
    
    func moveTodo(with todo: Todo) {
        let section = todo.section
        var todo = todo
        mainViewModel.changeSection(from: todo.section, with: todo.id)
        
        if section == .later {
            laterSectionDataSource.removeExistingElement(todo: todo)
            todo.changeSection()
            soonerSectionDataSource.appendElementToSection(todo: todo, to: .sooner)
        } else {
            soonerSectionDataSource.removeExistingElement(todo: todo)
            todo.changeSection()
            laterSectionDataSource.appendElementToSection(todo: todo, to: .later)
        }
        updateDragTableDelegateData()
    }
    
    func restoreTodo(with todo: Todo) {
        mainViewModel.restoreTodo(todo: todo, shouldRestore: true)
    }
}

