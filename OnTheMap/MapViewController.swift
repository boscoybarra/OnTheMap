//
//  MapViewController.swift
//  PinSample
//
//  Created by Jason on 3/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var locations = StudentDataSource.sharedInstance.studentData
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getStudentsData()
        setupNavigationBar()
    }
    
    //Fuction that configures the navigation bar
    func setupNavigationBar(){
        
        /*Set the back button on the navigation bar to be logged out */
        let customLeftBarButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(MapViewController.deleteSession))
        navigationItem.setLeftBarButton(customLeftBarButton, animated: false)
        
        /* Set the title of the navigation bar to be On The Map */
        self.navigationItem.title = "On The Map"
        
        /* Create an array of bar button items */
        var customButtons = [UIBarButtonItem]()
        
        /* Create pin button */
        let pinImage = UIImage(named: "icon_pin")
        let pinButton = UIBarButtonItem(image: pinImage, style: .plain, target: self, action: #selector(MapViewController.presentInformationPostingViewController))
        
        /* create refresh button */
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(MapViewController.getStudentsData))
        
        /* Add the buttons to the array */
        customButtons.append(refreshButton)
        customButtons.append(pinButton)
        
        /* Add buttons to nav bar */
        navigationItem.setRightBarButtonItems(customButtons, animated: false)
        
    }
    
    
    //Function that presents the Information Posting View Controller
    func presentInformationPostingViewController(){
        
        OTMClient.sharedInstance().queryForAStudent() {(result, error) in
            
            guard error == nil else {
                let alertTitle = "Error fetching student data"
                let alertMessage = "Something went wrong when checking to see if you have already posted your location"
                let actionTitle = "Try Again"
                
                DispatchQueue.main.async(execute: {
                    self.showAlert(alertTitle: alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                })
                return
            }
            
            if result?.count != 0 {
                let resultArray = result?[0]
                print("This is the Array",resultArray!)
                let objectID = resultArray?[OTMClient.JSONResponseKeys.ObjectID]
                print("This is the objectID",objectID!)
                self.appDelegate.objectID = objectID as! String
                self.showOverwriteLocationAlert()
            }
        }
    }

    
    //Function that is called when the logout button is pressed
    func deleteSession() {
        OTMClient.sharedInstance().deleteSession() {(result, error) in
            
            guard error == nil else {
                let alertTitle = "Couldn't log out!"
                let alertMessage = error?.userInfo[NSLocalizedDescriptionKey] as? String
                let actionTitle = "Try Again"
                
                DispatchQueue.main.async(execute: {
                    self.showAlert(alertTitle: alertTitle, alertMessage: alertMessage!, actionTitle: actionTitle)
                })
                return
            }
        }
        
        /* Show the log in view controller */
        tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //MARK: -- Error helper functions
    
    func showOverwriteLocationAlert(){
        /* Prepare the strings for the alert */
        let userFirstName = self.appDelegate.userData[0]
        let userLastName = self.appDelegate.userData[1]
        let alertTitle = "Overwrite location?"
        let alertMessage = userFirstName + "" + userLastName + "do you really want to overwrite your existing location?"
        
        /* Prepare to overwrite for the alert */
        let overWriteAction = UIAlertAction(title: "Overwrite", style: .default) {(action) in
            /* instantiate and then present the view controller */
            let infoPostingViewController = self.storyboard!.instantiateViewController(withIdentifier: "InfoPostingViewController")
            self.present(infoPostingViewController, animated: true, completion: nil)
        }
        
        /* Prepare the cancel for the alert */
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(overWriteAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    
    //Function that populates the map with data
    func getStudentsData(){
        let activityView = UIView.init(frame: mapView.frame)
        activityView.backgroundColor = UIColor.gray
        activityView.alpha = 0.8
        view.addSubview(activityView)
        
        /* Show activity spinner */
        let activitySpinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activitySpinner.center = view.center
        activitySpinner.startAnimating()
        activityView.addSubview(activitySpinner)
        
        OTMClient.sharedInstance().getStudentLocations{(result, error) in
            
            guard error == nil else {
                let alertTitle = "Download failed"
                let alertMessage = "There was a problem fetching the student data."
                let actionTitle = "Try Again"
                
                DispatchQueue.main.async(execute: {
                    self.showAlert(alertTitle: alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                    activityView.removeFromSuperview()
                    activitySpinner.stopAnimating()
                })
                return
            }
            
            /* Clear any previously fetched student data */
            if !self.locations.isEmpty {
                self.locations.removeAll()
            }
            
            /* For each student in the returned results add it to the StudentDataStore */
            if let locations = result {
                self.locations = locations
                performUIUpdatesOnMain {
                    self.populateMapWithStudentData()
                    
                    activityView.removeFromSuperview()
                    activitySpinner.stopAnimating()
                }
            } else {
                print(error ?? "empty error")
            }
            
        }
    }
        
    //Function that populates the map with data
    func populateMapWithStudentData(){
        
        /* Remove any pins previously on the map to avoid duplicates */
        if !mapView.annotations.isEmpty{
            mapView.removeAnnotations(mapView.annotations)
        }
        
        var annotations = [MKPointAnnotation]()
        
        /* For each student in the data */
        for s in self.locations {
            
            /* Get the lat and lon values to create a coordinate */
            let lat = CLLocationDegrees(s.latitude)
            let lon = CLLocationDegrees(s.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            /* Make the map annotation with the coordinate and other student data */
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(s.firstName) \(s.lastName)"
            annotation.subtitle = s.mediaURL
            
            /* Add the annotation to the array */
            annotations.append(annotation)
        }
        /* Add the annotations to the map */
        mapView.addAnnotations(annotations)
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    //Function that configures and shows alert
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
            
    }
}
