//
//  StatisticController.swift
//  TaskFlow
//
//  Created by Данил Забинский on 07.03.2025.
//

import UIKit

final class StatisticController: UIViewController {
    
    private var statisticView: StatisticView {
        view as! StatisticView
    }
    
    private var statisticViewModel: StatisticViewModel
    
    init(statsticViewModel: StatisticViewModel) {
        self.statisticViewModel = statsticViewModel
        super.init(nibName: nil, bundle: nil)
        
        statisticView.presentTodoInfoScreen = { todo in
            let todoDetailScreen = TodoDetailController(statisticViewModel: self.statisticViewModel)
            todoDetailScreen.setupWithTodo(todo)
            todoDetailScreen.modalPresentationStyle = .custom
            todoDetailScreen.modalTransitionStyle = .coverVertical
            
            self.present(todoDetailScreen, animated: true)
        }
        
        statisticViewModel.onContentWillChange = { [weak self] in
            self?.statisticView.finishedTodosTableView.beginUpdates()
        }
        
        statisticViewModel.onContentDidChange = { [weak self] in
            self?.statisticView.finishedTodosTableView.endUpdates()
        }
        
        statisticViewModel.onDeletingRowAt = { [weak self] indexPath in
            self?.statisticView.deleteRowAt(indexPath: indexPath)
        }
        
        statisticViewModel.onInsertingRowAt = { [weak self] indexPath in
            self?.statisticView.insertRowAt(indexPath: indexPath)
        }
        
        statsticViewModel.onUpdateTableHeight = { [weak self] updatedHeight in
            self?.statisticView.updateHeight(value: updatedHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = StatisticView(
            viewModel: statisticViewModel,
            initialTableHeight: (TodoCellSize.default.value + 2.5) * CGFloat(statisticViewModel.finishedData.count)
        )
    }
    
    override func viewDidLoad() {
        setupNabigationBar()
        setupNavigationBarButtonItems()
    }
}

private extension StatisticController {
    
    func setupNabigationBar() {
        
        let titleLabel = UILabel()
        titleLabel.textColor = SelectedColor.backgroundColor
        titleLabel.font = .boldSystemFont(ofSize: Fonts.default.value)
        titleLabel.text = "Archive"
        navigationItem.titleView = titleLabel
    }
    
    func setupNavigationBarButtonItems() {
        
        let closeBarButtonItem = UIBarButtonItem(
            title: "Close",
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        closeBarButtonItem.tintColor = SelectedColor.backgroundColor
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }
}
