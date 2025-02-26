//
//  MainTableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainTableDataSource: NSObject, UITableViewDataSource {
    
    private var mainViewModel: MainViewModel!
    
    private(set) var soonerCell: MainTableViewCell!
    private(set) var laterCell: MainTableViewCell!
    private(set) var soonerSectionDataSource = TodoTableDiffableDataSource()
    private(set) var laterSectionDataSource = TodoTableDiffableDataSource()
    private(set) lazy var soonerSectionDragDropDelegate: DragAndDropDelegate = {
        DragAndDropDelegate(data: mainViewModel.getTodos(in: .sooner))
    }()
    private(set) lazy var laterSectionDragDropDelegate: DragAndDropDelegate = {
        DragAndDropDelegate(data: mainViewModel.getTodos(in: .later))
    }()
    
    init(viewModel mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        switch indexPath.section {
        case 0:
            soonerCell = cell
            setupDragDropTableDelegates(section: .later)
            configureCell(section: .sooner)
        case 1:
            laterCell = cell
            setupDragDropTableDelegates(section: .sooner)
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
    
    private func setupDragDropTableDelegates(section: MainTableSections) {
        
        let currentCell = (section == .sooner) ? soonerCell : laterCell
        let currentSectionDragDropDelegate = (section == .sooner) ? soonerSectionDragDropDelegate
                                                                  : laterSectionDragDropDelegate
        currentCell?.tasksTable.dropDelegate = currentSectionDragDropDelegate
        currentCell?.tasksTable.dragDelegate = currentSectionDragDropDelegate
    }
    
    private func configureCell(section: MainTableSections) {

        let cell = getCurrentCell(in: section)
        let todos = mainViewModel.getTodos(in: section)
        let dataSource = (section == .sooner) ? soonerSectionDataSource
                                              : laterSectionDataSource
        
        dataSource.setupDataSource(table: cell.tasksTable, todos: todos)
        dataSource.bindIdToDataSource = { [weak self] id in
            self?.moveTodo(from: section, with: id)
        }
        dataSource.bindFinishingToDataSource = { [weak self] id in
            self?.mainViewModel.removeAndFinishTodo(from: section, with: id)
        }
    }
    
    private func getCurrentCell(in section: MainTableSections) -> MainTableViewCell {
        (section == .sooner) ? soonerCell : laterCell
    }
    
    private func moveTodo(from section: MainTableSections, with id: UUID) {
        
        mainViewModel.changeSection(from: section, with: id)
        updateDragTableDelegateData()
    }
}

