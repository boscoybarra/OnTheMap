//
//  OTMClient.swift
//  OnTheMap
//
//  Created by J B on 6/14/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    var session = URLSession.shared
    var sessionID: String?
    var uniqueKey: String?
 
    
    // MARK: POST
    
    func taskForPostMethod(method: String, jsonBody: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        let urlString = method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody, options: [])
        }
        
        //make request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            
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
            guard newData != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse and use the data */
            self.parseJSONWithCompletionHandler(data: newData! as NSData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
        
    }
    
    // MARK: GET
    
    func taskForGetMethod(method: String, parameters: [String : AnyObject]?, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        //build url and configure request
        var parametersWithApiKey = parameters
        
        /* 1. Set the parameters */
        let request = NSMutableURLRequest(url: tmdbURLFromParameters(parametersWithApiKey, withPathExtension: method))
        
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
    
    
    
    // MARK: PUT
    
    func taskForPutMethod(method: String, parameters: String, jsonBody: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        /* 2/3. Build the UrL and configure the request */
        let urlString = Constants.FullURL + method + "/" + parameters
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        }
        
        //make request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            
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
            guard newData != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse and use the data */
            self.parseJSONWithCompletionHandler(data: newData! as NSData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
        
    }
    
    
    // MARK: Helpers
    
    
    // given raw JSON, return a usable Foundation object
    private func parseJSONWithCompletionHandler(data: NSData, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
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
    private func tmdbURLFromParameters(_ parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = OTMClient.Constants.ApiHost
        components.path = OTMClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if parameters != nil {
        
        
        for (key, value) in parameters! {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        } else {

        print("Yo! You just sent me a nil value on the parameters, that cool!")
        }
        return components.url!
    }
    
    //Given a dictionary of parameters, convert string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
        
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}
