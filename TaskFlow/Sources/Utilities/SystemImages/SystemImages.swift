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
         newTodo
    
    var image: UIImage {
        switch self {
        case .laterHeader:
            return UIImage(systemName: "note")!
        case .soonerHeader:
            return UIImage(systemName: "note.text")!
        case .arrowsUp:
            return UIImage(systemName: "arrow.up.and.line.horizontal.and.arrow.down")!
            // return UIImage(systemName: "rectangle.expand.vertical")!
//            return UIImage(systemName: "rectangle.arrowtriangle.2.outward")!
        case .arrowsDown:
            return UIImage(systemName: "arrow.down.and.line.horizontal.and.arrow.up")!
//            return UIImage(systemName: "rectangle.compress.vertical")!
//            return UIImage(systemName: "rectangle.arrowtriangle.2.inward")!
        case .settings:
            return UIImage(systemName: "gear")!
        case .newTodo:
            return UIImage(systemName: "lightbulb.max.fill")!
            //return (UIImage(systemName: "pencil.and.scribble")?.withTintColor(SelectedColor.backgroundColor, renderingMode: .alwaysOriginal))!
        }
    }
         
}
