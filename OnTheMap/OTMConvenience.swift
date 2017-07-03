//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by J B on 6/14/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation
import UIKit


enum RequestError: Error {
    case failedRequest
    case badResponse
    case noDataReturned
    case parsingFailed
    case noSessionDataReturned
    case noAccountDataReturned
    case noAccountRegistered
    case other
}


// MARK: - TMDBClient (Convenient Resource Methods)

extension OTMClient {
    
    
    static func postSession(username: String, password: String, completionHandler: @escaping (_ error: RequestError?, _ errorDescription: String?) -> Void) {
    
        let postSessionURL = URL(string: "https://www.udacity.com/api/session")!
        
        var request = URLRequest(url: postSessionURL)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            let range = Range(uncheckedBounds: (5, data!.count))
            let decryptedData = data?.subdata(in: range)
            
            guard (error == nil) else {
                print(error.debugDescription)
                completionHandler(.failedRequest, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandler(.badResponse, nil)
                return
            }
            
            guard let data = decryptedData else {
                completionHandler(.noDataReturned, nil)
                return
            }
            
            let parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
            } catch {
                completionHandler(.parsingFailed, nil)
                return
            }

            
            let isStatusCode2XX = (statusCode<300) && (199<statusCode)
            
            if isStatusCode2XX {
                
                guard let sessionData = parsedResult["session"] as? [String: AnyObject], let expiration = sessionData["expiration"] as? String, let id = sessionData["id"] as? String else {
                    completionHandler(.noSessionDataReturned, nil)
                    return
                }
                
                guard let accountData = parsedResult["account"] as? [String: AnyObject], let key = accountData["key"] as? String else {
                    completionHandler(.noAccountDataReturned, nil)
                    return
                }
                
                let session = SessionManager.Session(id: id, key: key, expiration: expiration)
                
                SessionManager.session = session
                let uniqueKey = session.key
                UserDefaults.standard.set(uniqueKey, forKey: "uniqueKey")
                
                completionHandler(nil, nil)
                
                
            } else {
                
                guard let errorDescription = parsedResult["error"] as? String else {
                    return
                }
                
                completionHandler(.other, errorDescription)
            }
            
        }
        
        task.resume()
    }

    
    //MARK: -- Function GETs the last 300 student locations created
    static func getStudentsLocation(completion: @escaping (_ students: [Student]?, _ error: NSError?) -> Void) {
        
        let parameters = [
            "limit": "300",
            JSONBodyKeys.Order : JSONResponseKeys.LastUpdated] as [String: AnyObject]
        
        
        OTMClient.taskForGETMethod(method: Methods.StudentLocation, parameters: parameters) { (data: AnyObject?, error: NSError?) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error.debugDescription)")
                return
            }
            
            guard let results = data!["results"] as? [[String : AnyObject]] else {
                sendError("No data was returned by the request!")
                return
            }
            
            var students: [Student] = []
            
            for result in results {
                
                let location = Location(dictionary: result)
                
                if location.coordinate != nil {
                    
                    let student = Student(dictionary: result, location: location)
                    
                    let firsNameHasEmptyString = student.firstName == nil || student.firstName == ""
                    
                    let lastNameHasEmptyString = student.lastName == nil || student.lastName == ""
                    
                    if !firsNameHasEmptyString || !lastNameHasEmptyString {
                        
                        students.append(student)
                        
                    } else {
                        
                        // Handle no name student error here
                    }
                    
                } else {
                    
                    // Handle no location student error here
                    
                }
            }
            
            DataSource.students = students
            
            completion(students, nil)
            
        }
    }
    
    // POSTing students info
    static func postStudentLocation(student: Student, completion: @escaping (_ error: NSError?) -> Void) {
        let method = Methods.StudentLocation
        
        let jsonBody = "{\"uniqueKey\": \"\(student.uniqueKey!)\", \"firstName\": \"\(student.firstName ?? "")\", \"lastName\": \"\(student.lastName ?? "")\",\"mapString\": \"\(String(describing: student.location!.mapString!))\", \"mediaURL\": \"\(String(describing: student.mediaURL!))\",\"latitude\": \(String(describing: student.location!.latitude!)), \"longitude\": \(student.location!.longitude!)}"
        
        OTMClient.taskForWriteMethod(method: method, httpMethod: .POST, jsonBody: jsonBody) { (result: AnyObject?, error: NSError?) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error.debugDescription)")
                return
            }
            
            guard result!["updatedAt"] != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            completion(nil)
        }
        
    }
    
    //PUTing students location
    static func putStudentLocation(student: Student, completion: @escaping (_ error: NSError?) -> Void) {
        let method = Methods.StudentLocation + "/" + student.objectId!
        
        let jsonBody = "{\"uniqueKey\": \"\(student.uniqueKey!)\", \"firstName\": \"\(student.firstName ?? "")\", \"lastName\": \"\(student.lastName ?? "")\",\"mapString\": \"\(String(describing: student.location!.mapString!))\", \"mediaURL\": \"\(String(describing: student.mediaURL!))\",\"latitude\": \(String(describing: student.location!.latitude!)), \"longitude\": \(student.location!.longitude!)}"
        
        OTMClient.taskForWriteMethod(method: method, httpMethod: .PUT, jsonBody: jsonBody) { (result: AnyObject?, error: NSError?) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error.debugDescription)")
                return
            }
            
            guard result!["updatedAt"] != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            completion(nil)
        }
        
    }
    
    static func getStudentLocation(uniqueKey: String, completionHandler: @escaping (_ student: Student?, _ error: NSError?) -> Void) {
        
        
        let _ = taskForGETSession(uniqueKey: uniqueKey) {(data, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForGETSession", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error.debugDescription)")
                return
            }
            
            guard let result = data?["results"] as? [[String : AnyObject]] else {
                sendError("No data was returned by the request!")
                return
            }
            
            print("Estos son los resultados", result)
            
            let studentDictionary = result[0]
            let location = Location(dictionary: studentDictionary)
            let student = Student(dictionary: studentDictionary, location: location)
            
            completionHandler(student, nil)
            
        }
    }
    
    
    
    //MARK: -- Function that DELETEs the current session
    static func deleteSession(completion: @escaping () -> Void) {
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
            
            if error != nil {
                print(error!)
                return
            }
            
            let range = Range(5..<data!.count)
            let _ = data?.subdata(in: range)
            
            completion()
        }
        task.resume()
    }
}

// Log Out Dialogue Box

extension MapViewController {
    override func logOutDialogueBox(completion: (@escaping () -> Void)) {
        let alert = UIAlertController(title: "Log Out", message: "Are You Sure Want To Log Out?", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let logOut = UIAlertAction(title: "Log Out", style: .destructive) { (action: UIAlertAction) in
            completion()
        }
        alert.addAction(logOut)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
}
