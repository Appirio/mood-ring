//
//  User.swift
//  MoodRing
//
//  Created by Alexander Volkov on 09.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Model object for a user
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - funFactor type changes to FunFactorItem
* - new initializer
* - safe methods for getting a fun factor
*/
class User {
 
    /// the ID of the user
    let id: String
    
    /// full name
    let fullName: String
    
    /// user's average rating for all projects
    var avgAllProjectsRating: Float
    
    /// user's fun factor index
    var funFactor: FunFactorItem?
    
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
    init(id: String, _ fullName: String, rating: Float = 0, funFactor: FunFactorItem? = nil, iconUrl: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.avgAllProjectsRating = rating
        self.funFactor = funFactor
        self.iconUrl = iconUrl
    }
    
    /**
    Instantiate new User instance
    
    - parameter id:        the id of the user
    - parameter fullName:  the full name
    - parameter rating:    The current rating. Used in UI to show on different screens.
    - parameter funFactor: The current fun factor of the user. Uses current date and empty comment.
    - parameter iconUrl:   the URL of user's image
    
    - returns: new instance
    */
    init(id: String, _ fullName: String, rating: Float = 0, funFactor: Int = 2, iconUrl: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.avgAllProjectsRating = rating
        self.funFactor = FunFactorItem.getDefaultFunFactor()
        self.iconUrl = iconUrl
    }
    
    /**
    Get current fun factor
    
    - returns: the fun factor index
    */
    func getFunFactor() -> Int {
        return funFactor?.funFactor ?? 2 // "Normal" by default (2)
    }
    
    /**
    Get fun factor item.
    
    - returns: either specified or default FunFactorItem
    */
    func getFunFactorItem() -> FunFactorItem {
        return funFactor ?? FunFactorItem.getDefaultFunFactor()
    }
}