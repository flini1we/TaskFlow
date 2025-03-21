//
//  StatisticView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 07.03.2025.
//

import UIKit
import SwiftUI

final class StatisticView: UIView {
    
    private var statisticViewModel: StatisticViewModel
    
    var presentTodoInfoScreen: ((Todo) -> Void)?
    private var tableHeightAnchor: NSLayoutConstraint!
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private lazy var chartsSwiftUIView: UIHostingController<TodoCharts> = {
        let hostingController = UIHostingController(
            rootView: TodoCharts(statisticViewModel: self.statisticViewModel)
        )
        return hostingController
    }()
    
    private(set) lazy var finishedTodosTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        table.register(TodoTableViewCell.self, forCellReuseIdentifier: TodoTableViewCell.identifier)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = TodoCellSize.default.value
        table.separatorStyle = .none
        table.backgroundColor = .secondarySystemBackground
        table.layer.cornerRadius = Constants.paddingSmall.value + 5
        table.contentInset = UIEdgeInsets(top: Constants.paddingTiny.value, left: 0, bottom: Constants.paddingTiny.value, right: 0)
        return table
    }()
    
    private lazy var dataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            chartsSwiftUIView.view,
            finishedTodosTableView
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    init(viewModel: StatisticViewModel) {
        self.statisticViewModel = viewModel
        super.init(frame: .zero)
        setup(initialTableHeight: statisticViewModel.getHeight())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHeight(value: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.tableHeightAnchor.constant = value
        }
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
    
    func setup(initialTableHeight: CGFloat) {
        self.backgroundColor = .systemBackground
        setupSubviews()
        setupLayout(initialTableHeight: initialTableHeight)
    }
    
    func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(dataStackView)
    }
    
    func setupLayout(initialTableHeight: CGFloat) {
        tableHeightAnchor = finishedTodosTableView.heightAnchor.constraint(equalToConstant: initialTableHeight)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dataStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.paddingSmall.value),
            dataStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dataStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.95),
            tableHeightAnchor,
            dataStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}
