//
//  TodoTableDiffableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 10.02.2025.
//

import UIKit

final class TodoTableDiffableDataSource: NSObject {
    
    var onTodoSectionChange: ((Todo) -> Void)?
    var onTodoFinishing: ((Todo) -> Void)?
    
    private var dataSource: UITableViewDiffableDataSource<MainTableSections, Todo>?
    private var mainViewModel: MainViewModel
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
                                   delegate: TodoTextFieldDelegate(viewModel: mainViewModel, currentTodo: todo))
            cell.changeTodoSection = { [weak self] todo in self?.onTodoSectionChange?(todo) }
            cell.finishTodo = { [weak self] todo in self?.onTodoFinishing?(todo) }
            cells.append(cell)
            return cell
        })
        dataSource?.defaultRowAnimation = .fade
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
    
    func appendElementToSection(todo: Todo, to section: MainTableSections) {
        guard var snapshot = dataSource?.snapshot() else { return }
        if snapshot.numberOfSections == 0 { snapshot.appendSections([section]) }
        snapshot.appendItems([todo], toSection: section)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func removeExistingElement(todo: Todo) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        snapshot.deleteItems([todo])
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func replaceExistingElementWithUpdated(oldElement: Todo, newElementTodo: Todo) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        snapshot.insertItems([newElementTodo], beforeItem: oldElement)
        snapshot.deleteItems([oldElement])
        dataSource?.apply(snapshot)
    }
    
    func updateColor() { cells.forEach { $0.updateColor() } }
}
