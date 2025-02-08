//
//  MainTableDelegate.swift
//  TaskFlow
//
//  Created by Данил Забинский on 06.02.2025.
//

import UIKit

class MainTableDelegate: NSObject, UITableViewDelegate {
    
    var currentState: TableState = .default {
        didSet {
            reloadTalbe?()
        }
    }
    var reloadTalbe: (() -> Void)?
    
    private(set) var firstHeader = MainTableHeaderView(in: .sooner)
    private(set) var secondHeader = MainTableHeaderView(in: .later)
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return firstHeader
        case 1:
            return secondHeader
        default:
            return nil
        }
    }
    
    override init() {
        super.init()
        firstHeader.backToDefaultTableViewPosition = { [weak self] in
            self?.currentState = .default
            self?.updateLowerButton()
            self?.updateUpperButton()
        }
    }
    
    func updateLowerButton() {
        secondHeader.updateButtonImage()
    }
    
    func updateUpperButton() {
        firstHeader.updateButtonImage()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        HeaderSize.default.value
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch currentState {
        case .default:
            return TableItemSize.default.value
        case .upperOpened:
            if indexPath.section == 0 {
                return TableItemSize.fullScreen.value
            } else {
                return TableItemSize.none.value
            }
        case .lowerOpened:
            if indexPath.section == 0 {
                return TableItemSize.none.value
            } else {
                return TableItemSize.fullScreen.value
            }
        case .addingTask:
            return TableItemSize.default.value / 1.75
        }
    }
}
