//
//  InRoomUser.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 30.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

struct InRoomUser: Decodable {
    let uuid: String
    let room: String
    let id: Int
    let username: String
}
