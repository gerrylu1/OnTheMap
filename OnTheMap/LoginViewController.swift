//
//  ViewController.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-19.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addPaddingToTextField(textField: emailTextField, padding: 10)
        addPaddingToTextField(textField: passwordTextField, padding: 10)
    }
    
    func addPaddingToTextField(textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.rightView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
    }

}
