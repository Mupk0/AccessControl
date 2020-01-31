//
//  ViewController.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 29.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @IBAction func didTapEnterButton(_ sender: Any) {
        if let login = loginTextField.text, let password = passwordTextField.text {
            if let user = Users.init(string: login), user.password == password {
                let vc = ActionsController.createInstance(identifier: user.identifier)
                let viewWithNavigation = UINavigationController(rootViewController: vc)
                viewWithNavigation.modalPresentationStyle = .fullScreen
                navigationController?.present(viewWithNavigation, animated: true)
            } else {
                AppDelegate.shared.sendNotification(title: "Ошибка",
                                                    description: "Неверный логин или пароль")
            }
        }
    }
    
    @IBAction func didTapInHouseButton(_ sender: Any) {
        let vc = InHouseTableController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapInRoomButton(_ sender: Any) {
        let vc = InRoomTableController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/1.5
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

