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
        getLocationData()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAfterLocationUpdate(_:)), name: NSNotification.Name(rawValue: "RefreshNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentSessionTask?.cancel()
    }
    
    @IBAction func refresh(_ sender: Any) {
        getLocationData()
    }
    
    @objc func refreshAfterLocationUpdate(_ notification: Notification) {
        getLocationData()
    }
    
    func getLocationData() {
        indicateNetworkActivity(true)
        currentSessionTask = APIClient.getStudentLocations(limit: limit, completion: handleLocationDataResponse(studentsInformation:error:))
    }
    
    @IBAction func addPin(_ sender: Any) {
        let informationPostingNC = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingNavController") as! UINavigationController
        if StudentInformationPosting.userInfoRetrieved {
            if StudentInformationPosting.objectId == nil {
                present(informationPostingNC, animated: true, completion: nil)
            }
            else {
                showAlertOKCancel(title: "Student Location Existed", message: "You have already posted a student location. Would you like to overwrite your current location?", on: self) {
                    self.present(informationPostingNC, animated: true, completion: nil)
                }
            }
        }
        else {
            indicateNetworkActivity(true)
            currentSessionTask = APIClient.getPublicUserData { (success, error) in
                guard success else {
                    if self.logoutBarButton.isEnabled {
                        self.showAlert(title: "Get User Data For Pin Adding Failed", message: error?.localizedDescription, on: self)
                        self.indicateNetworkActivity(false)
                    }
                    return
                }
                self.present(informationPostingNC, animated: true, completion: nil)
                self.indicateNetworkActivity(false)
            }
        }
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
                showAlert(title: "Get Locations Failed", message: error?.localizedDescription, on: self)
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
        StudentInformationPosting.clear()
        navigationController?.popToRootViewController(animated: true)
    }
    
    func indicateNetworkActivity(_ networkActivity: Bool) {
        refreshBarButton.isEnabled = !networkActivity
        addPinBarButton.isEnabled = !networkActivity
    }
}
