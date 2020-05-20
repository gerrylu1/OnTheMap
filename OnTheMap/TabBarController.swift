//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-20.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    @IBOutlet weak var addPinBarButton: UIBarButtonItem!
    
    let limit:Int = 100
    
    var currentSessionTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: .plain, target: self, action: #selector(self.logout))
        refreshBarButton.isEnabled = false
        currentSessionTask = APIClient.getStudentLocation(limit: limit, completion: handleLocationDataResponse(studentsInformation:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func refresh(_ sender: Any) {
        refreshBarButton.isEnabled = false
        currentSessionTask = APIClient.getStudentLocation(limit: limit, completion: handleLocationDataResponse(studentsInformation:error:))
    }
    
    @objc func logout() {
        currentSessionTask?.cancel()
        APIClient.logout(completion: handleLogoutResponse)
    }
    
    func handleLocationDataResponse(studentsInformation: [StudentInformation], error: Error?) {
        refreshBarButton.isEnabled = true
        guard error == nil else {
            AlertController.showAlert(title: "Get Locations Failed", message: error?.localizedDescription, on: self)
            return
        }
        StudentInformationModel.studentsInformation = studentsInformation
        (selectedViewController as! DataViewControllerProtocol).loadData()
    }
    
    func handleLogoutResponse() {
        navigationController?.popToRootViewController(animated: true)
    }
}
