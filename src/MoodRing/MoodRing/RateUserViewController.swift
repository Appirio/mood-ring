//
//  RateUserViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* "Rate" popup used to rate a user
*
* @author Alexander Volkov
* @version 1.0
*/
class RateUserViewController: SetFunFactorViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userIconView: UIImageView!
    
    /// the related user
    var user: User!
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        if selectedIndex == nil {
            selectedIndex = 0       // at least one star is selected by default
        }
        super.viewDidLoad()

        titleLabel.text = "RATE_PREFIX".localized() + " \(user.fullName)"
        userIconView.makeRound()
        userIconView.image = nil
        UIImage.loadAsync(user.iconUrl) { (image) -> () in
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
}
