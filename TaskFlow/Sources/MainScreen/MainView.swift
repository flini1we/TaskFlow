//
//  MainView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

final class MainView: UIView {
    
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
    
    private lazy var settingsBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        return item
    }()
    
    private lazy var addTodoBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        return item
    }()
    
    private lazy var hideKeyboardBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        return item
    }()
    
    private lazy var chartsBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        return item
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: HeaderSize.default.value))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barTintColor = .systemBackground
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        
        toolbar.items = [settingsBarButtonItem, spacer, addTodoBarButtonItem, spacer, chartsBarButtonItem]
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
        mainTableView.reloadSections(IndexSet(integer: 0), with: .fade)
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
        toolBar.items?[2] = hideKeyboardBarButtonItem
    }
    
    func hideToolbar() {
        UIView.animate(withDuration: 0.25) {
            self.toolbarBottomConstraint.constant = 0
            self.layoutIfNeeded()
        }
        toolBar.items?[2] = addTodoBarButtonItem
    }
    
    func updateBackgroundColor() {
        
        settingsBarButtonItem.tintColor = SelectedColor.backgroundColor
        addTodoBarButtonItem.tintColor = SelectedColor.backgroundColor
        hideKeyboardBarButtonItem.tintColor = SelectedColor.backgroundColor
        chartsBarButtonItem.tintColor = SelectedColor.backgroundColor
    }
    
    func addActionToHideKeyboardButton(_ action: UIAction) {
        hideKeyboardBarButtonItem.primaryAction = action
        hideKeyboardBarButtonItem.tintColor = SelectedColor.backgroundColor
        hideKeyboardBarButtonItem.image = SystemImages.hideKeyboard.image
    }
    
    func addActionToAddTodoButton(_ action: UIAction) {
        addTodoBarButtonItem.primaryAction = action
        addTodoBarButtonItem.tintColor = SelectedColor.backgroundColor
        addTodoBarButtonItem.image = SystemImages.addTodo.image
    }
    
    func addActionToSettingsButton(_ action: UIAction) {
        settingsBarButtonItem.primaryAction = action
        settingsBarButtonItem.tintColor = SelectedColor.backgroundColor
        settingsBarButtonItem.image = SystemImages.settings.image
    }
    
    func addActionToChartsButton(_ action: UIAction) {
        chartsBarButtonItem.primaryAction = action
        chartsBarButtonItem.tintColor = SelectedColor.backgroundColor
        chartsBarButtonItem.image = SystemImages.charts.image
    }
    
    func enableOrDisableAllToolbardButtons(shouldEnable: Bool) {
        if !shouldEnable {
            settingsBarButtonItem.isEnabled = false
            chartsBarButtonItem.isEnabled = false
        } else {
            settingsBarButtonItem.isEnabled = true
            chartsBarButtonItem.isEnabled = true
        }
    }
}

private extension MainView {
    
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = Constants.paddingMedium.value
        layer.masksToBounds = true
        setupSubviews()
        setupLayout()
    }
    
    func setupSubviews() {
        addSubview(mainTableView)
        addSubview(toolBar)
    }
    
    func setupLayout() {
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
