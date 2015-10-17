//
//  UserRatingInProjectViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/// sample users for the screen
let SAMPLE_USER_RATING_USERS = [
    User(id: "1", "Jackblack Longnamous", rating: 5, funFactor: 4, iconUrl: "ava0"),
    User(id: "2", "Jane Snow", rating: 4, funFactor: 3, iconUrl: "ava1"),
    User(id: "3", "John Scott", rating: 4, funFactor: 3, iconUrl: "ava2"),
    User(id: "4", "Greg Water", rating: 3, funFactor: 2, iconUrl: "ava3")
]

/**
* User Rating in Project screen (opened from "My Rating" screen).
* Reuses code in MemberDetailsViewController
*
* @author Alexander Volkov
* @version 1.0
*/
class UserRatingInProjectViewController: MemberDetailsViewController {
    
    /**
    Change title to the project's title
    
    - parameter animated: the animation flag
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = project.title
    }
    
    /**
    Customize and show User Details section
    
    - parameter userData: the user's data
    */
    override func addUserDetailsSection(userData: User) {
        // User Details section
        if let vc = self.create(UserDetailsViewController.self) {
            vc.user = userData
            vc.avgRatingOnThisProjectLabelText = "AVG_RATING_THIS_PROJECT".localized()
            vc.avgRatingOnAllProjects = self.avgRatingOnThisProject
            vc.showThisProjectView = false
            vc.showBarDiagram = false
            vc.showSmiley = false
            self.loadViewController(vc, self.topView)
        }
    }
    
    /**
    Load a list of users
    */
    override func loadUsersList() {
        loadSampleUsersList(SAMPLE_USER_RATING_USERS)
    }
}
