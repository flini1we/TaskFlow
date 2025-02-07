//
//  MainTableHeaderView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainTableHeaderView: UIView {
    
    private var buttonAction: UIAction!
    private enum SwipeDirection: Int {
        case up, down
    }
    
    private var isHalfScreen = true {
        didSet {
            if isHalfScreen {
                UIView.animate(withDuration: 0.1) {
                    self.upOrDownButton.transform = CGAffineTransform(rotationAngle: .pi)
                } completion: { _ in
                    self.upOrDownButton.setImage(SystemImages.arrowsUp.image, for: .normal)
                    UIView.animate(withDuration: 0.1) {
                        self.upOrDownButton.transform = .identity
                        self.upOrDownButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                    }
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.upOrDownButton.transform = CGAffineTransform(rotationAngle: .pi)
                } completion: { _ in
                    self.upOrDownButton.setImage(SystemImages.arrowsDown.image, for: .normal)
                    UIView.animate(withDuration: 0.1) {
                        self.upOrDownButton.transform = .identity
                        self.upOrDownButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                    }
                }
            }
        }
    }
    
    var onButtonTapped: ((Bool) -> Void)?
    
    private lazy var titleImage: UIImageView = {
        let image = UIImageView()
        image.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        image.tintColor = SelectedColor.backgroundColor
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
        button.tintColor = SelectedColor.backgroundColor
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
        
        buttonAction = UIAction { [weak self] _ in
            guard let self else { return }
            onButtonTapped?(isHalfScreen)
            isHalfScreen.toggle()
        }
        upOrDownButton.addAction(buttonAction, for: .touchUpInside)
        upOrDownButton.setImage(SystemImages.arrowsUp.image, for: .normal)
        
        switch section {
        case .sooner:
            titleLabel.text = "Sooner"
            titleImage.image = SystemImages.soonerHeader.image
            
            setupGestures(direction: .up)
        case .later:
            titleLabel.text = "Later"
            titleImage.image = SystemImages.laterHeader.image
            
            setupGestures(direction: .down)
        }
    }
    
    private func setupGestures(direction: SwipeDirection) {
        if direction == .up {
            let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleUpperHeaderGesture(_:)))
            let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleUpperHeaderGesture(_:)))
            
            downSwipeGesture.direction = .down
            upSwipeGesture.direction = .up
            
            self.addGestureRecognizer(downSwipeGesture)
            self.addGestureRecognizer(upSwipeGesture)
        } else {
            let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLowerHeaderGesture(_:)))
            let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLowerHeaderGesture(_:)))
            
            downSwipeGesture.direction = .down
            upSwipeGesture.direction = .up
            
            self.addGestureRecognizer(downSwipeGesture)
            self.addGestureRecognizer(upSwipeGesture)
        }
    }
    
    @objc private func handleUpperHeaderGesture(_ gesture: UISwipeGestureRecognizer) {
        let direction = gesture.direction
        if isHalfScreen {
            if direction == .down {
                onButtonTapped?(isHalfScreen)
                isHalfScreen.toggle()
            }
        } else {
            onButtonTapped?(isHalfScreen)
            isHalfScreen.toggle()
        }
    }
    
    @objc private func handleLowerHeaderGesture(_ gesture: UISwipeGestureRecognizer) {
        let direction = gesture.direction
        if isHalfScreen {
            if direction == .up {
                onButtonTapped?(isHalfScreen)
                isHalfScreen.toggle()
            }
        } else {
            if direction == .down {
                onButtonTapped?(isHalfScreen)
                isHalfScreen.toggle()
            }
        }
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
