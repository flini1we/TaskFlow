//
//  TodoTextFieldDelegate.swift
//  TaskFlow
//
//  Created by Данил Забинский on 02.03.2025.
//

import UIKit

class TodoTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    private var viewModel: MainViewModel
    private var currentId: UUID
    
    init(viewModel: MainViewModel, currentId: UUID!) {
        self.viewModel = viewModel
        self.currentId = currentId
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            viewModel.editTodo(withId: currentId, updatedTitle: text)
            return true
        }
        return false
    }
}
