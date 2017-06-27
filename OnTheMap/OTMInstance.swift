//
//  OTMInstance.swift
//  OnTheMap
//
//  Created by J B on 6/26/17.
//  Copyright © 2017 J B. All rights reserved.
//

import Foundation

class OTMInstance : NSObject {

// MARK: Shared Instance
class func sharedInstance() -> OTMInstance {
    struct Singleton {
        static var sharedInstance = OTMInstance()
    }
    return Singleton.sharedInstance
}

}

