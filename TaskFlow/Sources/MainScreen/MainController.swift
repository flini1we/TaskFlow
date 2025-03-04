//
//  ViewController.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit
import SPLarkController

final class MainController: UIViewController {
    
    private var mainView: MainView { view as! MainView }
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
        setupViewData()
        
        setupDelegateBindings()
        setupViewModelBindings()
        setupViewModelObserver()
        setupViewActions()
    }
    
    override func viewDidAppear(_ animated: Bool) { mainViewModel.updateBothViewData() }
    
    override func viewDidDisappear(_ animated: Bool) { mainViewModel.saveDataOnScreenDisappearing() }
}

// MARK: ColorUpdatable protocol extension
extension MainController: ColorUpdatable {
    
    func updateBackgroundColor() {
        
        mainView.updateBackgroundColor()
        mainTableViewDelegate.updateHeadersBackgroundColor()
        mainTableViewDataSource.updateCellsColor()
    }
}

// MARK: Private methods
private extension MainController {
    
    func setupViewData() {
        mainView.mainTableView.dataSource = mainTableViewDataSource
        mainView.mainTableView.delegate = mainTableViewDelegate
    }
    
    func setupDelegateBindings() {
        
        mainTableViewDelegate.reloadHeaders = { [weak self] in
            self?.mainView.reloadHeaders()
        }
        
        mainTableViewDelegate.onTodoCreate = { [weak self] todo in
            self?.mainViewModel.soonerTodos.append(todo)
            self?.mainTableViewDataSource.soonerSectionDataSource.appendElementToSection(todo: todo, to: .sooner)
            self?.mainTableViewDataSource.updateDragTableDelegateData()
        }
    }
    
    func setupViewActions() {
        
        mainView.addActionToAddTodoButton(configureActionToAddTodoOrHideKeyboardButton(state: .addingTask))
        mainView.addActionToHideKeyboardButton(configureActionToAddTodoOrHideKeyboardButton(state: .default))
        mainView.addActionToSettingsButton(goToSettingsScreenAction())
    }
    
    func setupViewModelBindings() {
        
        mainViewModel.updateBackground = { [weak self] section in guard let self else { return }
            mainTableViewDataSource.checkTableBackground(section, mainViewModel.getTodos(in: section))
        }
        
        mainViewModel.updateCounter = { [weak self] section in
            self?.mainTableViewDelegate.updateHeaderCount(in: section)
        }
        
        mainViewModel.tableStateOnChange = { [weak self] in
            FeedBackService.occurreVibration(style: .light)
            self?.mainView.updateTable()
        }
    }
    
    func setupViewModelObserver() {
        
        mainViewModel.setupObserver { [weak mainView] keyboardFrame in
            mainView?.raiseToolbar(keyboardFrame.height)
        } onHideKeyboard: { [weak mainView] in
             mainView?.hideToolbar()
        }
    }
    
    func configureActionToAddTodoOrHideKeyboardButton(state: TableState) -> UIAction {
        UIAction { [weak self] _ in
            self?.updateState(state: state)
        }
    }
    
    func updateState(state: TableState) {
        if state == .default {
            mainView.endEditing(true)
        }
        mainViewModel.tableState = state
        
        mainViewModel.reloadButtonImage?(.later)
        mainViewModel.reloadButtonImage?(.sooner)
        
        mainView.reloadHeaders()
        mainViewModel.updateBackground?(.sooner)
    }
    
    func goToSettingsScreenAction() -> UIAction {
        UIAction { [weak self] _ in
            let settingsController = SettingsController(settingsViewModel: SettingsViewModel())
            let transitionDelegate = SPLarkTransitioningDelegate()
            
            transitionDelegate.customHeight = UIScreen.main.bounds.height / 10
            settingsController.transitioningDelegate = transitionDelegate
            settingsController.modalPresentationStyle = .custom
            settingsController.modalPresentationCapturesStatusBarAppearance = true
            self?.present(settingsController, animated: true)
        }
    }
}
