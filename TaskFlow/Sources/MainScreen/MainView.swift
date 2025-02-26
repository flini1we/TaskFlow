//
//  MainView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainView: UIView {
    
    
    var changeView: (() -> Void)?
    var getViewBack: (() -> Void)?
    
    private var toolbarBottomConstraint: NSLayoutConstraint!
    
    lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        table.isScrollEnabled = false
        table.sectionHeaderTopPadding = 0
        return table
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(SystemImages.settings.image, for: .normal)
        button.tintColor = SelectedColor.backgroundColor
        return button
    }()
    
    private lazy var addTodoButton: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.setImage(SystemImages.addTodo.image, for: .normal)
        button.tintColor = SelectedColor.backgroundColor
        button.addAction(UIAction { [weak self] _ in
            self?.changeView?()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var hideKeyboardButton: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.setImage(SystemImages.hideKeyboard.image, for: .normal)
        button.tintColor = SelectedColor.backgroundColor
        button.addAction(UIAction { [weak self] _ in
            self?.getViewBack?()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(SystemImages.info.image, for: .normal)
        button.tintColor = SelectedColor.backgroundColor
        return button
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: HeaderSize.default.value))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barTintColor = .systemBackground
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        let addTodoBarButtonItem = UIBarButtonItem(customView: addTodoButton)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        
        toolbar.items = [settingsBarButtonItem, spacer, addTodoBarButtonItem, spacer, infoBarButtonItem]
        toolbar.barTintColor = .systemBackground
        toolbar.sizeToFit()
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        return toolbar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadHeaders() {
        mainTableView.reloadSections(IndexSet(integersIn: 0..<1), with: .fade)
    }
    
    func updateTable() {
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
    }
    
    func raiseToolbar(_ updatedHeight: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.toolbarBottomConstraint.constant = -updatedHeight + UIInsets.bottomInset
            self.layoutIfNeeded()
        }
        toolBar.items?[2] = UIBarButtonItem(customView: hideKeyboardButton)
        animateToolbarButtonChanging(toolBar)
    }
    
    func hideToolbar() {
        UIView.animate(withDuration: 0.25) {
            self.toolbarBottomConstraint.constant = 0
            self.layoutIfNeeded()
        }
        toolBar.items?[2] = UIBarButtonItem(customView: addTodoButton)
    }
    
    private func animateToolbarButtonChanging(_ toolbar: UIToolbar) {
        UIView.transition(with: toolBar, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.toolBar.setNeedsLayout()
            self.toolBar.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        addSubview(mainTableView)
        addSubview(toolBar)
    }
    
    private func setupLayout() {
        toolbarBottomConstraint = toolBar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            mainTableView.heightAnchor.constraint(equalToConstant: TableItemSize.fullScreen.value + 2 * HeaderSize.default.value),
            mainTableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            toolbarBottomConstraint,
            toolBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
