//
//  InformationPostingMapViewController.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-21.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InformationPostingMapViewController: UIViewController, MKMapViewDelegate, DataViewControllerProtocol {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    var placemark: CLPlacemark? = nil
    var currentSessionTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeButtonTraits(button: finishButton, isEnabled: false, alpha: 0.5)
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentSessionTask?.cancel()
    }
    
    func reloadData() {
        mapView.removeAnnotations(mapView.annotations)
        
        guard let placemark = placemark else {
            AlertController.showAlert(title: "Error", message: "No placemark object. Please go back to edit the location and try again.", on: self)
            return
        }
        
        guard let coordinate = placemark.location?.coordinate else {
            AlertController.showAlert(title: "Error", message: "Cannot retrieve map coordination. Please go back to edit the location and try again.", on: self)
            return
        }
        
        let title = [placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode, placemark.country].compactMap({ $0 }).joined(separator: ", ")
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        changeButtonTraits(button: finishButton, isEnabled: true, alpha: 1)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func changeButtonTraits(button: UIButton, isEnabled: Bool, alpha: CGFloat) {
        button.isEnabled = isEnabled
        button.alpha = alpha
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}