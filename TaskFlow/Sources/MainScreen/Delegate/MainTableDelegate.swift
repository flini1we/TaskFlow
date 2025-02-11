//
//  MainTableDelegate.swift
//  TaskFlow
//
//  Created by Данил Забинский on 06.02.2025.
//

import UIKit

class MainTableDelegate: NSObject, UITableViewDelegate {
        
    private var mainViewModel: MainViewModel
    private(set) var firstHeader = MainTableHeaderView(in: .sooner)
    private(set) var secondHeader = MainTableHeaderView(in: .later)
    
    var currentState: TableState = .default {
        didSet {
            reloadTable?()
        }
    }
    var reloadTable: (() -> Void)?
    
    var createdTodo: Todo? {
        didSet {
            if let createdTodo {
                sendCreatedTodoToController?(createdTodo)
            }
        }
    }
    var sendCreatedTodoToController: ((Todo) -> Void)?
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return firstHeader
        case 1:
            return secondHeader
        default:
            return nil
        }
    }
    
    init(viewModel: MainViewModel) {
        self.mainViewModel = viewModel
        super.init()
        setupActions()
        setupBindings()
    }
    
    private func setupActions() {
        mainViewModel.changeLowerButton = self.updateLowerButton
        mainViewModel.changeUpperButton = self.updateUpperButton
    }
    
    private func setupBindings() {
        firstHeader.backToDefaultTableViewPosition = { [weak self] in
            self?.currentState = .default
            self?.updateLowerButton()
            self?.updateUpperButton()
        }
        
        mainViewModel.tableStateOnChange = { [weak self] updatedState in
            self?.currentState = updatedState
        }
        
        firstHeader.sendCreatedTodoToDelegate = { [weak self] todo in
            self?.sendCreatedTodoToController?(todo)
        }
    }
    
    func updateLowerButton() {
        if !secondHeader.isHalfScreen {
            secondHeader.isHalfScreen.toggle()
        }
    }
    func updateUpperButton() {
        if !firstHeader.isHalfScreen {
            firstHeader.isHalfScreen.toggle()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        HeaderSize.default.value
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        mainViewModel.calculateCellsHeight(at: indexPath, withState: currentState)
    }
}
