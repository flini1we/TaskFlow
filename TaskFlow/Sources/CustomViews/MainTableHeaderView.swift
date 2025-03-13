//
//  MainTableHeaderView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainTableHeaderView: UIView {
    
    var isHalfScreen: Bool {
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
    
    private lazy var tasksCountView: TaskCounterView = {
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
            tasksCountView,
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
    
    init(in section: MainTableSections, withCurrentState: TableState) {
        switch (section, withCurrentState) {
        case (.sooner, .default), (.later, .default), (.sooner, .addingTask), (.later, .addingTask): isHalfScreen = true
        default: isHalfScreen = false }
        super.init(frame: .zero)
        
        setupButton(in: section, with: withCurrentState)
        setupUI()
        setupData(section)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(updatedColor color: UIColor) {
        UIView.animate(withDuration: 0.5) {
            self.titleImage.alpha = 0
            self.upOrDownButton.alpha = 0 
        } completion: { _ in
            self.titleImage.tintColor = color
            self.upOrDownButton.tintColor = color
            UIView.animate(withDuration: 0.5) {
                self.titleImage.alpha = 1
                self.upOrDownButton.alpha = 1
            }
        }
    }
    
    func setUpdatedTodosCount(_ value: Int) {
        tasksCountView.updateTaskCount(newValue: value)
    }
    
    func addActionToUpOrDownButton(_ action: UIAction) {
        upOrDownButton.addAction(action, for: .touchUpInside)
    }
}

private extension MainTableHeaderView {
    
    func setupButton(in section: MainTableSections, with state: TableState) {
        switch (section, state) {
        case (.sooner, .default), (.later, .default), (.later, .upperOpened), (.sooner, .lowerOpened):
            upOrDownButton.setImage(SystemImages.arrowsUp.image, for: .normal)
        default: upOrDownButton.setImage(SystemImages.arrowsDown.image, for: .normal) }
    }
    
    func animateImage() {
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
    
    func setupData(_ section: MainTableSections) {
        
        switch section {
        case .sooner:
            titleLabel.text = "Sooner"
            titleImage.image = SystemImages.soonerHeader.image
        case .later:
            titleLabel.text = "Later"
            titleImage.image = SystemImages.laterHeader.image
        }
    }
    
    func setupUI() {
        backgroundColor = .systemBackground
        setupSubviews()
        setupLayout()
    }
    
    func setupSubviews() {
        addSubview(mainScrollView)
        mainScrollView.addSubview(dataStackView)
    }
    
    func setupLayout() {
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
