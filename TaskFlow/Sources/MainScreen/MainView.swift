//
//  MainView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainView: UIView {
    
    lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        table.isScrollEnabled = false
        table.sectionHeaderTopPadding = 0 // отступ от хедера
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        backgroundColor = .systemBackground
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        addSubview(mainTableView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
