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
        
        setupNotification()
    }
    
    deinit {
        mainViewModel.saveDataOnScreenDisappearing()
        mainViewModel.updateUserDefaultsWithTableState()
        
        deleteNotification()
    }
    
    
    override func viewDidAppear(_ animated: Bool) { mainViewModel.updateBothViewData() }
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
        mainView.addActionToSettingsButton(presentSettingsScreen())
        mainView.addActionToChartsButton(presentArchiveScreen())
    }
    
    func setupViewModelBindings() {
        
        mainViewModel.updateBackground = { [weak self] section in guard let self else { return }
            mainTableViewDataSource.checkTableBackground(section, mainViewModel.getTodos(in: section))
        }
        
        mainViewModel.updateCounter = { [weak self] section in
            self?.mainTableViewDelegate.updateHeaderCount(in: section)
        }
        
        mainViewModel.tableStateOnChange = { [weak self] in
            if self?.mainViewModel.tableState != .addingTask { FeedBackService.occurreVibration(style: .light) }
            self?.mainView.updateTable()
        }
        
        mainViewModel.onDragDelegateUpdate = { [weak self] section in
            self?.mainTableViewDataSource.updateDragDropDelegateIn(section: section)
        }
        
        mainViewModel.updateDisplayingCells = { [weak self] indexPath, section in guard let self = self else { return }
            if section == .sooner {
                mainTableViewDataSource.soonerCell.tasksTable.scrollToRow(at: indexPath, at: .top, animated: true)
            } else {
                mainTableViewDataSource.laterCell.tasksTable.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func setupViewModelObserver() {
        
        mainViewModel.setupObserver { [weak mainView] keyboardFrame in
            FeedBackService.occurreVibration(style: .light)
            mainView?.raiseToolbar(keyboardFrame.height)
            mainView?.enableOrDisableAllToolbardButtons(shouldEnable: false)
        } onHideKeyboard: { [weak mainView] in
            mainView?.hideToolbar()
            mainView?.enableOrDisableAllToolbardButtons(shouldEnable: true)
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
    
    func presentSettingsScreen() -> UIAction {
        UIAction { [weak self] _ in guard let self else { return }
            let transitionDelegate = SPLarkTransitioningDelegate()
            let settingsController = SettingsController(settingsViewModel: SettingsViewModel())
            transitionDelegate.customHeight = UIScreen.main.bounds.height / 10
            settingsController.transitioningDelegate = transitionDelegate
            settingsController.modalPresentationStyle = .custom
            settingsController.modalPresentationCapturesStatusBarAppearance = true
            present(settingsController, animated: true)
        }
    }
    
    func presentArchiveScreen() -> UIAction {
        UIAction { [weak self] _ in
            guard let self else { return }
            let statisticViewModel = StatisticViewModel(
                todoService: mainViewModel.todoService,
                onTodoRestoringCompletion: { [weak self] todo, shouldRestore in
                    self?.restoreTodo(todo, shouldRestore: shouldRestore)
                }
            )
            statisticViewModel.onUpdateViewModelData = { [weak self] todo in
                self?.mainViewModel.finishedTodos.removeAll(where: { $0.id == todo.id })
            }
            let statisticController = StatisticController(statsticViewModel: statisticViewModel)
            let statisticNavigationController = UINavigationController(rootViewController: statisticController)
            statisticNavigationController.modalPresentationStyle = .formSheet
            present(statisticNavigationController, animated: true)
        }
    }
    
    func restoreTodo(_ todo: Todo, shouldRestore: Bool) {
        mainViewModel.restoreTodo(todo: todo, shouldRestore: shouldRestore)
        
        if shouldRestore {
            self.appendTodoDueToSection(todo: todo)
        } else {
            if todo.section == .sooner {
                mainViewModel.soonerTodos.removeAll {
                    $0.id == todo.id
                }
            } else {
                mainViewModel.laterTodos.removeAll {
                    $0.id == todo.id
                }
            }
        }
    }
    
    func appendTodoDueToSection(todo: Todo) {
        if todo.section == .sooner {
            mainTableViewDataSource.soonerSectionDataSource.appendElementToSection(todo: todo, to: .sooner)
        } else {
            mainTableViewDataSource.laterSectionDataSource.appendElementToSection(todo: todo, to: .later)
        }
    }
    
    // MARK: Notification methods
    func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(colorUpdateNotification(_:)),
            name: Notification.Name(NotificationName.updateAccentColorNotification.getName),
            object: nil)
    }
    
    @objc func colorUpdateNotification(_ notification: NSNotification) {
        guard let updatedColor = notification.userInfo?[NotificationName.updateAccentColorKey.getName] as? UIColor
        else { return }
        mainView.updateBackgroundColor(updatedColor: updatedColor)
        mainTableViewDelegate.updateHeadersBackgroundColor(updatedColor: updatedColor)
        mainTableViewDataSource.updateCellsColor(updatedColor: updatedColor)
    }
    
    func deleteNotification() {
        NotificationCenter.default.removeObserver(self)
    }
}
