//
//  TaskCounter.swift
//  TaskFlow
//
//  Created by Данил Забинский on 04.02.2025.
//

import UIKit

final class TaskCounterView: UIView {
    
    private lazy var taskCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = SelectedColor.backgroundColor
        label.text = "0"
        label.font = .boldSystemFont(ofSize: Fonts.small.value)
        return label
    }()
    
    private lazy var backgrounView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = Constants.paddingMedium.value / 2
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTaskCount(newValue: Int) { taskCount.text = "\(newValue)" }
    
    private func setupUI() {
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        addSubview(backgrounView)
        backgrounView.addSubview(taskCount)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            backgrounView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgrounView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            backgrounView.heightAnchor.constraint(equalToConstant: Constants.paddingMedium.value),
            backgrounView.widthAnchor.constraint(equalToConstant: Constants.paddingMedium.value),
        ])
        
        NSLayoutConstraint.activate([
            taskCount.centerXAnchor.constraint(equalTo: backgrounView.centerXAnchor),
            taskCount.centerYAnchor.constraint(equalTo: backgrounView.centerYAnchor),
        ])
    }
}
