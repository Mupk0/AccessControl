//
//  InHouseTableCell.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 30.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

class InHouseTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func register(inTableView tableView: UITableView) {
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
}
