//
//  CoreDataErrors.swift
//  TaskFlow
//
//  Created by Данил Забинский on 04.03.2025.
//

import Foundation

enum CoreDataErrors: Error {
    
    case failedToObtainActiveTodosFromSection(TodoTypes)
    case failedToObtainFinishedTodos
    case failedToSaveDataInContext(CoreDataContextTypes)
    case failedToObtainFinishedTodosDueToTodoFinishedAtFieldIsNil(Todo)
    
    var errorDescription: String {
        switch self {
        case .failedToObtainActiveTodosFromSection(let mainTableSections):
            return "Oops.. Failed to load data from \(mainTableSections.rawValue) section."
        case .failedToObtainFinishedTodos:
            return "Oops.. Failed to load finishedTodod from data"
        case .failedToSaveDataInContext(let context):
            return "Oops.. Failed to load data from \(context)."
        case .failedToObtainFinishedTodosDueToTodoFinishedAtFieldIsNil(let todo):
            return "Oops.. Such todo with id: \(todo.id) isn't finished yet. Try to finish it first."
        }
    }
}
