//
//  FunFactorDetailsViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 11.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Fun Factor details popup
*
* @author TCASSEMBLER
* @version 1.0
*/
class FunFactorDetailsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var smileView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var fadingView: UIView!

    /// the related user
    var user: User!
    
    /// the comment
    var comment: String = ""
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        iconView.makeRound()
        fadingView.backgroundColor = UIColor.clearColor()
        updateUI(user, comment: comment)
    }
    
    /**
    Fade background
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.3) { () -> Void in
            self.fadingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }
    }

    /**
    Update UI with data
    
    - parameter data:    the user's data
    - parameter comment: the comment
    */
    func updateUI(data: User, comment: String) {
        iconView.image = nil
        UIImage.loadAsync(data.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        bgView.backgroundColor = UIColor.funFactorColor(data.funFactor)
        smileView.applyFunFactor(data.funFactor, addWhiteBorder: 3)
        titleLabel.text = "\"\(comment)\""
    }
    
    /**
    "Close" button action handler
    
    - parameter sender: the button
    */
    @IBAction func closePopupAction(sender: AnyObject) {
        self.fadingView.alpha = 0
        self.dismissViewControllerToSide(self, side: .BOTTOM, nil)
    }
}
