//
//  UserRatingInProjectViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* User Rating in Project screen (opened from "My Rating" screen).
* Reuses code in MemberDetailsViewController
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - new parameters in addUserDetailsSection()
*/
class UserRatingInProjectViewController: MemberDetailsViewController {
    
    /**
    Change title to the project's title
    
    - parameter animated: the animation flag
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = projectUser.project.title
    }
    
    /**
    Customize and show User Details section
    
    - parameter projectUser: the user's data
    - parameter ratings:     the list of ratings to show
    */
    override func addUserDetailsSection(projectUser: ProjectUser, ratings: [Rating], funFactors: [FunFactorItem]) {
        // User Details section
        if let vc = self.create(UserDetailsViewController.self) {
            vc.user = projectUser.user
            vc.ratings = ratings
            vc.avgRatingOnThisProjectLabelText = "AVG_RATING_THIS_PROJECT".localized()
            vc.avgRatingOnAllProjects = projectUser.avgProjectUserRating
            vc.showThisProjectView = false
            vc.showBarDiagram = false
            vc.showSmiley = false
            self.loadViewController(vc, self.topView)
        }
    }
    
}
