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
        
        mainViewModel.tableStateOnChange = { [weak self] updatedState in
            guard let self else { return }
            mainTableViewDelegate.currentState = updatedState
            mainView.mainTableView.beginUpdates()
            mainView.mainTableView.endUpdates()
        }
        
        mainTableViewDelegate.firstHeader.onButtonTapped = { [weak self] isHalfScreen in
            guard let self else { return }
            mainViewModel.handleHeaderButtonTapped(for: MainTableSections.sooner, isHalfScreen: isHalfScreen)
        }
        
        mainTableViewDelegate.secondHeader.onButtonTapped = { [weak self] isHalfScreen in
            guard let self else { return }
            mainViewModel.handleHeaderButtonTapped(for: MainTableSections.later, isHalfScreen: isHalfScreen)
        }
        
        
       
//        navigationController?.setToolbarHidden(false, animated: false)
    }
}
