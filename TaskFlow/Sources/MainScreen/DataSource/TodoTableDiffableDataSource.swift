//
//  TodoTableDiffableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 10.02.2025.
//

import UIKit

final class TodoTableDiffableDataSource: NSObject {
    
    private var dataSource: UITableViewDiffableDataSource<MainTableSections, Todo>?
    
    var bindIdToDataSource: ((UUID) -> Void)?
    var bindFinishingToDataSource: ((UUID) -> Void)?
    
    func setupDataSource(table: UITableView, todos: [Todo]) {
        
        dataSource = UITableViewDiffableDataSource(tableView: table, cellProvider: { tableView, indexPath, todo in
            let cell = table.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as! TodoTableViewCell
            cell.configureWithTodo(todo)
            cell.changeTodoSection = { [weak self] id in self?.bindIdToDataSource?(id) }
            cell.finishTodo = { [weak self] id in self?.bindFinishingToDataSource?(id) }
            return cell
        })
        confirmSnapshot(todos: todos, animation: false)
    }
    
    func confirmSnapshot(todos: [Todo], animation: Bool) {
    
        var snapshot = NSDiffableDataSourceSnapshot<MainTableSections, Todo>()
        if !todos.isEmpty {
            snapshot.appendSections([todos[0].section])
            snapshot.appendItems(todos)
        }
        
        dataSource?.applySnapshotUsingReloadData(snapshot)
    }
}
