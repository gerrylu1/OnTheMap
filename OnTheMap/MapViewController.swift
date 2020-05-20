//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-20.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let limit:Int = 100
    
    var currentSessionTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSessionTask = APIClient.getStudentLocation(limit: limit, completion: handleLocationDataResponse(studentsInformation:error:))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(self.refresh))
    }
    
    @objc func refresh() {
        currentSessionTask = APIClient.getStudentLocation(limit: limit, completion: handleLocationDataResponse(studentsInformation:error:))
    }
    
    func handleLocationDataResponse(studentsInformation: [StudentInformation], error: Error?) {
        guard error == nil else {
            AlertController.showAlert(title: "Get Locations Failed", message: error?.localizedDescription, on: self)
            return
        }
        StudentInformationModel.studentsInformation = studentsInformation
        loadLocationDataOnMap()
    }
    
    func loadLocationDataOnMap() {
        var annotations = [MKPointAnnotation]()
        
        for studentInformation in StudentInformationModel.studentsInformation {
            let latitude = CLLocationDegrees(studentInformation.latitude)
            let longitude = CLLocationDegrees(studentInformation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let title = "\(studentInformation.firstName) \(studentInformation.lastName)"
            let mediaURL = studentInformation.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = title
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                if let url = URL(string: toOpen ?? "") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
}
