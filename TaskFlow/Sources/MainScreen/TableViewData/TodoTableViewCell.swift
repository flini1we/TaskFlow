//
//  TodoTableViewCell.swift
//  TaskFlow
//
//  Created by Данил Забинский on 09.02.2025.
//

import UIKit

final class TodoTableViewCell: UITableViewCell {
    
    static var identifier: String { "\(self)" }
    private var textFieldDelegate: TodoTextFieldDelegate?
    
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
    
    lazy var todoTextField: UITextField = {
        let label = UITextField()
        label.textAlignment = .left
        return label
    }()
    
    private lazy var squareImageView: UIImageView = {
        let image = UIImageView(image: SystemImages.square.image)
        image.tintColor = SelectedColor.backgroundColor
        image.alpha = 0.1
        return image
    }()
    
    private lazy var squareWithCheckMarkImage: UIImageView = {
        let image = UIImageView(image: SystemImages.checkmark.image)
        image.tintColor = SelectedColor.backgroundColor
        image.alpha = 0
        return image
    }()
    
    private lazy var squareImageAndTitleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            squareImageView,
            todoTextField
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
    
    func configureWithTodo(_ todo: Todo, delegate todoTextFieldDelegate: TodoTextFieldDelegate) {
        currentId = todo.id
        
        todoTextField.text = todo.title
        moveToAnotherSectionButton.setImage(SystemImages.moveTodo(todo.section).image, for: .normal)
        
        moveToAnotherSectionButton.addAction(UIAction { [weak self] _ in
            self?.changeTodoSection?(todo.id)
        }, for: .touchUpInside)
        
        textFieldDelegate = todoTextFieldDelegate
        self.todoTextField.delegate = textFieldDelegate
    }
    
    func updateColor() {
        UIView.animate(withDuration: 0.5) {
            self.squareImageView.alpha = 0
            self.squareWithCheckMarkImage.alpha = 0
            self.moveToAnotherSectionButton.alpha = 0
        } completion: { _ in
            self.squareImageView.tintColor = SelectedColor.backgroundColor
            self.squareWithCheckMarkImage.tintColor = SelectedColor.backgroundColor
            self.moveToAnotherSectionButton.tintColor = SelectedColor.backgroundColor
            
            UIView.animate(withDuration: 0.5) {
                self.squareImageView.alpha = 0.1
                self.squareWithCheckMarkImage.alpha = 0
                self.moveToAnotherSectionButton.alpha = 1
            }
        }
    }
}

// MARK: Private methods
private extension TodoTableViewCell {
    
    func setupData() {
        setupSubviews()
        setupLayout()
        setupGestures()
    }
    
    func setupSubviews() {
        self.selectionStyle = .none
        backgroundColor = .systemGray6
        
        contentView.addSubview(bgView)
        bgView.addSubview(dataStackView)
        squareImageView.addSubview(squareWithCheckMarkImage)
    }
    
    func setupLayout() {
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
            todoTextField.leadingAnchor.constraint(equalTo: squareImageView.trailingAnchor, constant: Constants.paddingSmall.value),
            todoTextField.trailingAnchor.constraint(lessThanOrEqualTo: moveToAnotherSectionButton.leadingAnchor, constant: -Constants.paddingTiny.value)
        ])
        
        NSLayoutConstraint.activate([
            squareWithCheckMarkImage.centerXAnchor.constraint(equalTo: squareImageView.centerXAnchor),
            squareWithCheckMarkImage.centerYAnchor.constraint(equalTo: squareImageView.centerYAnchor),
        ])
    }
    
    func setupGestures() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(rightSwipe(_:)))
        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc func rightSwipe(_ gesture: UIPanGestureRecognizer) {
        let xTransition = gesture.translation(in: self).x
        setupAnimation(xTransition, gesture)
    }
    
    func setupAnimation(_ xTransition: CGFloat, _ gesture: UIPanGestureRecognizer) {
        guard xTransition > 0 else { return }
        
        let currentLoaded = max(0.1, xTransition / maxTreshold)
        squareImageView.alpha = currentLoaded
        squareWithCheckMarkImage.alpha = currentLoaded
        todoTextField.transform = CGAffineTransform(translationX: min(xTransition, maxTreshold), y: 0)
        
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
                FeedBackService.occurreVibration(type: .medium)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.backToDefaultAnimation()
                }
            }
        }
    }
    
    func backToDefaultAnimation() {
        UIView.animate(withDuration: 0.2) {
            self.todoTextField.transform = .identity
            self.squareImageView.alpha = 0.1
            self.squareWithCheckMarkImage.alpha = 0
            self.squareImageView.transform = .identity
        }
    }
}
