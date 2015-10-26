//
//  RateUserViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* "Rate" popup used to rate a user
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
*/
class RateUserViewController: SetFunFactorViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userIconView: UIImageView!
    
    /// the related user
    var projectUser: ProjectUser!
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        if selectedIndex == nil {
            selectedIndex = 0       // at least one star is selected by default
        }
        super.viewDidLoad()

        titleLabel.text = "RATE_PREFIX".localized() + " \(projectUser.user.fullName)"
        userIconView.makeRound()
        userIconView.image = UIImage(named: "noProfileIcon")
        UIImage.loadAsync(projectUser.user.iconUrl) { (image) -> () in
            self.userIconView.image = image
        }
    }

    /**
    Updates star buttons to reflect the selected rate
    
    - parameter button: the last selected button
    */
    override func updateSelectedButton(button: UIButton) {
        for b in buttons {
            b.selected = button.tag >= b.tag
        }
    }
    
    /**
    Send new rating to the server
    
    - parameter selectedIndex: the selected index
    - parameter comment:       the related comment
    - parameter callback:      the callback to invoke after receiving the response
    - parameter failure:       the callback to invoke when an error occurred
    */
    override func processSubmission(selectedIndex: Int, comment: String, callback: ()->(), failure: FailureCallback) {
        let rating = selectedIndex + 1 // convert to rating value
        api.saveRating(rating, comment: comment, projectUser: projectUser,
            callback: callback, failure: failure)
    }
}
