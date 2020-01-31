//
//  API.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 31.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

let API = _API()

class _API {
    
    func requestInRoomsUsers(success: @escaping ([InRoomUser]) -> (),
                             fail: @escaping (String) -> ()) {
        guard let url = URL(string: "http://control-access-api.herokuapp.com/rooms") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            do {
                let JSONData = try JSONDecoder().decode([InRoomUser].self, from: data)
                DispatchQueue.main.async {
                    success(JSONData)
                }
            } catch let jsonError {
                print(jsonError)
                fail(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func requestLoggedUsers(success: @escaping ([LoggedUser]) -> (),
                            fail: @escaping (String) -> ()) {
        guard let url = URL(string: "http://control-access-api.herokuapp.com/logged") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            do {
                let JSONData = try JSONDecoder().decode([LoggedUser].self, from: data)
                DispatchQueue.main.async {
                    success(JSONData)
                }
            } catch let jsonError {
                print(jsonError)
                fail(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func requestCheckID(identifier: String,
                        inside: @escaping () -> (),
                        outside: @escaping () -> (),
                        close: @escaping () -> (),
                        fail: @escaping (String) -> ()) {
        let parameters = ["uuid": identifier]
        let url = URL(string: "http://control-access-api.herokuapp.com/check")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters,
                                                          options: .prettyPrinted)
        } catch let error {
            let error = error.localizedDescription
            print(error)
            fail(error)
        }
        let task = URLSession.shared.dataTask(with: request,
                                              completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                let jsonData = try JSONDecoder().decode(CheckStatus.self, from: data)
                DispatchQueue.main.async {
                    if jsonData.message == "Hello" {
                        inside()
                    } else if jsonData.message == "Goodbye" {
                        outside()
                    } else if jsonData.message == "Close" {
                        close()
                    }
                }
            } catch let error {
                let error = error.localizedDescription
                print(error)
                fail(error)
            }
        })
        task.resume()
    }
    
    func requestForRoom(identifier: String,
                        status: String,
                        inside: @escaping () -> (),
                        outside: @escaping () -> (),
                        close: @escaping () -> (),
                        fail: @escaping (String) -> ()) {
        let parameters = ["uuid": identifier,
                          "room": "Главная комната",
                          "status": status]
        let url = URL(string: "http://control-access-api.herokuapp.com/rooms")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters,
                                                          options: .prettyPrinted)
        } catch let error {
            let error = error.localizedDescription
            print(error)
            fail(error)
        }
        let task = URLSession.shared.dataTask(with: request,
                                              completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                let jsonData = try JSONDecoder().decode(CheckStatus.self, from: data)
                DispatchQueue.main.async {
                    if jsonData.message == "InRoom" {
                        inside()
                    } else if jsonData.message == "OutRoom" {
                        outside()
                    } else if jsonData.message == "ErrorMessage" {
                        close()
                    }
                }
            } catch let error {
                let error = error.localizedDescription
                print(error)
                fail(error)
            }
        })
        task.resume()
    }
}
