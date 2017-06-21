//
//  StudentDataSource.swift
//  OnTheMap
//
//  Created by J B on 6/12/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation


class StudentDataSource {
    let studentData = [StudentInformation]()
    static let sharedInstance = StudentDataSource()
    private init() {} //This prevents others from using the default '()' initializer for this class.
}
