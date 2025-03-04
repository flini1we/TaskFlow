//
//  DragAndDropDelegate.swift
//  TaskFlow
//
//  Created by Данил Забинский on 25.02.2025.
//

import UIKit

final class DragAndDropDelegate: NSObject, UITableViewDragDelegate, UITableViewDropDelegate {
    
    private var data: [Todo]!
    private var onDraggingDataChanged: (([Todo]) -> Void)
    
    init(data: [Todo], onDraggingDataChanged: @escaping (([Todo]) -> Void)) {
        self.data = data
        self.onDraggingDataChanged = onDraggingDataChanged
    }
    
    func updateData(_ data: [Todo]) { self.data = data }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.row < data.count else { return [] }
        
        let item = data[indexPath.row]
        let itemProvider = NSItemProvider(object: item.id.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        let items = coordinator.items
        guard !items.isEmpty else { return }
        items.forEach { item in
            
            if let dragItem = item.dragItem.localObject as? Todo {
                
                if let sourceIndexPath = item.sourceIndexPath {
                    
                    data.remove(at: sourceIndexPath.row)
                    data.insert(dragItem, at: destinationIndexPath.row)
                    
                    onDraggingDataChanged(data)
                }
            }
        }
    }
}
