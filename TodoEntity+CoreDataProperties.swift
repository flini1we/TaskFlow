//
//  TodoEntity+CoreDataProperties.swift
//  TaskFlow
//
//  Created by Данил Забинский on 23.02.2025.
//
//

import Foundation
import CoreData

@objc(TodoEntity)
public class TodoEntity: NSManagedObject {

}

extension TodoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var finishedAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var section: String?

}

extension TodoEntity : Identifiable {

}
