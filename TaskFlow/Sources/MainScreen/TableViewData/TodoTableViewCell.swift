//
//  TodoTableViewCell.swift
//  TaskFlow
//
//  Created by Данил Забинский on 09.02.2025.
//

import UIKit

final class TodoTableViewCell: UITableViewCell {
    
    static var identifier: String { "\(self)" }
    private var isActive: Bool!
    
    private var todoTextFieldDelegate: TodoTextFieldDelegate?
    private var todoScrollViewDelegate: TodoScrollViewDelegate?
    
    var changeTodoSection: ((Todo) -> Void)?
    var showTodoInfo: ((Todo) -> Void)?
    
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var todoScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceHorizontal = true
        scroll.addSubview(todoTextField)
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private lazy var squareImageView: UIImageView = {
        let image = UIImageView(image: SystemImages.square.image)
        image.tintColor = SelectedColor.backgroundColor
        return image
    }()
    
    private lazy var squareWithCheckMarkImage: UIImageView = {
        let image = UIImageView(image: SystemImages.checkmark.image)
        image.tintColor = SelectedColor.backgroundColor
        return image
    }()
    
    private lazy var squareImageAndTitleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            squareImageView,
            todoScrollView
        ])
        stack.spacing = Constants.paddingSmall.value
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        return stack
    }()
    
    private lazy var functionalButton: UIButton = {
        let button = UIButton()
        button.tintColor = SelectedColor.backgroundColor
        button.backgroundColor = .systemBackground
        return button
    }()
    
    private lazy var dataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            squareImageAndTitleStack,
            functionalButton
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        return stack
    }()
    
    override func prepareForReuse() {
        functionalButton.removeTarget(nil, action: nil, for: .allEvents)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithTodo(_ todo: Todo, isActive: Bool) {
        todoTextField.text = todo.title
        self.isActive = isActive
        
        if isActive {
            functionalButton.setImage(SystemImages.moveTodo(todo.section).image, for: .normal)
            functionalButton.addAction(UIAction { [weak self] _ in
                self?.changeTodoSection?(todo)
            }, for: .touchUpInside)
            squareWithCheckMarkImage.alpha = 0
            
            self.backgroundColor = .systemGray6
        } else {
            functionalButton.setImage(SystemImages.todoInfo.image, for: .normal)
            functionalButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
            functionalButton.addAction(UIAction { [weak self] _ in
                self?.showTodoInfo?(todo)
            }, for: .touchUpInside)
            squareWithCheckMarkImage.alpha = 1
            
            todoTextField.isUserInteractionEnabled = false
            self.backgroundColor = UIColor { traits in
                traits.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.systemGray6
            }
        }
    }
    
    func setDelegateToScrollView(scrollViewDelegate: TodoScrollViewDelegate) {
        self.todoScrollViewDelegate = scrollViewDelegate
        todoScrollView.delegate = todoScrollViewDelegate
    }
    
    func setDelegateToTextField(textFieldDelegate: TodoTextFieldDelegate) {
        self.todoTextFieldDelegate = textFieldDelegate
        todoTextField.delegate = self.todoTextFieldDelegate
    }
    
    func updateColor() {
        UIView.animate(withDuration: 0.5) {
            self.squareImageView.alpha = 0
            self.squareWithCheckMarkImage.alpha = 0
            self.functionalButton.alpha = 0
        } completion: { _ in
            self.squareImageView.tintColor = SelectedColor.backgroundColor
            self.squareWithCheckMarkImage.tintColor = SelectedColor.backgroundColor
            self.functionalButton.tintColor = SelectedColor.backgroundColor
            
            UIView.animate(withDuration: 0.5) {
                self.squareImageView.alpha = 1
                self.squareWithCheckMarkImage.alpha = 0
                self.functionalButton.alpha = 1
            }
        }
    }
    
    func onUIUpdate(value: CGFloat, isActive: Bool) {
        squareWithCheckMarkImage.alpha = value
        
        UIView.animate(withDuration: 0.1) {
            if value >= 0.85 && isActive || value < 0.025 && !isActive {
                self.squareImageView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            } else {
                self.squareImageView.transform = .identity
            }
        }
    }
}

// MARK: Private methods
private extension TodoTableViewCell {
    
    func setupData() {
        setupSubviews()
        setupLayout()
    }
    
    func setupSubviews() {
        self.selectionStyle = .none
//        backgroundColor = .systemGray6
        
        contentView.addSubview(bgView)
        bgView.addSubview(dataStackView)
        squareImageView.addSubview(squareWithCheckMarkImage)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingTiny.value / 4),
            bgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingTiny.value),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingTiny.value),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingTiny.value / 4),
        ])

        NSLayoutConstraint.activate([
            dataStackView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Constants.paddingSmall.value),
            dataStackView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Constants.paddingSmall.value),
            dataStackView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            dataStackView.heightAnchor.constraint(equalTo: bgView.heightAnchor),
        ])
        
        functionalButton.widthAnchor.constraint(equalToConstant: 44).isActive = true

        NSLayoutConstraint.activate([
            todoScrollView.heightAnchor.constraint(equalTo: bgView.heightAnchor),
            todoScrollView.leadingAnchor.constraint(equalTo: squareWithCheckMarkImage.trailingAnchor, constant: Constants.paddingSmall.value),
            todoScrollView.trailingAnchor.constraint(equalTo: functionalButton.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            todoTextField.leadingAnchor.constraint(equalTo: todoScrollView.leadingAnchor),
            todoTextField.centerYAnchor.constraint(equalTo: todoScrollView.centerYAnchor),
            todoTextField.heightAnchor.constraint(equalTo: todoScrollView.heightAnchor),
            todoTextField.trailingAnchor.constraint(equalTo: functionalButton.leadingAnchor)
        ])
    }
    
    func backToDefaultAnimation() {
        UIView.animate(withDuration: 0.2) {
            self.todoTextField.transform = .identity
            self.squareImageView.alpha = 1
            self.squareWithCheckMarkImage.alpha = 0
            self.squareImageView.transform = .identity
        }
    }
}
