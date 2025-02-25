//
//  TodoTableViewCell.swift
//  TaskFlow
//
//  Created by Данил Забинский on 09.02.2025.
//

import UIKit

final class TodoTableViewCell: UITableViewCell {
    
    var changeTodoSection: ((UUID) -> Void)?
    var finishTodo: ((UUID) -> Void)?
    private let maxTreshold: CGFloat = UIScreen.main.bounds.width / 7
    private var currentId: UUID!
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.paddingSmall.value
        return view
    }()
    
    private lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    private lazy var squareImageView: UIImageView = {
        let image = UIImageView(image: SystemImages.checkmark.image)
        image.tintColor = SelectedColor.backgroundColor
        image.alpha = 0.1
        return image
    }()
    
    private lazy var squareImageAndTitleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            squareImageView,
            todoLabel
        ])
        stack.spacing = Constants.paddingSmall.value
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        return stack
    }()
    
    private lazy var moveToAnotherSectionButton: UIButton = {
        let button = UIButton()
        button.tintColor = SelectedColor.backgroundColor
        button.backgroundColor = .systemBackground
        return button
    }()
    
    private lazy var dataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            squareImageAndTitleStack,
            moveToAnotherSectionButton
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        return stack
    }()
    
    override func prepareForReuse() {
        moveToAnotherSectionButton.removeTarget(nil, action: nil, for: .allEvents)
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithTodo(_ todo: Todo) {
        currentId = todo.id
        
        todoLabel.text = todo.title
        moveToAnotherSectionButton.setImage(SystemImages.moveTodo(todo.section).image, for: .normal)
        
        moveToAnotherSectionButton.addAction(UIAction { [weak self] _ in
            self?.changeTodoSection?(todo.id)
        }, for: .touchUpInside)
    }
    
    private func setupData() {
        setupSubviews()
        setupLayout()
        setupGestures()
    }
    
    private func setupSubviews() {
        self.selectionStyle = .none
        backgroundColor = .systemGray6
        contentView.addSubview(bgView)
        bgView.addSubview(dataStackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingTiny.value),
            bgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingTiny.value),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingTiny.value),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingTiny.value / 4),
        ])
        
        NSLayoutConstraint.activate([
            dataStackView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: Constants.paddingTiny.value),
            dataStackView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Constants.paddingSmall.value),
            dataStackView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Constants.paddingSmall.value),
            dataStackView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -Constants.paddingTiny.value),
        ])
        
        moveToAnotherSectionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: self.intrinsicContentSize.width).isActive = true
        
        NSLayoutConstraint.activate([
            todoLabel.leadingAnchor.constraint(equalTo: squareImageView.trailingAnchor, constant: Constants.paddingSmall.value),
            todoLabel.trailingAnchor.constraint(lessThanOrEqualTo: moveToAnotherSectionButton.leadingAnchor, constant: -Constants.paddingTiny.value)
        ])
    }
    
    private func setupGestures() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(rightSwipe(_:)))
        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func rightSwipe(_ gesture: UIPanGestureRecognizer) {
        let xTransition = gesture.translation(in: self).x
        setupAnimation(xTransition, gesture)
    }
    
    private func setupAnimation(_ xTransition: CGFloat, _ gesture: UIPanGestureRecognizer) {
        guard xTransition > 0 else { return }
        
        let currentLoaded = max(0.1, xTransition / maxTreshold)
        squareImageView.alpha = currentLoaded
        todoLabel.transform = CGAffineTransform(translationX: min(xTransition, maxTreshold), y: 0)
        
        UIView.animate(withDuration: 0.2) {
            if currentLoaded >= 1 {
                self.squareImageView.transform = CGAffineTransform(scaleX: 1.35, y: 1.35).concatenating(CGAffineTransform(rotationAngle: .pi / 6))
            } else {
                self.squareImageView.transform = .identity
            }
        }
        
        if gesture.state == .ended {
            if currentLoaded < 1 {
                backToDefaultAnimation()
            } else {
                finishTodo?(self.currentId)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.backToDefaultAnimation()
                }
            }
        }
    }
    
    private func backToDefaultAnimation() {
        UIView.animate(withDuration: 0.2) {
            self.todoLabel.transform = .identity
            self.squareImageView.alpha = 0.1
            self.squareImageView.transform = .identity
        }
    }
}

extension TodoTableViewCell {
    
    static var identifier: String {
        "\(self)"
    }
}
