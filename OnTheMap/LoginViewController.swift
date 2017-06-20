//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by J B on 6/8/17.
//  Copyright © 2017 J B. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //TODO configureUI()
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debugTextLabel.text = ""
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        userDidTapView(self)
        /* Disable the buttons in the UIonce the Login button has been pressed */
        enableButtons(sender: sender as! UIButton)
        
        /* Show activity to show the app is processing data */
        let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityView.center = view.center
        activityView.startAnimating()
        view.addSubview(activityView)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            OTMClient.sharedInstance().postSession(username:usernameTextField.text!, password:passwordTextField.text! ) { (result, error) in
                
                /* GUARD: Was there an error? */
                guard error == nil else {
                    
                    /* Check to see what type of error occured */
                    if let errorString = error?.userInfo[NSLocalizedDescriptionKey] as? String {
                        
                        /* Display an alert and shake the view letting the user know the authentication failed */
                        DispatchQueue.main.async(execute: {
                            
                            self.showAuthenticationAlert(errorString: errorString)
                            self.shakeScreen()
                            activityView.stopAnimating()
                        })
                    }
                    return
                }
                
                self.appDelegate.userID = result!
                
                DispatchQueue.main.async(execute: {
                     if (result != nil) {
                    
                    // Display the tabbed view controller
                    self.completeLogin()
                    self.enableButtons(sender: sender as! UIButton)
                    activityView.stopAnimating()
                        
                    } else {
                    self.displayError(String(describing: error))
                    }
                })
                
            }
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            // TODO self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapTabController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    //MARK: -- Error helper functions
    
    //Functions that presents an alert to the user with a reason as to why their login failed
    func showAuthenticationAlert(errorString: String){
        let titleString = "Authentication failed!"
        var errorString = errorString
        
        if errorString.range(of: "400") != nil{
            errorString = "Please enter your email address and password."
        } else if errorString.range(of: "403")  != nil {
            errorString = "Wrong email address or password entered."
        } else if errorString.range(of: "1009") != nil {
            errorString = "Something is wrong with the network connection."
        } else {
            errorString = "Something went wrong! Try again"
        }
        
        self.showAlert(alertTitle: titleString, alertMessage: errorString, actionTitle: "Try again")
    }
    
    //MARK: -- User interface helper functions
    //Function sets up the user interface
    
    //Function to enable the login button
    func enableButtons(sender: UIButton){
        loginButton.isEnabled = true
        sender.alpha = 1.0
    }

    
    
    //Function that configures and shows an alert
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        
        /* Present the alert view */
        self.present(alert, animated: true, completion: nil)
    }
    
    //Function that animates the screen to show login has failed
    func shakeScreen(){
        
        /*Configure a shake animation */
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.07
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = CGPoint(x:self.mainView.center.x - 10, y:self.mainView.center.y - 10)
        shakeAnimation.toValue = CGPoint(x:self.mainView.center.x + 10, y:self.mainView.center.y + 10)
        
        /* Shake the view */
        self.mainView.layer.add(shakeAnimation, forKey: "position")
    }
    
    //MARK: -- Text field delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            movieImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            movieImageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}








// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func displayError(_ errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }
}
