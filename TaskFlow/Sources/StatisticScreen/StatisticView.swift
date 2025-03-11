//
//  StatisticView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 07.03.2025.
//

import UIKit

final class StatisticView: UIView {
    
    private var statisticViewModel: StatisticViewModel
    
    var presentTodoInfoScreen: ((Todo) -> Void)?
    
    private(set) lazy var finishedTodosTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TodoTableViewCell.self, forCellReuseIdentifier: TodoTableViewCell.identifier)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = TodoCellSize.default.value
        table.separatorStyle = .none
        table.backgroundColor = .systemGray6
        table.rowHeight = TodoCellSize.default.value
        table.backgroundColor = .systemGray6
        table.layer.cornerRadius = Constants.paddingSmall.value + 5
        table.contentInset = UIEdgeInsets(top: Constants.paddingTiny.value, left: 0, bottom: Constants.paddingTiny.value, right: 0)
        return table
    }()
    
    init(viewModel: StatisticViewModel) {
        self.statisticViewModel = viewModel
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatisticView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { statisticViewModel.getNumberOfSections() }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        statisticViewModel.getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier) as! TodoTableViewCell
        let todo = statisticViewModel.getTodo(at: indexPath)
        cell.configureWithTodo(todo, isActive: false)
        cell.setDelegateToScrollView(scrollViewDelegate: TodoScrollViewDelegate(
            with: todo,
            onTodoComplete: { self.statisticViewModel.onTodoRestore(todo: $0, shouldRestore: true) },
            onUIupdate: { cell.onUIUpdate(value: $0, isActive: false) },
            isActive: false))
        cell.showTodoInfo = { [weak self] todo in
            self?.presentTodoInfoScreen?(todo)
        }
        return cell
    }
    
    func deleteRowAt(indexPath: IndexPath) {
        finishedTodosTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func insertRowAt(indexPath: IndexPath) {
        finishedTodosTableView.insertRows(at: [indexPath], with: .fade)
    }
}


private extension StatisticView {
    
    func setup() {
        self.backgroundColor = .systemBackground
        setupSubviews()
        setupLayout()
    }
    
    func setupSubviews() {
        addSubview(finishedTodosTableView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            finishedTodosTableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Constants.paddingSmall.value),
            finishedTodosTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.paddingTiny.value),
            finishedTodosTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.paddingTiny.value),
            finishedTodosTableView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.75)
        ])
    }
}
