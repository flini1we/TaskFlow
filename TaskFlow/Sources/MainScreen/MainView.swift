//
//  MainView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainView: UIView {
    
    var changeView: (() -> Void)?
    
    lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        table.isScrollEnabled = false
        table.sectionHeaderTopPadding = 0 // отступ от хедера
        return table
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(SystemImages.settings.image, for: .normal)
        button.tintColor = SelectedColor.backgroundColor
        button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        button.addAction(UIAction { [weak self] _ in
            self?.changeView?()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var searchBarStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            settingsButton,
        ])
        stack.spacing = Constants.paddingSmall.value
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.items = [UIBarButtonItem(customView: searchBarStackView)]
        toolbar.barTintColor = .systemBackground
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
    
    func updateMainTableView() {
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
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
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            mainTableView.heightAnchor.constraint(equalToConstant: TableItemSize.fullScreen.value + 2 * HeaderSize.default.value),
            mainTableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            toolBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
