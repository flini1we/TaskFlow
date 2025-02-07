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
         arrowsDown
    
    var image: UIImage {
        switch self {
        case .laterHeader:
            return UIImage(systemName: "note")!
        case .soonerHeader:
            return UIImage(systemName: "note.text")!
        case .arrowsUp:
            return UIImage(systemName: "arrow.up.and.line.horizontal.and.arrow.down")!
        case .arrowsDown:
            return UIImage(systemName: "arrow.down.and.line.horizontal.and.arrow.up")!
        }
    }
         
}
