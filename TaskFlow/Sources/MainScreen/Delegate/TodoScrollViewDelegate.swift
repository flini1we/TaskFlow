//
//  TodoScrollViewDelegate.swift
//  TaskFlow
//
//  Created by Данил Забинский on 10.03.2025.
//

import UIKit

final class TodoScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    typealias OnTodoCompleteType = ((Todo) -> Void)
    typealias OnUIUpdateType = ((CGFloat) -> Void)
    
    private let maxTreshold: CGFloat = -UIScreen.main.bounds.width / 5
    private var onTodoComplete: OnTodoCompleteType
    private var onUIUpdateCompletion: OnUIUpdateType
    private var currentTodo: Todo
    private var isTodoActive: Bool
    
    init(with todo: Todo,
         onTodoComplete onTodoCompleteCompletion: @escaping OnTodoCompleteType,
         onUIupdate onUIUpdateCompletion: @escaping OnUIUpdateType,
         isActive: Bool) {
        self.currentTodo = todo
        self.onTodoComplete = onTodoCompleteCompletion
        self.onUIUpdateCompletion = onUIUpdateCompletion
        self.isTodoActive = isActive
        super.init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        
        if xOffset > 0 {
            scrollView.contentOffset.x = 0
        } else if xOffset < maxTreshold {
            scrollView.contentOffset.x = maxTreshold
        } else {
            let currentLoaded = isTodoActive ? xOffset / maxTreshold : 1 - xOffset / maxTreshold
            onUIUpdateCompletion(currentLoaded)
            if !scrollView.isDragging && (currentLoaded >= 0.8 && isTodoActive || currentLoaded < 0.2 && !isTodoActive) {
                onTodoComplete(currentTodo)
            }
        }
    }
}
