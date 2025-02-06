//
//  MainViewModel.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import Foundation

class MainViewModel {
    
    private var tableState: TableState = .default {
        didSet {
            tableStateOnChange?(tableState)
        }
    }
    
    var tableStateOnChange: ((TableState) -> Void)?
    
    func handleHeaderButtonTapped(for section: MainTableSections, isHalfScreen: Bool) {
        if section == .sooner {
            if isHalfScreen {
                tableState = .upperOpened
            } else {
                tableState = .default
            }
        } else {
            if isHalfScreen {
                tableState = .lowerOpened
            } else {
                tableState = .default
            }
        }
    }
}
