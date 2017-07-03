//
//  PostVerificationViewController.swift
//  OnTheMap
//
//  Created by J B on 6/8/17.
//  Copyright © 2017 J B. All rights reserved.
//

import UIKit
import MapKit

class PostVerificationViewController: UIViewController {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    let backgroundView = UIView()
    
    var mediaURL: URL? = nil
    
    @IBOutlet weak var finishButton: UIButton!
    
    static var placemark: CLPlacemark? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishButton.layer.cornerRadius = 5.0
        finishButton.clipsToBounds = true
        
        let backBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back-arrow"), style: .plain, target: self, action: #selector(back))
        backBarButtonItem.tintColor = OTMClient.Color.blue
        self.navigationItem.setLeftBarButton(backBarButtonItem, animated: false)
        
        self.mapView.showAnnotations([MKPlacemark(placemark: PostVerificationViewController.placemark!)], animated: true)
        finishButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func finish() {
        
        guard isConnectedToNetwork() else {
            presentErrorAlertController("Network Connection Error", alertMessage: "No network connection, please try again later")
            return
        }
        
        self.state(state: .loading, activityIndicator: activityIndicator, background: backgroundView)
        print("finish button is tapped")
        let uniqueKey = UserDefaults.standard.value(forKey: "uniqueKey") as! String
        OTMClient.getStudentLocation(uniqueKey: uniqueKey) { (student: Student?, error: NSError?) in
            guard error == nil else{
                print(error.debugDescription)
                return
            }
            
            var studentToPut = student!
            
            studentToPut.firstName = student!.firstName!
            studentToPut.lastName = student!.lastName
            studentToPut.uniqueKey = student!.uniqueKey
            studentToPut.mediaURL = self.mediaURL!
            
            if let placemark = PostVerificationViewController.placemark {
                let city = placemark.locality!
                let state = placemark.administrativeArea ?? placemark.isoCountryCode
                
                studentToPut.location!.mapString = "\(city) , \(state!)"
                
                let location = placemark.location!
                let coordinate = location.coordinate
                studentToPut.location!.latitude = Double(coordinate.latitude)
                studentToPut.location!.longitude = Double(coordinate.longitude)
            }
            
            if error == nil {
                OTMClient.putStudentLocation(student: studentToPut, completion: { (error: NSError?) in
                    if error == nil {
                        
                        self.executeOnMain {
                            self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    } else {
                        self.executeOnMain {
                            self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                        }
                    }
                })
                
            } else {
                
                OTMClient.postStudentLocation(student: studentToPut, completion: { (error: NSError?) in
                    if error == nil {
                        self.executeOnMain {
                            self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        
                    } else {
                        self.executeOnMain {
                            self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                            self.presentErrorAlertController("Error", alertMessage: "Error to post new information")
                        }
                    }
                })
                
            }
            
        }
    }
    
}

