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
    private lazy var mainTableViewDelegate = MainTableDelegate()
    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        mainView.mainTableView.dataSource = mainTableViewDataSource
        mainView.mainTableView.delegate = mainTableViewDelegate
        mainTableViewDelegate.reloadTalbe = { [weak self] in
            self?.mainView.updateMainTableView()
        }
        mainViewModel.changeLowerButton = { [weak self] in
            self?.mainTableViewDelegate.updateLowerButton()
        }
        mainViewModel.changeUpperButton = { [weak self] in
            self?.mainTableViewDelegate.updateUpperButton()
        }
        mainViewModel.tableStateOnChange = { [weak self] updatedState in
            self?.mainTableViewDelegate.currentState = updatedState
        }
        
        mainTableViewDelegate.firstHeader.onButtonTapped = { [weak self] isHalfScreen in
            self?.mainViewModel.handleHeaderButtonTapped(for: MainTableSections.sooner, isHalfScreen: isHalfScreen)
        }
        mainTableViewDelegate.secondHeader.onButtonTapped = { [weak self] isHalfScreen in
            self?.mainViewModel.handleHeaderButtonTapped(for: MainTableSections.later, isHalfScreen: isHalfScreen)
        }
        
        mainView.changeView = { [weak self] in
            self?.mainTableViewDelegate.firstHeader.changeUpperView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self?.mainTableViewDelegate.firstHeader.createTodoField.becomeFirstResponder()
                self?.mainTableViewDelegate.currentState = .addingTask
            }
        }
    }
}
