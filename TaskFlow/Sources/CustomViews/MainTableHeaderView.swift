//
//  MainTableHeaderView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainTableHeaderView: UIView {
    
    var isHalfScreen = true {
        didSet {
            animateImage()
        }
    }
    var changeTodosCount: ((Int) -> Void)?
    
    lazy var mainScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.backgroundColor = .systemBackground
        return scroll
    }()
    
    private lazy var titleImage: UIImageView = {
        let image = UIImageView()
        image.tintColor = SelectedColor.backgroundColor
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: Fonts.default.value)
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
        TaskCounterView()
    }()
    
    private lazy var upOrDownButton: UIButton = {
        let button = UIButton()
        button.tintColor = SelectedColor.backgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
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
        setupButton()
        setupData(section)
    }
    
    func setUpdatedTodosCount(_ value: Int) {
        tasksCount.updateTaskCount(newValue: value)
    }
    
    private func animateImage() {
        UIView.animate(withDuration: 0.1) {
            self.upOrDownButton.transform = CGAffineTransform(rotationAngle: .pi)
        } completion: { _ in
            let image = self.isHalfScreen ? SystemImages.arrowsUp.image : SystemImages.arrowsDown.image
            self.upOrDownButton.setImage(image, for: .normal)
            UIView.animate(withDuration: 0.1) {
                self.upOrDownButton.transform = .identity
            }
        }
    }
    
    private func setupData(_ section: MainTableSections) {
        
        switch section {
        case .sooner:
            titleLabel.text = "Sooner"
            titleImage.image = SystemImages.soonerHeader.image
        case .later:
            titleLabel.text = "Later"
            titleImage.image = SystemImages.laterHeader.image
        }
    }
    
    private func setupButton() { upOrDownButton.setImage(SystemImages.arrowsUp.image, for: .normal) }
    
    func addActionToUpOrDownButton(_ action: UIAction) {
        upOrDownButton.addAction(action, for: .touchUpInside)
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
        addSubview(mainScrollView)
        mainScrollView.addSubview(dataStackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            mainScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainScrollView.topAnchor.constraint(equalTo: self.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            dataStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, multiplier: 0.875),
            dataStackView.centerYAnchor.constraint(equalTo: mainScrollView.centerYAnchor),
            dataStackView.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor),
        ])
    }
}
