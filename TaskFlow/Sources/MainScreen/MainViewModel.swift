//
//  MainViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import Foundation

class MainViewModel {
    
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
}
