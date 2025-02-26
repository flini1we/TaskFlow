//
//  ViewController.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainController: UIViewController {
    
    private var mainView: MainView {
        view as! MainView
    }
    private var mainViewModel: MainViewModel!
    
    private lazy var mainTableViewDataSource = MainTableDataSource(viewModel: mainViewModel)
    private lazy var mainTableViewDelegate = MainTableDelegate(viewModel: mainViewModel)
    
    override func loadView() {
        view = MainView()
    }
    
    init(viewModel: MainViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.mainViewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        mainView.mainTableView.dataSource = mainTableViewDataSource
        mainView.mainTableView.delegate = mainTableViewDelegate
        
        setupDelegateBindings()
        setupViewBindings()
        setupViewModelBindings()
        setupTableDragDropDelegates()
        setupViewModelObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mainViewModel.updateBothViewData()
    }
    
    private func setupDelegateBindings() {
        
        mainTableViewDelegate.reloadTable = { [weak self] in
            self?.mainView.updateTable()
        }
        
        mainTableViewDelegate.reloadHeaders = { [weak self] in
            self?.mainView.reloadHeaders()
        }
        
        mainTableViewDelegate.sendCreatedTodoToController = { [weak self] todo in
            self?.mainViewModel.soonerTodos.append(todo)
            self?.mainTableViewDataSource.updateDragTableDelegateData()
        }
    }
    
    private func setupViewBindings() {
        
        mainView.changeView = { [weak self] in
            self?.updateState(state: .addingTask)
        }
        
        mainView.getViewBack = { [weak self] in
            self?.updateState(state: .default)
        }
    }
    
    private func setupViewModelBindings() {
        
        mainViewModel.updateBackground = { [weak self] section in guard let self else { return }
            mainTableViewDataSource.checkTableBackground(section, mainViewModel.getTodos(in: section))
        }
        
        mainViewModel.updateTodos = { [weak self] section, todos in guard let self else { return }
            let currentDataSource = (section == .sooner) ? mainTableViewDataSource.soonerSectionDataSource
                                                         : mainTableViewDataSource.laterSectionDataSource
            currentDataSource.confirmSnapshot(todos: todos, animation: true)
        }
        
        mainViewModel.updateCounter = { [weak self] section in guard let self else { return }
            let headerToUpdate = (section == .sooner) ? mainTableViewDelegate.soonerSectionHeader : mainTableViewDelegate.laterSectionHeader
            headerToUpdate.setUpdatedTodosCount(mainViewModel.getTodos(in: section).count)
        }
    }
    
    private func setupTableDragDropDelegates() {
        
        mainTableViewDataSource.soonerSectionDragDropDelegate.bindUpdatedDataToDelegate = { [weak self] todos in
            self?.mainViewModel.soonerTodos = todos
        }
        mainTableViewDataSource.laterSectionDragDropDelegate.bindUpdatedDataToDelegate = { [weak self] todos in
            self?.mainViewModel.laterTodos = todos
        }
    }
    
    private func setupViewModelObserver() {
        
        mainViewModel.setupObserver { [weak mainView] keyboardFrame in
            mainView?.raiseToolbar(keyboardFrame.height)
        } onHideKeyboard: { [weak mainView] in
             mainView?.hideToolbar()
        }
    }
    
    fileprivate func updateState(state: TableState) {
        
        mainTableViewDelegate.currentState = state
        mainView.reloadHeaders()
    }
}
