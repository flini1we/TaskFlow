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
    private lazy var mainTableViewDataSource = MainTableDataSource(data: [])
    
    override func loadView() {
        view = MainView()
    }

    override func viewDidLoad() {
        mainView.mainTableView.dataSource = mainTableViewDataSource
    }
}
