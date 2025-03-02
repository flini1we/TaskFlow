//
//  AddingTodoView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 25.02.2025.
//

import UIKit

final class AddingTodoView: UIView {
    
    private var createdTodo: Todo? {
        didSet {
            if let createdTodo {
                onTodoCreate?(createdTodo)
            }
        }
    }
    var onTodoCreate: ((Todo) -> Void)?
    var hideView: (() -> Void)?
    
    lazy var createTodoField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .systemBackground
        field.borderStyle = .none
        field.placeholder = "Add a todo"
        field.textAlignment = .left
        field.returnKeyType = .continue
        field.clearButtonMode = .whileEditing
        field.delegate = self
        field.font = .boldSystemFont(ofSize: Fonts.default.value)
        return field
    }()
    
    private lazy var lightbulbImage: UIImageView = {
        let lightbulbImage = UIImageView(image: SystemImages.newTodo.image)
        lightbulbImage.tintColor = .systemYellow
        lightbulbImage.alpha = 0.2
        return lightbulbImage
    }()
    
    private lazy var createTodoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            lightbulbImage,
            createTodoField
        ])
        stack.spacing = Constants.paddingSmall.value
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func didMoveToSuperview() {
        createTodoField.becomeFirstResponder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        
        addSubview(createTodoStackView)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            createTodoStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            createTodoStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.paddingMedium.value),
            createTodoStackView.heightAnchor.constraint(equalTo: self.heightAnchor),
            createTodoField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8)
        ])
    }
}

extension AddingTodoView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count >= currentText.count {
            lightbulbImage.alpha += 0.05
        } else {
            lightbulbImage.alpha -= 0.05
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        if let todoTitle = textField.text, !todoTitle.isEmpty {
            createdTodo = Todo(id: UUID(), title: todoTitle, section: .sooner)
        }
        textField.text = ""
        lightbulbImage.alpha = 0.2
        hideView?()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        lightbulbImage.alpha = 0.2
        return true
    }
}
