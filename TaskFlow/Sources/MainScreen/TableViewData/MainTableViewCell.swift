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
        let placeHolderLabel = UILabel()
        placeHolderLabel.text = "Nothing to do, good job!"
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeHolderLabel.textColor = .systemGray
        placeHolderLabel.font = .systemFont(ofSize: Fonts.default.value)
        table.addSubview(placeHolderLabel)
        NSLayoutConstraint.activate([
            placeHolderLabel.centerXAnchor.constraint(equalTo: table.centerXAnchor),
            placeHolderLabel.centerYAnchor.constraint(equalTo: table.centerYAnchor),
        ])
        table.backgroundView = placeHolderLabel
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemGray6
        table.layer.cornerRadius = Constants.paddingSmall.value
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.register(TodoTableViewCell.self, forCellReuseIdentifier: TodoTableViewCell.identifier)
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
        contentView.addSubview(tasksTable)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tasksTable.heightAnchor.constraint(equalTo: self.heightAnchor),
            tasksTable.topAnchor.constraint(equalTo: contentView.topAnchor),
            tasksTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingSmall.value),
            tasksTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingSmall.value),
        ])
    }
}

extension MainTableViewCell: UITableViewDelegate {
    
    static var identifier: String {
        "\(self)"
    }
}
