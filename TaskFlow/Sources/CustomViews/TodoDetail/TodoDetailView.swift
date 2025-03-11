//
//  TodoDetailView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 11.03.2025.
//

import UIKit

final class TodoDetailView: UIView {
    
    private lazy var dayAndMonthDateFormater: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "dd MMM"
        formater.locale = .current
        return formater
    }()
    
    private lazy var timeFormater: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "HH:mm"
        formater.locale = .current
        return formater
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = Constants.paddingMedium.value
        return view
    }()
    
    private(set) lazy var deleteTodoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = Constants.paddingSmall.value
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.setTitle("Delete Todo", for: .normal)
        return button
    }()
    
    private lazy var todoTitle: UILabel = {
        let title = UILabel()
        title.font = .boldSystemFont(ofSize: Fonts.title.value)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private(set) lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(SystemImages.cross.image, for: .normal)
        button.tintColor = SelectedColor.backgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleAndCrossButtonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            todoTitle,
            dismissButton
        ])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = Constants.paddingSmall.value
        return stack
    }()
    
    // MARK: Info about begining todo
    private lazy var beginedAtTitle: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: Fonts.default.value)
        title.textColor = .secondaryLabel
        title.text = "Created"
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var dayOfCreatingLabel: UILabel = {
        let title = UILabel()
        title.font = .boldSystemFont(ofSize: Fonts.default.value)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var timeOfCreatingLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: Fonts.default.value)
        title.textColor = .secondaryLabel
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    // MARK: Info about finishing todo
    private lazy var finishedAtTitle: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: Fonts.default.value)
        title.textColor = .secondaryLabel
        title.text = "Completed"
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var dayOfFinishingLabel: UILabel = {
        let title = UILabel()
        title.font = .boldSystemFont(ofSize: Fonts.default.value)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var timeOfFinishingLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: Fonts.default.value)
        title.textColor = .secondaryLabel
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    // MARK: Time stacks
    private lazy var createdAtDataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            beginedAtTitle,
            dayOfCreatingLabel,
            timeOfCreatingLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.paddingSmall.value
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var finishedAtDataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            finishedAtTitle,
            dayOfFinishingLabel,
            timeOfFinishingLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.paddingSmall.value
        stack.alignment = .trailing
        return stack
    }()
    
    private lazy var todoDateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            createdAtDataStackView,
            finishedAtDataStackView
        ])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: DataStackView
    private lazy var dateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleAndCrossButtonStackView,
            todoDateStackView,
            deleteTodoButton
        ])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.spacing = Constants.paddingMedium.value
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithTodo(_ todo: Todo) {
        self.todoTitle.text = todo.title
        
        dayOfCreatingLabel.text = dayAndMonthDateFormater.string(from: todo.createdAt)
        timeOfCreatingLabel.text = timeFormater.string(from: todo.createdAt)
        
        dayOfFinishingLabel.text = dayAndMonthDateFormater.string(from: todo.finishedAt!)
        timeOfFinishingLabel.text = timeFormater.string(from: todo.finishedAt!)
    }
}

private extension TodoDetailView {
    
    func setup() {
        
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(bgView)
        bgView.addSubview(dateStackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.paddingSmall.value),
            bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.paddingSmall.value),
            bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.paddingSmall.value),
            bgView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.paddingSmall.value),
        ])
        
        NSLayoutConstraint.activate([
            dateStackView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: Constants.paddingMedium.value),
            dateStackView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Constants.paddingMedium.value),
            dateStackView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Constants.paddingMedium.value)
        ])
    }
}
