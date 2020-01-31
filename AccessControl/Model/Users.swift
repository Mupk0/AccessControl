//
//  Users.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 31.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import Foundation

enum Users {
    case Dima
    case Ivan
    case Test
    
    init? (string: String) {
        switch string {
        case "dima":
            self = .Dima
        case "ivan":
            self = .Ivan
        case "test":
            self = .Test
        default:
            return nil
        }
    }
    
    var name: String {
        switch self {
        case .Dima:
            return "dima"
        case .Ivan:
            return "ivan"
        case .Test:
            return "test"
        }
    }
    
    var password: String {
        switch self {
        case .Dima:
            return "dima"
        case .Ivan:
            return "ivan"
        case .Test:
            return "test"
        }
    }
    
    var identifier: String {
        switch self {
        case .Dima:
            return "777"
        case .Ivan:
            return "888"
        case .Test:
            return "999"
        }
    }
    
    static let allValues = [Dima, Ivan, Test]
    
    static var allNames: [String] {
        return Users.allValues.map { $0.name }
    }
}
