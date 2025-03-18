//
//  TodoDetailController.swift
//  TaskFlow
//
//  Created by Данил Забинский on 11.03.2025.
//

import UIKit

final class TodoDetailController: UIViewController {
    
    private var todoDetailView: TodoDetailView {
        view as! TodoDetailView
    }
    private var statisticViewModel: StatisticViewModel
    
    init(statisticViewModel: StatisticViewModel) {
        self.statisticViewModel = statisticViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = TodoDetailView()
    }
    
    override func viewDidLoad() {
        transitioningDelegate = self
        
        todoDetailView.dismissButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }, for: .touchUpInside)
    }
    
    func setupWithTodo(_ todo: Todo) {
        todoDetailView.setupWithTodo(todo)
        
        todoDetailView.deleteTodoButton.addAction(UIAction { [weak self] _ in
            FeedBackService.occurreVibration(style: .light)
            self?.statisticViewModel.onTodoRestore(todo: todo, shouldRestore: false)
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
    }
}

// MARK: Conforming UIViewControllerTransitioningDelegate protocol
extension TodoDetailController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let customPresentationController = CustomHeightPresentationController(presentedViewController: presented, presenting: presenting)
        customPresentationController.dismissView = { [weak self] in self?.dismiss(animated: true) }
        return customPresentationController
    }
}
