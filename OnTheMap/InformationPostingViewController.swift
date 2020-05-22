//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-21.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if StudentInformationPosting.userInfoRetrieved {
            locationTextField.text = StudentInformationPosting.locationText
            linkTextField.text = StudentInformationPosting.studentInformationPostingRequest?.mediaURL
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        let location = locationTextField.text!
        let link = linkTextField.text!
        StudentInformationPosting.locationText = location
        StudentInformationPosting.studentInformationPostingRequest?.mediaURL = link
        guard !location.isEmpty && !link.isEmpty else {
            AlertController.showAlert(title: "Incomplete Information", message: "Please enter location and link.", on: self)
            return
        }
        indicateNetworkActivity(true)
        CLGeocoder().geocodeAddressString(location, completionHandler: handleGeocodeResponse(placemark:error:))
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleGeocodeResponse(placemark: [CLPlacemark]?, error: Error?) {
        indicateNetworkActivity(false)
        guard let placemark = placemark else {
            AlertController.showAlert(title: "Geocoding Failed", message: error?.localizedDescription, on: self)
            return
        }
        guard placemark.count > 0 else {
            AlertController.showAlert(title: "Geocoding Failed", message: "No corresponding placemarks to the entered location.", on: self)
            return
        }
        let controller = storyboard?.instantiateViewController(withIdentifier: "InformationPostingMapViewController") as! InformationPostingMapViewController
        controller.placemark = placemark[0]
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func indicateNetworkActivity(_ networkActivity: Bool) {
        if networkActivity {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        changeButtonTraits(button: findButton, isEnabled: !networkActivity, alpha: networkActivity ? 0.5 : 1.0)
        cancelBarButton.isEnabled = !networkActivity
        locationTextField.isEnabled = !networkActivity
        linkTextField.isEnabled = !networkActivity
    }
    
    func changeButtonTraits(button: UIButton, isEnabled: Bool, alpha: CGFloat) {
        button.isEnabled = isEnabled
        button.alpha = alpha
    }
    
}
