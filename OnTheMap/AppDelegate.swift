//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by J B on 6/8/17.
//  Copyright © 2017 J B. All rights reserved.
//

import UIKit
import CoreData


// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?
    
    var sharedSession: URLSession = URLSession.shared
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Initial", bundle: nil)
        let initialViewController: InitialViewController = mainStoryboard.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        
        return true
    }

}
