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
        
        if indexPath.section == 0 {
            upperCell = cell
            soonerSectionDataSource.setupDataSource(table: upperCell!.tasksTable, todos: soonerTodos)
            upperCell!.tasksTable.backgroundView?.isHidden = !soonerTodos.isEmpty
            
            soonerSectionDataSource.bindIdToDataSource = { [weak self] id in
                self?.moveTodo(from: .sooner, to: .later, with: id)
            }
        } else {
            lowerCell = cell
            laterSectionDataSource.setupDataSource(table: lowerCell!.tasksTable, todos: laterTodos)
            lowerCell!.tasksTable.backgroundView?.isHidden = !laterTodos.isEmpty
            
            laterSectionDataSource.bindIdToDataSource = { [weak self] id in
                self?.moveTodo(from: .later, to: .sooner, with: id)
            }
        }
        return cell
    }
    
    private func moveTodo(from: MainTableSections, to: MainTableSections, with id: UUID) {
        
        if from == .sooner {
            if let index = soonerTodos.firstIndex(where: { $0.id == id }) {
                var movedTodo = soonerTodos[index]
                movedTodo.changeSection()
                
                if let indexInGlobalTodos = todos.firstIndex(where: { $0.id == id }) {
                    todos.remove(at: indexInGlobalTodos)
                    todos.append(movedTodo)
                }
                soonerTodos.remove(at: index)
                laterTodos.append(movedTodo)
            }
        } else {
            if let index = laterTodos.firstIndex(where: { $0.id == id }) {
                var movedTodo = laterTodos[index]
                movedTodo.changeSection()
                
                if let indexInGlobalTodos = todos.firstIndex(where: { $0.id == id }) {
                    todos.remove(at: indexInGlobalTodos)
                    todos.append(movedTodo)
                }
                laterTodos.remove(at: index)
                soonerTodos.append(movedTodo)
            }
        }
    }
}
