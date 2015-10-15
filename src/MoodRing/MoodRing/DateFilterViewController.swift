//
//  DateFilterViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 11.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Date Picker popup
*
* @author TCASSEMBLER
* @version 1.0
*/
class DateFilterViewController: UIViewController {

    /// outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var fadingView: UIView!
    
    /// the date to show in picker when opened
    var initialDate: NSDate = NSDate()
    
    /// callback to return selected date
    var delegate: ((NSDate)->())!
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        fadingView.backgroundColor = UIColor.clearColor()
        
        // Limit picker to current date because we do not need to filter by future date
        datePicker.maximumDate = NSDate()
        datePicker.date = initialDate
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
    "Done" button action handler
    
    - parameter sender: the button
    */
    @IBAction func applyDateAction(sender: AnyObject) {
        delegate?(datePicker.date)
        closePopup()
    }
    
    /**
    "Cancel" button action handler
    
    - parameter sender: the button
    */
    @IBAction func closePopupAction(sender: AnyObject) {
        closePopup()
    }
    
    /**
    Close this popup
    */
    func closePopup() {
        self.fadingView.alpha = 0
        self.dismissViewControllerToSide(self, side: .BOTTOM, nil)
    }

}
