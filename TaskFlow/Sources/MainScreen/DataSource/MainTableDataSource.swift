//
//  MainTableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainTableDataSource: NSObject, UITableViewDataSource {
    
    private var mainViewModel: MainViewModel!
    
    private(set) var upperCell: MainTableViewCell!
    private(set) var lowerCell: MainTableViewCell!
    private var soonerSectionDataSource = TodoTableDiffableDataSource()
    private var laterSectionDataSource = TodoTableDiffableDataSource()
    
    private(set) lazy var soonerSectionDragDropDelegate: DragAndDropDelegate = {
        DragAndDropDelegate(data: soonerTodos)
    }()
    private(set) lazy var laterSectionDragDropDelegate: DragAndDropDelegate = {
        DragAndDropDelegate(data: laterTodos)
    }()
    
    var updateUpperHeaderTodoCount: ((Int) -> Void)?
    var updateLowerHeaderTodoCount: ((Int) -> Void)?

    /// for testing
    var todos: [Todo] = [Todo(id: UUID(), title: "Later", section: .later),
                         Todo(id: UUID(), title: "Sooner", section: .sooner),
                         Todo(id: UUID(), title: "q3", section: .later),
                         Todo(id: UUID(), title: "JKLDSJFKLSJDFLKSJDLKFJSDLKFJDSLKFJSKLDJFLSDJF", section: .later),
    ]

    lazy var soonerTodos = todos.filter { $0.section == .sooner } {
        didSet {
            checkTableBackground(upperCell, soonerTodos)
            updateUpperHeaderTodoCount?(soonerTodos.count)
            
            soonerSectionDataSource.confirmSnapshot(todos: soonerTodos, animation: false)
        }
    }
    lazy var laterTodos = todos.filter { $0.section == .later } {
        didSet {
            checkTableBackground(lowerCell, laterTodos)
            updateLowerHeaderTodoCount?(laterTodos.count)
            
            laterSectionDataSource.confirmSnapshot(todos: laterTodos, animation: false)
        }
    }
    
    init(viewModel mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        switch indexPath.section {
        case 0:
            upperCell = cell
            upperCell.tasksTable.dragDelegate = soonerSectionDragDropDelegate
            upperCell.tasksTable.dropDelegate = soonerSectionDragDropDelegate
            configureCell(cell: upperCell, section: .sooner)
        case 1:
            lowerCell = cell
            lowerCell.tasksTable.dragDelegate = laterSectionDragDropDelegate
            lowerCell.tasksTable.dropDelegate = laterSectionDragDropDelegate
            configureCell(cell: lowerCell, section: .later)
        default: break
        }
        
        return cell
    }
    
    private func checkTableBackground(_ cell: MainTableViewCell?, _ todos: [Todo]) {
        cell?.tasksTable.backgroundView?.isHidden = !todos.isEmpty
    }
    
    private func configureCell(cell: MainTableViewCell, section: MainTableSections) {
        let todos = (section == .sooner) ? soonerTodos : laterTodos
        let dataSource = (section == .sooner) ? soonerSectionDataSource : laterSectionDataSource

        dataSource.setupDataSource(table: cell.tasksTable, todos: todos)
        checkTableBackground(cell, todos)

        dataSource.bindIdToDataSource = { [weak self] id in
            self?.moveTodo(from: section, with: id)
        }
        dataSource.bindFinishingToDataSource = { [weak self] id in
            self?.finishTodo(in: section, id: id)
        }
    }
    
    private func setupData(cell: MainTableViewCell, dataSource: TodoTableDiffableDataSource, data: [Todo], table: UITableView, currentSection: MainTableSections) {
        
        dataSource.setupDataSource(table: table, todos: data)
        self.checkTableBackground(cell, data)
        
        dataSource.bindIdToDataSource = { [weak self] id in
            self?.moveTodo(from: currentSection, with: id)
        }
        dataSource.bindFinishingToDataSource = { [weak self] id in
            self?.finishTodo(in: currentSection, id: id)
        }
    }
    
    private func moveTodo(from: MainTableSections, with id: UUID) {
        switch from {
        case .sooner:
            changeSection(findIn: &soonerTodos, appendIn: &laterTodos, id: id)
        case .later:
            changeSection(findIn: &laterTodos, appendIn: &soonerTodos, id: id)
        }
        
        updateDragTableDelegateData()
    }
    
    func updateDragTableDelegateData() {
        
        soonerSectionDragDropDelegate.updateData(soonerTodos)
        laterSectionDragDropDelegate.updateData(laterTodos)
    }
    
    private func changeSection(findIn: inout [Todo], appendIn: inout [Todo], id: UUID) {

        guard let index = findIn.firstIndex(where: { $0.id == id }) else { return }
        var movedTodo = findIn[index]
        movedTodo.changeSection()
        
        findIn.remove(at: index)
        appendIn.append(movedTodo)
    }
    
    private func finishTodo(in section: MainTableSections, id: UUID) {
        
        switch section {
        case .sooner:
            removeAndFinishTask(from: &soonerTodos, with: id)
        case .later:
            removeAndFinishTask(from: &laterTodos, with: id)
        }
    }
    
    private func removeAndFinishTask(from array: inout [Todo], with id: UUID) {
        
        guard let index = array.firstIndex(where: { $0.id == id }) else { return }
        array[index].finishTask()
        array.remove(at: index)
    }
}

