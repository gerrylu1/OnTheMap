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
    @IBOutlet weak var logoutBarButton: UIBarButtonItem!
    
    let limit:Int = 100
    
    var currentSessionTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicateNetworkActivity(true)
        currentSessionTask = APIClient.getStudentLocation(limit: limit, completion: handleLocationDataResponse(studentsInformation:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func refresh(_ sender: Any) {
        indicateNetworkActivity(true)
        currentSessionTask = APIClient.getStudentLocation(limit: limit, completion: handleLocationDataResponse(studentsInformation:error:))
    }
    
    @IBAction func logout(_ sender: Any) {
        indicateNetworkActivity(true)
        logoutBarButton.isEnabled = false
        currentSessionTask?.cancel()
        APIClient.logout(completion: handleLogoutResponse)
    }
    
    func handleLocationDataResponse(studentsInformation: [StudentInformation], error: Error?) {
        guard error == nil else {
            if logoutBarButton.isEnabled {
                AlertController.showAlert(title: "Get Locations Failed", message: error?.localizedDescription, on: self)
                indicateNetworkActivity(false)
            }
            return
        }
        StudentInformationModel.studentsInformation = studentsInformation
        let selectedVC = selectedViewController as! DataViewControllerProtocol
        selectedVC.reloadData()
        indicateNetworkActivity(false)
    }
    
    func handleLogoutResponse() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func indicateNetworkActivity(_ networkActivity: Bool) {
        refreshBarButton.isEnabled = !networkActivity
        addPinBarButton.isEnabled = !networkActivity
    }
}
