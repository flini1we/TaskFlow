//
//  ViewController.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainController: UIViewController {
    
    private var mainView: MainView {
        view as! MainView
    }
    private let mainViewModel = MainViewModel()
    private lazy var mainTableViewDataSource = MainTableDataSource()
    private lazy var mainTableViewDelegate = MainTableDelegate(viewModel: mainViewModel)
    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {        
        mainView.mainTableView.dataSource = mainTableViewDataSource
        mainView.mainTableView.delegate = mainTableViewDelegate
        
        setupDelegateBindings()
        setupViewBindings()
        setupViewModelObserver()
    }
    
    private func setupDelegateBindings() {
        
        mainTableViewDelegate.reloadTable = { [weak self] in
            self?.mainView.updateMainTableView()
        }
        
        mainTableViewDelegate.firstHeader.onButtonTapped = { [weak self] isHalfScreen in
            self?.mainViewModel.handleHeaderButtonTapped(for: .sooner, isHalfScreen: isHalfScreen)
            self?.mainTableViewDelegate.firstHeader.isHalfScreen.toggle()
        }
        mainTableViewDelegate.secondHeader.onButtonTapped = { [weak self] isHalfScreen in
            self?.mainViewModel.handleHeaderButtonTapped(for: .later, isHalfScreen: isHalfScreen)
            self?.mainTableViewDelegate.secondHeader.isHalfScreen.toggle()
        }
        
        mainTableViewDelegate.sendCreatedTodoToController = { [weak self] todo in
            print(todo.title)
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
    
    private func setupViewModelObserver() {
        
        mainViewModel.setupObserver { [weak mainView] keyboardFrame in
            mainView?.raiseToolbar(keyboardFrame.height)
        } onHideKeyboard: { [weak mainView] in
             mainView?.lowerToolbar()
        }
    }
}
