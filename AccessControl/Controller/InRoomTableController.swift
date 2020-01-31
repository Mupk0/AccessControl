//
//  InRoomsTableController.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 30.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

class InRoomTableController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let topView = UIView()
    let tableView = UITableView(frame: CGRect(x: 0,
                                              y: 88,
                                              width: UIScreen.main.bounds.width,
                                              height: UIScreen.main.bounds.height))
    var usersInRoom = [InRoomUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        view.backgroundColor = .white
        navigationItem.title = "Сотрудники в комнатах"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                                                         style: .done,
                                                                                         target: self,
                                                                                         action: #selector(exitController))

        tableView.delegate = self
        tableView.dataSource = self
        
        InHouseTableCell.register(inTableView: tableView)
        API.requestInRoomsUsers(success: { data in
            self.usersInRoom = data
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
        usersInRoom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InHouseTableCell.identifier) as? InHouseTableCell
            else { return UITableViewCell() }

        cell.nameLabel.text = usersInRoom[indexPath.row].username
        cell.timeLabel.text = usersInRoom[indexPath.row].room
        return cell
    }
}
