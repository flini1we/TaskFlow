//
//  MainTableHeaderView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainTableHeaderView: UIView {
    
    private var isHalfScreen = true
    var onButtonTapped: ((Bool) -> Void)?
    
    private lazy var titleImage: UIImageView = {
        let image = UIImageView()
        image.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        image.tintColor = .label
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: Fonts.title.value)
        return label
    }()
    
    private lazy var firstDataStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleImage,
            titleLabel
        ])
        
        stack.axis = .horizontal
        stack.spacing = Constants.paddingSmall.value
        stack.alignment = .center
        return stack
    }()
    
    private lazy var tasksCount: TaskCounterView = {
        let counter = TaskCounterView()
        counter.translatesAutoresizingMaskIntoConstraints = false
        return counter
    }()
    
    private lazy var upOrDownButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.and.line.horizontal.and.arrow.down"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        return button
    }()
    
    private lazy var secondDataStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            tasksCount,
            upOrDownButton,
        ])
        stack.distribution = .fillEqually
        stack.spacing = Constants.paddingSmall.value
        stack.alignment = .center
        return stack
    }()
    
    private lazy var dataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            firstDataStack,
            secondDataStack
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        return stack
    }()
    
    init(in section: MainTableSections) {
        super.init(frame: .zero)
        setupUI()
        
        switch section {
        case .sooner:
            titleLabel.text = "Sooner"
            titleImage.image = UIImage(systemName: "note.text")
        case .later:
            titleLabel.text = "Later"
            titleImage.image = UIImage(systemName: "note")
        }
        
        upOrDownButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onButtonTapped?(isHalfScreen)
            isHalfScreen.toggle()
        }, for: .touchUpInside)
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
        addSubview(dataStackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            dataStackView.heightAnchor.constraint(equalToConstant: HeaderSize.default.value),
            dataStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dataStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.paddingMedium.value),
            dataStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.paddingMedium.value),
        ])
    }
}
