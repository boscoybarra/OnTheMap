//
//  OTMClient.swift
//  OnTheMap
//
//  Created by J B on 6/14/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    // MARK: Properties
    
    static var session = URLSession.shared
    
    var requestedToken: String? = nil
    var sessionID: String? = nil
    var userID: String? = nil
    
    
    // MARK: GET SESSION
    
    @discardableResult static func taskForGETSession(uniqueKey: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        /* 1. Set the parameters */
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22"+"\(uniqueKey)"+"%22%7D"
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        
        /* 2/3. Build the UrL and configure the request */
        
        print("esta es la URL",request)
        request.addValue("\(Constants.ParseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("\(Constants.ApiKey)", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //make request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                return
            }
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse and use the data */
            self.parseJSONWithCompletionHandler(data: data as NSData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
        
    }

    
    
    // MARK: GET
    
    @discardableResult static func taskForGETMethod(method: String, parameters: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        /* 1. Set the parameters */
      
        let url = self.parseURLFromParameters(parameters, withPathExtension: method)
        
        let request = NSMutableURLRequest(url: url)
        
        /* 2/3. Build the UrL and configure the request */
        
        print("esta es la URL",request)
        request.addValue("\(Constants.ParseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("\(Constants.ApiKey)", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //make request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                return
            }
          
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse and use the data */
            self.parseJSONWithCompletionHandler(data: data as NSData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
        
    }
    
    // MARK: PUT/POST
    
    @discardableResult static func taskForWriteMethod(method: String, httpMethod: Write, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: self.parseURLFromParameters(nil, withPathExtension: method))
        
        request.httpMethod = httpMethod.rawValue
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: JSONBodyKeys.ApplicationID)
        request.addValue(Constants.ApiKey, forHTTPHeaderField: JSONBodyKeys.ApiKey)
        request.addValue(Constants.JSONApplication, forHTTPHeaderField: JSONBodyKeys.ContentType)
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error.debugDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            self.parseJSONWithCompletionHandler(data: data as NSData, completionHandler: completionHandlerForPOST)
        }
        task.resume()
        return task
    }
    
    
    // MARK: Helpers
    
    
    // given raw JSON, return a usable Foundation object
    private static func parseJSONWithCompletionHandler(data: NSData, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult, nil)
        
    }

    
    
    // create a URL from parameters
    private static func parseURLFromParameters(_ parameters: [String:AnyObject]?, withPathExtension: String?) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = OTMClient.Constants.ApiHost
        components.path = OTMClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        guard let parameters = parameters else {
            return components.url!
        }
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    

}
