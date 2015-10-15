//
//  User.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 09.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Model object for a user
*
* @author TCASSEMBLER
* @version 1.0
*/
class User {
 
    /// the ID of the user
    let id: String
    
    /// full name
    let fullName: String
    
    /// user's rating
    var rating: Float
    
    /// user's fun factor index
    var funFactor: Int
    
    /// the URL of the user's avatar
    var iconUrl: String?
    
    /**
    Instantiate new User instance
    
    - parameter id:        the id of the user
    - parameter fullName:  the full name
    - parameter rating:    The current rating. Used in UI to show on different screens.
    - parameter funFactor: the current fun factor of the user
    - parameter iconUrl:   the URL of user's image
    
    - returns: new instance
    */
    init(id: String, _ fullName: String, rating: Float = 0, funFactor: Int = 2, iconUrl: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.rating = rating
        self.funFactor = funFactor
        self.iconUrl = iconUrl
    }
}