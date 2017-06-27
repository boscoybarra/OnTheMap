//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by J B on 6/8/17.
//  Copyright © 2017 J B. All rights reserved.
//

// MARK: OTMConstants

import Foundation
import UIKit

extension OTMClient {
        
    struct Constants {
        
        // MARK: API Key
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let JSONApplication = "application/json"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
        static let FullURL = "https://parse.udacity.com/parse/classes"

    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Locations
        static let StudentLocation = "/StudentLocation"
        static let StudentLocationWithID = "/StudentLocation/{objectId}"
        static let SessionID = "https://www.udacity.com/api/session"
    
    }
    
    // MARK: Request Type
    enum Write: String {
        case PUT = "PUT"
        case POST = "POST"
    }

    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        // MARK: Locations
        
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Where = "where"
        
        // MARK: API Requests ParameterKeys
        static let ApiKey = "X-Parse-REST-API-Key"
        static let ApplicationID = "X-Parse-Application-Id"
        static let ContentType = "Content-Type"
        
        
        // MARK: Dates
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        
        // MARK: Authorization
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        
        // MARK: General
        static let Method = "method"
        static let Limit = "limit"
        static let Hundred = "100"
        static let Order = "order"
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        static let LastUpdated = "-updatedAt"
    
        
        // MARK: Authorization
        static let UserID = "id"
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        static let Session = "session"
        static let Account = "account"
        static let Key = "key"
        static let Registered = "registered"
        static let Id = "id"
        static let User = "user"
        static let Last_Name = "lastName"
        static let First_Name = "firstName"
        static let Results = "results"
        static let ObjectID = "objectId"

    }
        
    struct Color {
        static let blue = UIColor(red: 21/255, green: 164/255, blue: 222/255, alpha: 1.0)
        static let purple = UIColor(red: 151/255, green: 499/255, blue: 233/255, alpha: 1.0)
        static let magenta = UIColor(red: 251/255, green: 57/255, blue: 112/255, alpha: 1.0)
        static let green = UIColor(red: 25/255, green: 195/255, blue: 192/255, alpha: 1.0)
        
    }
    
}


