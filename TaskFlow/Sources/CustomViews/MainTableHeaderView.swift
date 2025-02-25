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
    var createdTodo: Todo? {
        didSet {
            if let createdTodo {
                sendCreatedTodoToDelegate?(createdTodo)
            }
        }
    }
    var sendCreatedTodoToDelegate: ((Todo) -> Void)?
    var backToDefaultTableViewPosition: (() -> Void)?
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
        stack.alpha = 0
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

extension MainTableHeaderView: UITextFieldDelegate {
    
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
        if let todoTitle = textField.text, !todoTitle.isEmpty {
            createdTodo = Todo(id: UUID(), title: todoTitle, section: .sooner)
        }
        getBackUpperView()
        textField.text = ""
        lightbulbImage.alpha = 0.2
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        lightbulbImage.alpha = 0.2
        return true
    }
}

extension MainTableHeaderView {
    
    func changeUpperView() {
        UIView.animate(withDuration: 0.25) {
            self.dataStackView.alpha = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            dataStackView.removeFromSuperview()
            
            addSubview(createTodoStackView)
            NSLayoutConstraint.activate([
                createTodoStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                createTodoStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.paddingMedium.value),
                createTodoStackView.heightAnchor.constraint(equalTo: self.heightAnchor),
                createTodoField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8)
            ])
            
            UIView.animate(withDuration: 0.25) { self.createTodoStackView.alpha = 1 }
        }
    }
    
    func getBackUpperView() {
        UIView.animate(withDuration: 0.25) {
            self.createTodoStackView.alpha = 0
        } completion: { _ in
            self.createTodoStackView.removeFromSuperview()
            
            self.addSubview(self.dataStackView)
            NSLayoutConstraint.activate([
                self.dataStackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.875),
                self.dataStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                self.dataStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ])
            self.backToDefaultTableViewPosition?()
            
            UIView.animate(withDuration: 0.25) { self.dataStackView.alpha = 1 }
        }
    }
}
