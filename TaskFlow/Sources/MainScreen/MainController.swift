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
    private let mainViewModel = MainViewModel()
    private lazy var mainTableViewDataSource = MainTableDataSource(viewModel: mainViewModel)
    private lazy var mainTableViewDelegate = MainTableDelegate(viewModel: mainViewModel)
    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {        
        mainView.mainTableView.dataSource = mainTableViewDataSource
        mainView.mainTableView.delegate = mainTableViewDelegate
        
        setupDelegateBindings()
        setupDataSourceBindings()
        setupViewBindings()
        setupViewModelObserver()
        setupTableDropDelegates()
    }
    
    private lazy var firstHeaderAction = UIAction { [weak self] _ in
        guard let self else { return }
        
        mainViewModel.handleHeaderButtonTapped(for: .sooner, isHalfScreen: mainTableViewDelegate.firstHeader.isHalfScreen)
        mainTableViewDelegate.firstHeader.isHalfScreen.toggle()
    }
    
    private lazy var secondHeaderAction = UIAction { [weak self] _ in
        guard let self else { return }
        
        mainViewModel.handleHeaderButtonTapped(for: .later, isHalfScreen: mainTableViewDelegate.secondHeader.isHalfScreen)
        mainTableViewDelegate.secondHeader.isHalfScreen.toggle()
    }
    
    private func setupDelegateBindings() {
        
        mainTableViewDelegate.reloadTable = { [weak self] in
            self?.mainView.updateMainTableView()
        }
        
        mainTableViewDelegate.firstHeader.addActionToUpOrDownButton(firstHeaderAction)
        mainTableViewDelegate.secondHeader.addActionToUpOrDownButton(secondHeaderAction)
        
        mainTableViewDelegate.sendCreatedTodoToController = { [weak self] todo in
            self?.mainTableViewDataSource.soonerTodos.append(todo)
            self?.mainTableViewDataSource.updateDragTableDelegateData()
        }
    }
    
    private func setupViewBindings() {
        
        mainView.changeView = { [weak self] in
            self?.mainTableViewDelegate.firstHeader.changeUpperView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self?.mainTableViewDelegate.firstHeader.createTodoField.becomeFirstResponder()
                self?.mainTableViewDelegate.currentState = .addingTask
            }
        }
        
        mainView.getViewBack = { [weak self] in
            self?.mainTableViewDelegate.firstHeader.getBackUpperView()
        }
    }
    
    private func setupDataSourceBindings() {
        
        mainTableViewDataSource.updateUpperHeaderTodoCount = { [weak self] value in
            self?.mainTableViewDelegate.firstHeader.setUpdatedTodosCount(value)
        }
        
        mainTableViewDataSource.updateLowerHeaderTodoCount = { [weak self] value in
            self?.mainTableViewDelegate.secondHeader.setUpdatedTodosCount(value)
        }
    }
    
    private func setupViewModelObserver() {
        
        mainViewModel.setupObserver { [weak mainView] keyboardFrame in
            mainView?.raiseToolbar(keyboardFrame.height)
        } onHideKeyboard: { [weak mainView] in
             mainView?.hideToolbar()
        }
    }
    
    private func setupTableDropDelegates() {
        
        mainTableViewDataSource.soonerSectionDragDropDelegate.bindUpdatedDataToDelegate = { [weak self] todos in
            self?.mainTableViewDataSource.soonerTodos = todos
        }
        mainTableViewDataSource.laterSectionDragDropDelegate.bindUpdatedDataToDelegate = { [weak self] todos in
            self?.mainTableViewDataSource.laterTodos = todos
        }
    }
}
