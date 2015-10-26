//
//  ProjectUser.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 18.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Model object to bind User and Project
*
* @author TCASSEMBLER
* @version 1.0
*/
class ProjectUser {
    
    /// the ID of corresponding ProjectUser object on the server
    let id: String

    /// the related user
    let user: User
    
    /// the related project
    let project: Project
    
    /// user rating in current project
    var projectUserRating: Float = 0
    
    /// average user rating for all time
    var avgProjectUserRating: Float = 0
    
    /// flag: true - if current user already has rated this ProjectUser, false - if not yet rated
    var isRatedByCurrentUser: Bool = false
    
    /**
    Instantiate object using given User object
    
    - parameter id:      the ID of ProjectUser object
    - parameter user:    the related user
    - parameter project: the related project
    
    - returns: new instance
    */
    init(id: String, user: User, project: Project) {
        self.id = id
        self.user = user
        self.project = project
    }
}