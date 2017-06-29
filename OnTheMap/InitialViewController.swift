//
//  InitialViewController.swift
//  OnTheMap
//
//  Created by J B on 6/26/17.
//  Copyright © 2017 J B. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isLoggedIn() {
            self.presentMainView(animate: true)
        } else {
            self.presentLoginView(animate: true)
        }
    }
    
    func isLoggedIn() -> Bool {
        if UserDefaults.standard.value(forKey: "uniqueKey") as? String != nil {
            return true
        } else {
            return false
        }
    }
    
    // Presenting Main view
    func presentMainView(animate: Bool) -> Void {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "MapTabController")
        if animate {
            print(homeTabBarController)
            self.present(homeTabBarController, animated: true, completion: nil)
        } else {
            self.present(homeTabBarController, animated: false, completion: nil)
        }
    }
    
    // Presenting Login view
    func presentLoginView(animate: Bool) -> Void {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let logInViewController = storyBoard.instantiateViewController(withIdentifier: "LogInViewController")
        if animate {
            self.present(logInViewController, animated: true, completion: nil)
        } else {
            self.present(logInViewController, animated: false, completion: nil)
        }
    }
}
