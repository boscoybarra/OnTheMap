//
//  GCD.swift
//  OnTheMap
//
//  Created by Zulwiyoza Putra on 2/16/17.
//  Copyright © 2017 zulwiyozaputra. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func executeOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func executeOnMain(withDelay timeInSecond: Double, _ updates: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInSecond, execute: {
            updates()
        })
    }
}

