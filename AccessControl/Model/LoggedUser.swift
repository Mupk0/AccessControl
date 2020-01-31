//
//  LoggedUser.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 30.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

struct LoggedUser: Decodable {
    let uuid: String
    let date: String
    let id: Int
    let username: String
}
