//
//  UITextFieldDelegate.swift
//  OnTheMap
//
//  Created by J B on 6/27/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
