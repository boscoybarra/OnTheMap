//
//  GCD.swift
//  OnTheMap
//
//  Created by J B on 6/8/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
