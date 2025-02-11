//
//  TodoTableViewCell.swift
//  TaskFlow
//
//  Created by Данил Забинский on 09.02.2025.
//

import UIKit

class TodoTableViewCell: UITableViewCell {
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.paddingSmall.value
        return view
    }()
    
    private lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithTodo(_ todo: Int) {
        todoLabel.text = "\(todo)"
    }
    
    private func setupData() {
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        self.selectionStyle = .none
        backgroundColor = .systemGray6
        contentView.addSubview(bgView)
        bgView.addSubview(todoLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingSmall.value / 2),
            bgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingSmall.value / 2),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingSmall.value / 2),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingSmall.value / 4),
        ])
        
        NSLayoutConstraint.activate([
            todoLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: Constants.paddingSmall.value / 2),
            todoLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Constants.paddingSmall.value / 2),
            todoLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Constants.paddingSmall.value / 2),
            todoLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -Constants.paddingSmall.value / 2),
        ])
    }
}

extension TodoTableViewCell {
    
    static var identifier: String {
        "\(self)"
    }
}
