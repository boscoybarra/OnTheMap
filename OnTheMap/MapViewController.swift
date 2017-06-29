//
//  MapViewController.swift
//  PinSample
//
//  Created by Jason on 3/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

/**
 * This view controller demonstrates the objects involved in displaying pins on a map.
 *
 * The map is a MKMapView.
 * The pins are represented by MKPointAnnotation instances.
 *
 * The view controller conforms to the MKMapViewDelegate so that it can receive a method
 * invocation when a pin annotation is tapped. It accomplishes this using two delegate
 * methods: one to put a small "info" button on the right side of each pin, and one to
 * respond when the "info" button is tapped.
 */

class MapViewController: MainViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        mapView.delegate = self
        super.viewDidLoad()
        
        executeOnMain(withDelay: 1.0) {
            self.state(state: .loading, activityIndicator: self.activityIndicator, background: self.backgroundView)
            
            self.getAnnotations { (annotations: [MKPointAnnotation]) in
                self.executeOnMain {
                    self.mapView.addAnnotations(annotations)
                    self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                    
                }
            }
        }
    }
    
    override func refresh() {
        super.refresh()
        DataSource.getStudents {
            self.executeOnMain {
                self.mapView.reloadInputViews()
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        pinView?.detailCalloutAccessoryView?.tintColor = OTMClient.Color.green
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = OTMClient.Color.magenta
            
            let button = UIButton(type: .detailDisclosure)
            button.tintColor = OTMClient.Color.green
            pinView!.rightCalloutAccessoryView = button
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            if let annotationSubtitle = view.annotation?.subtitle! {
                self.presentURLInSafariViewController(stringURL: annotationSubtitle)
            }
        }
    }
    
}
