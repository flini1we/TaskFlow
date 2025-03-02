//
//  TodoTableDiffableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 10.02.2025.
//

import UIKit

final class TodoTableDiffableDataSource: NSObject {
    
    private var dataSource: UITableViewDiffableDataSource<MainTableSections, Todo>?
    private var mainViewModel: MainViewModel
    
    var onTodoSectionChange: ((UUID) -> Void)?
    var onTodoFinishing: ((UUID) -> Void)?
    
    private var cells: [TodoTableViewCell] = []
    
    init(viewModel: MainViewModel) {
        self.mainViewModel = viewModel
    }
    
    func setupDataSource(table: UITableView, todos: [Todo]) {
        
        dataSource = UITableViewDiffableDataSource(tableView: table,
        cellProvider: { [weak self] tableView, indexPath, todo in
            guard let self else { return nil }
            let cell = table.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as! TodoTableViewCell
            cell.configureWithTodo(todo,
                                   delegate: TodoTextFieldDelegate(viewModel: mainViewModel, currentId: todo.id))
            cell.changeTodoSection = { [weak self] id in self?.onTodoSectionChange?(id) }
            cell.finishTodo = { [weak self] id in self?.onTodoFinishing?(id) }
            cells.append(cell)
            return cell
        })
        confirmSnapshot(todos: todos, animation: true)
    }
    
    func confirmSnapshot(todos: [Todo], animation: Bool) {
    
        var snapshot = NSDiffableDataSourceSnapshot<MainTableSections, Todo>()
        if !todos.isEmpty {
            snapshot.appendSections([todos[0].section])
            snapshot.appendItems(todos)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: animation)
    }
    
    func updateColor() {
        for cell in cells {
            cell.updateColor()
        }
    }
}
