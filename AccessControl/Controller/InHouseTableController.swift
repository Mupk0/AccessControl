//
//  InHouseTableController.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 30.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

class InHouseTableController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let topView = UIView()
    let tableView = UITableView(frame: CGRect(x: 0, y: 88, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var loggedUsers = [LoggedUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.backgroundColor = .white
        
        navigationItem.title = "Сотрудники в здании"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                                                         style: .done,
                                                                                         target: self,
                                                                                         action: #selector(exitController))
        tableView.delegate = self
        tableView.dataSource = self
        
        InHouseTableCell.register(inTableView: tableView)
        API.requestLoggedUsers(success: { data in
            self.loggedUsers = data
            self.tableView.reloadData()
        },fail: { errorString in
            let alertController = UIAlertController(
                title: "Ошибка",
                message: errorString,
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loggedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InHouseTableCell.identifier) as? InHouseTableCell
            else { return UITableViewCell() }

        cell.nameLabel.text = loggedUsers[indexPath.row].username
        cell.timeLabel.text = loggedUsers[indexPath.row].date
        return cell
    }
}
