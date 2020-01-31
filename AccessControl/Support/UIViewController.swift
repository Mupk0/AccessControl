//
//  UIViewController.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 30.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setNavigationBar(controllerName: String) {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 44, width: screenSize.width, height: 40))
        navBar.isTranslucent = false
        navBar.barTintColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        let navItem = UINavigationItem(title: controllerName)
        let doneItem = UIBarButtonItem(title: "Выйти", style: .done, target: nil, action: #selector(exitController))
        navItem.rightBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
    }
    
    @objc func exitController() {
        dismiss(animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.view.tintColor = .darkGray
        alert.addAction(UIAlertAction(title: "ОК",
                                                style: .cancel,
                                                handler: { action in
           self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true)
    }
}
