//
//  SettingsView.swift
//  TaskFlow
//
//  Created by Данил Забинский on 27.02.2025.
//

import UIKit

final class SettingsView: UIView, UICollectionViewDataSource {
    
    private var settingsViewModel: SettingsViewModel!
    
    private lazy var colorsCollectionView: UICollectionView = {
        let elementSize = ElementsSize.accentColorImageSize.value
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = .init(width: elementSize,
                                              height: elementSize)
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = Constants.paddingSmall.value
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(AccentColorCollectionViewCell.self, forCellWithReuseIdentifier: AccentColorCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemGray6
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.heightAnchor.constraint(equalToConstant: elementSize).isActive = true
        return collectionView
    }()
    
    private lazy var dataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            colorsCollectionView,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.paddingSmall.value
        return stack
    }()
    
    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        settingsViewModel.getColorsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccentColorCollectionViewCell.identifier, for: indexPath) as! AccentColorCollectionViewCell
        let currentColor = settingsViewModel.getColorOnIndexPath(indexPath)
        let isCurrentColorSelected = settingsViewModel.isCurrentColorSelected(indexPath)
        
        cell.setupWithColor(currentColor, isSelected: isCurrentColorSelected)
        cell.changeColor = { [weak self] newColor in
            self?.settingsViewModel.changeColor(newColor)
        }
        return cell
    }
    
    func reloadColorsCollectionView() {
        colorsCollectionView.reloadData()
    }
}

private extension SettingsView {
    
    func setup() {
        backgroundColor = .systemGray6
        
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(colorsCollectionView)
    }
    
    func setupConstraints() {

        NSLayoutConstraint.activate([
            colorsCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.paddingMedium.value),
            colorsCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.paddingMedium.value),
            colorsCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.paddingSmall.value),
        ])
    }
}
