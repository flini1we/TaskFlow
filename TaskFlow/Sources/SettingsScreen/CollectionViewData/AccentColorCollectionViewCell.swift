//
//  AccentColorCollectionViewCell.swift
//  TaskFlow
//
//  Created by Данил Забинский on 27.02.2025.
//

import UIKit

final class AccentColorCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String { "\(self)" }
    var currentColor: UIColor!
    
    var changeColor: ((UIColor) -> Void)?
    
    private lazy var accentColorElement: UIImageView = {
        let image = UIImageView(image: SystemImages.circle.image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: ElementsSize.accentColorImageSize.value).isActive = true
        image.widthAnchor.constraint(equalToConstant: ElementsSize.accentColorImageSize.value).isActive = true
        return image
    }()
    
    private lazy var isSelectedImage: UIImageView = {
        let image = UIImageView(image: SystemImages.circle.image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: ElementsSize.accentColorImageSize.value / 2).isActive = true
        image.widthAnchor.constraint(equalToConstant: ElementsSize.accentColorImageSize.value / 2).isActive = true
        image.tintColor = .systemGray6
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithColor(_ color: UIColor, isSelected: Bool) {
        isSelectedImage.alpha = isSelected ? 1 : 0
        accentColorElement.tintColor = color
        currentColor = color
    }
}

private extension AccentColorCollectionViewCell {
    
    func setup() {
        setupSubviews()
        setupConstraints()
        setupGestures()
    }
    
    func setupSubviews() {
        addSubview(accentColorElement)
        accentColorElement.addSubview(isSelectedImage)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            accentColorElement.topAnchor.constraint(equalTo: self.topAnchor),
            accentColorElement.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            accentColorElement.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            accentColorElement.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            isSelectedImage.centerXAnchor.constraint(equalTo: accentColorElement.centerXAnchor),
            isSelectedImage.centerYAnchor.constraint(equalTo: accentColorElement.centerYAnchor),
        ])
    }
    
    func setupGestures() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnColor)))
    }
    
    @objc func tapOnColor() {
        changeColor?(currentColor)
    }
}
