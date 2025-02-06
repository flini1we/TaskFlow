//
//  TaskTableViewCell.swift
//  TaskFlow
//
//  Created by Данил Забинский on 05.02.2025.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    private lazy var taskTitle: UILabel = {
        let label = UILabel()
        
        return label
    }()
}

extension TaskTableViewCell {
    
    static var identifier: String {
        "\(self)"
    }
}
