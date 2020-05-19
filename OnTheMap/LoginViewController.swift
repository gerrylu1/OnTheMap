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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addPaddingToTextField(textField: emailTextField, padding: 10)
        addPaddingToTextField(textField: passwordTextField, padding: 10)
    }
    
    @IBAction func login(_ sender: Any) {
        setLoggingIn(true)
        APIClient.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(APIClient.Endpoints.signUp.url)
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        guard success else {
            showLoginFailure(message: error?.localizedDescription ?? "Unknown Error.")
            return
        }
        print(APIClient.Auth.sessionId)
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signUpButton.isEnabled = !loggingIn
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func addPaddingToTextField(textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.rightView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
    }
    
}
