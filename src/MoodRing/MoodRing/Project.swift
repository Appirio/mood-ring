//
//  Project.swift
//  MoodRing
//
//  Created by Alexander Volkov on 09.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
Possible project states
*/
enum ProjectStatus: String {
    case Active = "Active", Completed = "Completed"
}

/**
* Model object for Projects
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - status property added
*/
class Project {
    
    /// the id
    let id: String
    
    /// the title
    let title: String
    
     /// the project rating
    var rating: Float = 0
    
    /// average user's rating
    var avgRating: Float = 0
    
    /// project icon URL
    var iconURL: String?
    
    /// the background color for project icon
    var tintColor: UIColor = UIColor.orange()
    
    /// the project fun factor
    var funFactor: Int = 2
    
    /// the status of the project
    var status: ProjectStatus = .Active
    
    /**
    Instantiate new Project object
    
    - parameter id:        the id
    - parameter title:     the title
    - parameter rating:    current project's rating
    - parameter avgRating: the avarage rating of all user's in the project
    - parameter iconURL:   the project icon URL
    - parameter tintColor: the tint color of the project's icon
    - parameter funFactor: the project's fun factor

    - returns: new instance
    */
    init(id: String, title: String, rating: Float, avgRating: Float, iconURL: String? = nil,
        tintColor: UIColor = UIColor.orange(), funFactor: Int = 2) {
            self.title = title
            self.id = id
            self.rating = rating
            self.avgRating = avgRating
            self.iconURL = iconURL
            self.tintColor = tintColor
            self.funFactor = funFactor
    }

}