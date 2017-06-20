//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by J B on 6/8/17.
//  Copyright © 2017 J B. All rights reserved.
//

    // MARK: OTMConstants

    extension OTMClient {
        
    struct Constants {
        
        // MARK: API Key
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
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

    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        // MARK: Locations
        
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
        
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
        static let Hundred = "10"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
    
        
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
    
}


