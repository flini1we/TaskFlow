//
//  TodoTextFieldDelegate.swift
//  TaskFlow
//
//  Created by Данил Забинский on 02.03.2025.
//

import UIKit

class TodoTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    private var viewModel: MainViewModel
    private var currentTodo: Todo
    
    init(viewModel: MainViewModel, currentTodo: Todo) {
        self.viewModel = viewModel
        self.currentTodo = currentTodo
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty, text != currentTodo.title {
            viewModel.editTodo(todo: currentTodo, updatedTitle: text)
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
