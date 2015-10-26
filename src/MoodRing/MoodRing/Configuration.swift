//
//  Configuration.swift
//  MoodRing
//
//  Created by Alexander Volkov on 08.10.15.
//  Copyright (c) 2015 Appirio. All rights reserved.
//

import Foundation

/**
* Configuration reads config from configuration.plist in the app bundle
*
* @author Alexander Volkov
* @version 1.0
*/
class Configuration: NSObject {
    
    /// the key for Salesforce SDK
    var salesforceKey = "<should be specified in configuration.plist>"
    
    /// the callback URI for Salesforce SDK
    var salesforceCallback = "http://localhost"
    
    /// flag used to switch between different user profiles in the prototype app
    var isManagerFlag = false
    
    /// shared instance of Configuration (singleton)
    class var sharedConfig: Configuration {
        struct Static {
            static let instance : Configuration = Configuration()
        }
        return Static.instance
    }
    
    /**
    Reads configuration file
    */
    override init() {
        super.init()
        self.readConfigs()
    }
    
    // MARK: private methods
    
    /**
    * read configs from plist
    */
    func readConfigs() {
        if let path = getConfigurationResourcePath() {
            let configDicts = NSDictionary(contentsOfFile: path)
            
            self.salesforceKey = configDicts?["salesforceKey"] as? String ?? self.salesforceKey
            self.salesforceCallback = configDicts?["salesforceCallback"] as? String ?? self.salesforceCallback
            self.isManagerFlag = configDicts?["isManagerFlag"] as? Bool ?? self.isManagerFlag
        }
        else {
            assert(false, "configuration is not found")
        }
    }
    
    /**
    Get the path to the configuration.plist.
    
    - returns: the path to configuration.plist
    */
    func getConfigurationResourcePath() -> String? {
        return NSBundle(forClass: Configuration.classForCoder()).pathForResource("configuration", ofType: "plist")
    }
}