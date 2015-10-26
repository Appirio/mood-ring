//
//  AuthenticationUtil.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/// the constants used to store profile data
let kProfileFunFactorIndex = "kProfileFunFactorIndex"
let kProfileFunFactorDate = "kProfileFunFactorDate"
let kProfileFunFactorComment = "kProfileFunFactorComment"

/**
* Utility for storing and getting current user data.
* This simple implementation stores data in memory.
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - last selected fun factor persistence support
*/
class AuthenticationUtil {
    
    /// the current user
    var currentUser = User(id: "6", "John Doe", rating: 4.25, funFactor: 4, iconUrl: "")
    
    /*
    Flag: true - the current user has manager role, false - the user is a common user.
    Currently the value is taked from configuration.plist to simplity verification of the prototype
    */
    var isManager = Configuration.sharedConfig.isManagerFlag
    
    /// the singleton
    class var sharedInstance: AuthenticationUtil {
        struct Singleton { static let instance = AuthenticationUtil() }
        return Singleton.instance
    }
    
    /**
    Will be implemented in future to clean up temporary stored user data
    */
    func cleanUp() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kProfileFunFactorIndex)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kProfileFunFactorDate)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kProfileFunFactorComment)
        SFAuthenticationManager.sharedManager().logout()
    }
    
    /**
    Store last selected fun factor for current user
    
    - parameter funFactor: the fun factor
    */
    func setLastFunFactor(funFactor: FunFactorItem) {
        saveValueForKey(funFactor.funFactor, key: kProfileFunFactorIndex)
        saveValueForKey(funFactor.date, key: kProfileFunFactorDate)
        saveValueForKey(funFactor.comment, key: kProfileFunFactorComment)
    }
    
    /**
    Get last specified fun factor (comment will be set to empty string)
    
    - returns: the fun factor
    */
    func getLastFunFactor() -> FunFactorItem? {
        if let funfactorIndex = getValueByKey(kProfileFunFactorIndex) as? Int,
            let date = getValueByKey(kProfileFunFactorDate) as? NSDate,
            let comment = getValueByKey(kProfileFunFactorComment) as? String {
                return FunFactorItem(funFactor: funfactorIndex, comment: comment, date: date)
        }
        return nil
    }
    
    /**
    Get value by key
    
    - parameter key: the key
    
    - returns: the value
    */
    private func getValueByKey(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().valueForKey(key)
    }
    
    /**
    Save value to local preferences
    
    - parameter value: the value to save
    - parameter key:   the key
    */
    private func saveValueForKey(value: AnyObject?, key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(value, forKey: key)
        defaults.synchronize()
    }
}