//
//  MainTableViewCell.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    private lazy var tasksTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemGray6
        table.layer.cornerRadius = Constants.paddingSmall.value
        table.delegate = self
        return table
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        addSubview(tasksTable)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tasksTable.topAnchor.constraint(equalTo: self.topAnchor),
            tasksTable.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tasksTable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.paddingSmall.value),
            tasksTable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.paddingSmall.value),
        ])
    }
}

extension MainTableViewCell {
    
    static var identifier: String {
        "\(self)"
    }
}

extension MainTableViewCell: UITableViewDelegate {
    
}
