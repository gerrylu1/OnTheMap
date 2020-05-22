//
//  AlertController.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-20.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String?, message: String?, on viewController: UIViewController) {
        let alertVC = UIAlertController(title: title ?? "", message: message ?? "Unknown error.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    func showAlertOKCancel(title: String?, message: String?, on viewController: UIViewController, completion: @escaping () -> Void) {
        let alertVC = UIAlertController(title: title ?? "", message: message ?? "Unknown message.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            completion()
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
}
