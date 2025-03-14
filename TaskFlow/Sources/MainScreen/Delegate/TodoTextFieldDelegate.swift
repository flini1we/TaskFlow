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
    private var todoIndexPath: IndexPath
    
    init(viewModel: MainViewModel, currentTodo: Todo, todoIndexPath: IndexPath) {
        self.viewModel = viewModel
        self.currentTodo = currentTodo
        self.todoIndexPath = todoIndexPath
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.scrollTableData(indexPath: self.todoIndexPath, section: currentTodo.section)
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
