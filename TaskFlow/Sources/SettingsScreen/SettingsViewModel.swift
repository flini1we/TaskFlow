//
//  SettingsViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 27.02.2025.
//

import UIKit

final class SettingsViewModel {
    
    //MARK: AccentColorData
    var currentColor: UIColor = SelectedColor.backgroundColor {
        didSet {
            reloadCollectionView?()
        }
    }
    var reloadCollectionView: (() -> Void)?
    var dismiss: (() -> Void)?
    
    let dataSource: [UIColor] = SelectedColor.getAvailableColors()
    
    func getColorsCount() -> Int { dataSource.count }
    
    func getColorOnIndexPath(_ indexPath: IndexPath) -> UIColor {
        dataSource[indexPath.item]
    }
    
    func isCurrentColorSelected(_ indexPath: IndexPath) -> Bool {
        dataSource[indexPath.item] == currentColor
    }
    
    func changeColor(_ updatedColor: UIColor) {
        if updatedColor != currentColor {
            currentColor = updatedColor
            SelectedColor.changeColor(updatedColor)
            dismiss?()
        }
    }
}
