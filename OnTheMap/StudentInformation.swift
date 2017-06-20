//
//  StudentInformation.swift
//  udacity-on-the-map
//
//  Created by Bosco Ybarra on 6/14/17.
//  Copyright (c) Bosco Ybarra. All rights reserved.
//

import Foundation

// MARK: - StudentInformation

struct StudentInformation {
    
    // MARK: Properties
    
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectID: String
    var uniqueKey: String
    var createdAt: NSDate
    var updatedAt: NSDate
    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init(dictionary: [String:AnyObject]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.firstName = dictionary[OTMClient.JSONResponseKeys.First_Name] as! String
        self.lastName = dictionary[OTMClient.JSONResponseKeys.Last_Name] as! String
        self.latitude = dictionary[OTMClient.JSONBodyKeys.Latitude] as! Double
        self.longitude = dictionary[OTMClient.JSONBodyKeys.Longitude] as! Double
        self.mapString = dictionary[OTMClient.JSONBodyKeys.MapString] as! String
        self.mediaURL = dictionary[OTMClient.JSONBodyKeys.MediaURL] as! String
        self.objectID = dictionary[OTMClient.JSONResponseKeys.ObjectID] as! String
        self.uniqueKey = dictionary[OTMClient.JSONBodyKeys.UniqueKey] as! String
        self.createdAt = dateFormatter.date(from: dictionary[OTMClient.JSONBodyKeys.CreatedAt] as! String)! as NSDate
        self.updatedAt = dateFormatter.date(from: dictionary[OTMClient.JSONBodyKeys.UpdatedAt] as! String)! as NSDate
        
  
    }
    
    static func studentsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studentData = [StudentInformation]()
        
        // iterate through array of dictionaries, for each student in a dictionary
        for result in results {
            studentData.append(StudentInformation(dictionary: result))
        }
        
        return studentData
    }
}

// MARK: - StudentInformation: Equatable

extension StudentInformation: Equatable {}

func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.uniqueKey == rhs.uniqueKey
}
