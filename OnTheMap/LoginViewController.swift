//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by J B on 6/8/17.
//  Copyright © 2017 J B. All rights reserved.
//

import UIKit
class LogInViewController: UIViewController {
    
    // Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var thirdQuarterView: UIView!
    
    // MARK: Properties
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    let backgroundView = UIView()
    
    var appDelegate: AppDelegate!
    var email: String?
    var password: String?
    var validAccount: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        logInButton.layer.cornerRadius = 5.0
        logInButton.clipsToBounds = true
        
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        
    }
    
    @objc private func logIn() {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            presentErrorAlertController("", alertMessage: "Username and Password you entered are wrong")
        } else {
            
            email = emailTextField.text!
            password = passwordTextField.text!
            
            guard isConnectedToNetwork() else {
                presentErrorAlertController("Network Connection Error", alertMessage: "No network connection, please try again later")
                return
            }
            
            self.state(state: .loading, activityIndicator: self.activityIndicator, background: self.backgroundView)
            OTMClient.postSession(username: email!, password: password!) { (error: RequestError?, errorDescription: String?) in
                if error == nil {
                    self.executeOnMain {
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                    }
                    self.completeLogin(withLogin: true)
                } else {
                    if errorDescription == nil {
                        self.executeOnMain {
                            self.emailTextField.text = ""
                            self.passwordTextField.text = ""
                            self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                            self.displayError("Error \(error.debugDescription) occurs")
                        }
                        
                    } else {
                        self.executeOnMain {
                            self.emailTextField.text = ""
                            self.passwordTextField.text = ""
                            self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                            self.displayError(errorDescription!)
                        }
                    }
                }
            }
        }
        
        
    }
    
    @objc private func signUp() {
        guard isConnectedToNetwork() else {
            presentErrorAlertController("Network Connection Error", alertMessage: "No network connection, please try again later")
            return
        }
        let url = "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        self.presentURLInSafariViewController(stringURL: url)
    }
    
    // Complete Login
    private func completeLogin(withLogin: Bool) -> Void {
        executeOnMain {
            if withLogin {
                self.state(state: .normal, activityIndicator: self.activityIndicator, background: self.backgroundView)
                self.presentNextView(animate: true)
            } else {
                self.presentNextView(animate: false)
            }
            
        }
    }
    
    // Presenting next view
    func presentNextView(animate: Bool) -> Void {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyBoard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        if animate {
            self.present(mainTabBarController, animated: true, completion: nil)
        } else {
            self.present(mainTabBarController, animated: false, completion: nil)
        }
    }
    
    // Displaying error message
    func displayError(_ error: String) {
        executeOnMain {
            self.presentErrorAlertController("Error", alertMessage: error)
        }
    }
}
