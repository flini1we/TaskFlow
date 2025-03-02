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
        DragAndDropDelegate(data: mainViewModel.getTodos(in: .sooner))
    }()
    private(set) lazy var laterSectionDragDropDelegate: DragAndDropDelegate = {
        DragAndDropDelegate(data: mainViewModel.getTodos(in: .later))
    }()
    
    init(viewModel mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        soonerSectionDataSource = TodoTableDiffableDataSource(viewModel: mainViewModel)
        laterSectionDataSource = TodoTableDiffableDataSource(viewModel: mainViewModel)
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
    
    func configureCell(section: MainTableSections) {
        let cell = getCurrentCell(in: section)
        let todos = mainViewModel.getTodos(in: section)
        let dataSource = getCurrentDataSource(in: section)
        
        dataSource.setupDataSource(table: cell.tasksTable, todos: todos)
        
        dataSource.onTodoSectionChange = { [weak self] id in
            self?.moveTodo(from: section, with: id)
        }
        dataSource.onTodoFinishing = { [weak self] id in
            self?.finishTodo(from: section, with: id)
        }
    }
    
    func getCurrentCell(in section: MainTableSections) -> MainTableViewCell {
        (section == .sooner) ? soonerCell : laterCell
    }
    
    func getCurrentDataSource(in section: MainTableSections) -> TodoTableDiffableDataSource {
        (section == .sooner) ? soonerSectionDataSource : laterSectionDataSource
    }
    
    func finishTodo(from section: MainTableSections, with id: UUID) {
        
        mainViewModel.removeAndFinishTodo(from: section, with: id)
        updateDragTableDelegateData()
    }
    
    func moveTodo(from section: MainTableSections, with id: UUID) {
        
        mainViewModel.changeSection(from: section, with: id)
        updateDragTableDelegateData()
    }
}

