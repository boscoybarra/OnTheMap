//
//  SafariServices.swift
//  OnTheMap
//
//  Created by J B on 6/14/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation
import SafariServices

extension UIViewController {
    func presentURLInSafariViewController(stringURL: String) {
        
        guard let url = URL(string: stringURL) else {
            return
        }
        if url.scheme != nil {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            if let schemedURL = URL(string: "http://" + stringURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(schemedURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(schemedURL)
                }
            } else {
                presentErrorAlertController("Sorry", alertMessage: "The page you try to visit has no valid URL")
            }
        }
    }
}
