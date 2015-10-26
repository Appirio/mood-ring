//
//  Rating.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 19.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Model object for user rating in the project
*
* @author TCASSEMBLER
* @version 1.0
*/
class Rating {
    
    /// the ID of corresponding RatingHistory object on the server
    let id: String
    
    /// The related ProjectUser. If nil, then this object is used for common perposes like a value for a plot graph.
    let projectUser: ProjectUser?
    
    /// the rating value
    let rating: Float
    
    /// the user who set this rating to given ProjectUser
    let ratedBy: User?
    
    /// the related comment
    let comment: String
    
    /// the rating date
    var date: NSDate = NSDate()
    
    /**
    Instantiate new Rating object
    
    - parameter id:          the ID of RatingHistory object
    - parameter projectUser: the related ProjectUser
    - parameter rating:      the rating value
    - parameter ratedBy:     the author of the rating (User)
    - parameter comment:     the related comment
    
    - returns: new instance
    */
    init(id: String, projectUser: ProjectUser?, rating: Float, ratedBy: User?, comment: String = "") {
        self.id = id
        self.projectUser = projectUser
        self.rating = rating
        self.ratedBy = ratedBy
        self.comment = comment
    }
}