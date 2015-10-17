//
//  AuthenticationUtil.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Utility for storing and getting current user data.
* This simple implementation stores data in memory.
*
* @author Alexander Volkov
* @version 1.0
*/
class AuthenticationUtil {
    
    /// the current user
    var currentUser = User(id: "6", "John Doe", rating: 4.25, funFactor: 4, iconUrl: "ava5")
    
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
        SFAuthenticationManager.sharedManager().logout()
    }
}