//
//  MainViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import Foundation

class MainViewModel: KeyboardObservable {
    
    var keyboardObserver: KeyboardObserver?
    
    private var lastSectionTapped: MainTableSections?
    private var tableState: TableState = .default {
        didSet {
            tableStateOnChange?(tableState)
        }
    }
    var tableStateOnChange: ((TableState) -> Void)?
    var changeLowerButton: (() -> Void)?
    var changeUpperButton: (() -> Void)?
    
    func handleHeaderButtonTapped(for section: MainTableSections, isHalfScreen: Bool) {
        
        if section == .sooner {
            if lastSectionTapped == .later {
                changeLowerButton?()
            }
            if isHalfScreen {
                tableState = .upperOpened
            } else {
                tableState = .default
            }
        } else {
            if lastSectionTapped == .sooner {
                changeUpperButton?()
            }
            if isHalfScreen {
                tableState = .lowerOpened
            } else {
                tableState = .default
            }
        }
        lastSectionTapped = section
    }
    
    func calculateCellsHeight(at indexPath: IndexPath, withState state: TableState) -> CGFloat {
        
        switch state {
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
            return TableItemSize.default.value / 2
        }
    }
    
    func setupObserver(onShowKeyboard: ((CGRect) -> Void)?,
                       onHideKeyboard: (() -> Void)?) {
        
        keyboardObserver = KeyboardObserver(onShow: { keyboardFrame in
            onShowKeyboard?(keyboardFrame)
        }, onHide: {
            onHideKeyboard?()
        })
    }
}
