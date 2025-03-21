//
//  SystemImages.swift
//  TaskFlow
//
//  Created by Данил Забинский on 07.02.2025.
//

import UIKit

enum SystemImages {
    
    case laterHeader,
         soonerHeader,
         arrowsUp,
         arrowsDown,
         settings,
         newTodo,
         addTodo,
         hideKeyboard,
         charts,
         moveTodo(MainTableSections),
         checkmark,
         square,
         circle,
         lightSun,
         darkMoon,
         sparkles,
         sparkle,
         todoInfo,
         cross
    
    var image: UIImage {
        switch self {
        case .laterHeader:
            return UIImage(systemName: "note")!
        case .soonerHeader:
            return UIImage(systemName: "note.text")!
        case .arrowsUp:
            return UIImage(systemName: "rectangle.expand.vertical")!
        case .arrowsDown:
            return UIImage(systemName: "rectangle.compress.vertical")!
        case .settings:
            return UIImage(systemName: "gear")!
        case .newTodo:
            return UIImage(systemName: "lightbulb.max.fill")!
        case .addTodo:
            return UIImage(systemName: "plus")!
        case .hideKeyboard:
            return UIImage(systemName: "keyboard.chevron.compact.down")!
        case .charts:
            return UIImage(systemName: "chart.bar")!
        case .moveTodo(let section):
            if section == .later {
                return UIImage(systemName: "chevron.up")!
            } else {
                return UIImage(systemName: "chevron.down")!
            }
        case .checkmark:
            return UIImage(systemName: "checkmark")!
        case .square:
            return UIImage(systemName: "square")!
        case .circle:
            return UIImage(systemName: "circle.fill")!
        case .lightSun:
            return UIImage(systemName: "sun.max.fill")!
        case .darkMoon:
            return UIImage(systemName: "moon.fill")!
        case .sparkles:
            return UIImage(systemName: "sparkles")!
        case .sparkle:
            return UIImage(systemName: "sparkle")!
        case .todoInfo:
            return UIImage(systemName: "ellipsis")!
        case .cross:
            return UIImage(systemName: "xmark")!
        }
    }
}
