//
//  MainTableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainTableDataSource: NSObject, UITableViewDataSource {
    
    private(set) var upperCell: MainTableViewCell?
    private(set) var lowerCell: MainTableViewCell?
    private var soonerSectionDataSource = TodoTableDiffableDataSource()
    private var laterSectionDataSource = TodoTableDiffableDataSource()
    
    /// for testing
    var todos: [Todo] = [Todo(id: UUID(), title: "Later", section: .later),
                         Todo(id: UUID(), title: "Sooner", section: .sooner),
                         Todo(id: UUID(), title: "q3", section: .later)]

    internal lazy var soonerTodos = todos.filter { $0.section == .sooner } {
        didSet {
            upperCell?.tasksTable.backgroundView?.isHidden = !soonerTodos.isEmpty
            soonerSectionDataSource.confirmSnapshot(todos: soonerTodos)
        }
    }
    private lazy var laterTodos = todos.filter { $0.section == .later } {
        didSet {
            lowerCell?.tasksTable.backgroundView?.isHidden = !laterTodos.isEmpty
            laterSectionDataSource.confirmSnapshot(todos: laterTodos)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        switch indexPath.section {
        case 0:
            upperCell = cell
            
            setupData(dataSource: soonerSectionDataSource,
                      data: soonerTodos,
                      table: upperCell!.tasksTable,
                      currentSection: .sooner)
        case 1:
            lowerCell = cell
            
            setupData(dataSource: laterSectionDataSource,
                      data: laterTodos,
                      table: lowerCell!.tasksTable,
                      currentSection: .later)
        default: break
        }
        
        return cell
    }
    
    private func setupData(dataSource: TodoTableDiffableDataSource, data: [Todo], table: UITableView, currentSection: MainTableSections) {
        
        dataSource.setupDataSource(table: table, todos: data)
        table.backgroundView?.isHidden = !data.isEmpty
        
        dataSource.bindIdToDataSource = { [weak self] id in
            self?.moveTodo(from: currentSection,
                           to: (currentSection == .sooner) ? .later : .sooner, with: id)
        }
        dataSource.bindFinishingToDataSource = { [weak self] id in
            self?.finishTodo(in: currentSection, id: id)
        }
    }
    
    private func moveTodo(from: MainTableSections, to: MainTableSections, with id: UUID) {
        switch from {
        case .sooner:
            changeSection(findIn: &soonerTodos, appendIn: &laterTodos, id: id)
        case .later:
            changeSection(findIn: &laterTodos, appendIn: &soonerTodos, id: id)
        }
        
        guard let indexInGlobalTodos = todos.firstIndex(where: { $0.id == id }) else { return }
        todos[indexInGlobalTodos].changeSection()
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
        removeAndFinishTask(from: &todos, with: id)
    }
    
    private func removeAndFinishTask(from array: inout [Todo], with id: UUID) {
        
        guard let index = array.firstIndex(where: { $0.id == id }) else { return }
        array[index].finishTask()
        print(array[index])
        array.remove(at: index)
    }
}
