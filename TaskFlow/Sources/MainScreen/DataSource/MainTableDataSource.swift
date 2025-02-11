//
//  MainTableDataSource.swift
//  TaskFlow
//
//  Created by Данил Забинский on 03.02.2025.
//

import UIKit

class MainTableDataSource: NSObject, UITableViewDataSource {
    
    private(set) var upperCell: MainTableViewCell?
    private(set) var lowerCell: MainTableViewCell?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        if indexPath.section == 0 {
            upperCell = cell
        } else {
            lowerCell = cell
        }
        return cell
    }
}
