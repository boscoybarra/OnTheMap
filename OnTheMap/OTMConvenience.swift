//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by J B on 6/14/17.
//  Copyright © 2017 J B. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension OTMClient {
    
    
    func postSession(username: String, password: String, completionHandler: @escaping (_ result: String?, _ error: NSError?) -> Void){
        let method = Methods.SessionID
        let jsonBody = [
            JSONBodyKeys.Udacity : [
                JSONBodyKeys.Username : username,
                JSONBodyKeys.Password : password
            ],
        ]
        
        let _ = taskForPostMethod(method: method, jsonBody: jsonBody as [String : AnyObject]) { (JSONResult, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let dictionary = JSONResult! [JSONResponseKeys.Account] as? [String : AnyObject] {
                if let result = dictionary[JSONResponseKeys.Key] as? String {
                    print("Hello Bosco data", dictionary)
                    completionHandler(result, nil)
                } else {
                    completionHandler(nil, NSError(domain: "postSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse session"]))
                }
            } else {
                completionHandler(nil, NSError(domain: "postSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse session"]))
                
            }
        }
        
    }
    
    //MARK: -- Function GETs the last 100 student locations created
    func getStudentLocations(completionHandler: @escaping (_ result: [StudentInformation]?, _ error: NSError?) -> Void){
        
        /* 1. Set the parameters */
        let parameters = [JSONBodyKeys.Limit: JSONBodyKeys.Hundred]
        
        let _ = taskForGetMethod(method:Methods.StudentLocation, parameters: parameters as [String : AnyObject]) {(results, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            // This is where the magic takes place, we append all the Json data into an dictionary
            if let results = results?[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                let locations = StudentInformation.studentsFromResults(results)
                completionHandler(locations, nil)
            } else {
                completionHandler(nil, NSError(domain: "getStudentLocations", code: 0, userInfo:  [NSLocalizedDescriptionKey: "Could not parse student data"]))
            }
            
        }
        
    }
    
    // POSTing students info
    func postStudentLocation(jsonBody: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let method = Methods.StudentLocation
        
        let _ = taskForPostMethod(method: method, jsonBody: jsonBody) { (JSONResult, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let result = JSONResult?[JSONResponseKeys.ObjectID] as? String {
                completionHandler(result as AnyObject, nil)
            } else {
                completionHandler(nil, NSError(domain: "postStudentLocations parsing", code: 0, userInfo:  [NSLocalizedDescriptionKey: "Could not parse student location"]))
            }
        }
    }
    
    //PUTing students location
    func putStudentLocation(objectID: String, jsonBody: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let method = Methods.StudentLocation
        
        let _ = taskForPutMethod(method: method, parameters: objectID, jsonBody: jsonBody) {(JSONResult, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let result = JSONResult?[JSONBodyKeys.UpdatedAt] as? String {
                completionHandler(result as AnyObject, nil)
            } else {
                completionHandler(nil, NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse student location"]))
            }
        }
    }
    
    func queryForAStudent(completionHandler: @escaping (_ result: [[String:AnyObject]]?, _ error: NSError?) -> Void) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let parameters = [OTMClient.JSONResponseKeys.ObjectID : appDelegate.userID]
        
        let _ = taskForGetMethod(method: Methods.StudentLocation, parameters: parameters as [String : AnyObject]) {(JSONResult, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let results = JSONResult?[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                completionHandler(results, nil)
            } else {
                completionHandler(nil, NSError(domain: "getStudentLocations", code: 0, userInfo:  [NSLocalizedDescriptionKey: "Could not parse student data"]))
            }
        }
    }
    
    
    
    //MARK: -- Function that DELETEs the current session
    func deleteSession(completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
    

}
