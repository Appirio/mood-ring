//
//  FilterViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Filter view for Member Details and other screens
*
* @author TCASSEMBLER
* @version 1.0
*/
class FilterViewController: UIViewController {
    
    /// outlet
    @IBOutlet weak var dateLabel: UILabel!
    
    /// the filter date
    var selectedDate = NSDate()
    
    /// callback to invoke when date is changed
    var dateChanged: ((NSDate)->())?
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor() // nest bg from the parent view
    }

    /**
    "Today" button action handler
    
    - parameter sender: the button
    */
    @IBAction func dateFilterAction(sender: AnyObject) {
        if let vc = create(DateFilterViewController.self) {
            vc.initialDate = selectedDate
            vc.delegate = { (date)->() in
                self.selectedDate = date
                
                struct Static {
                    static var filterDateFormatter: NSDateFormatter = {
                        let f = NSDateFormatter()
                        f.dateFormat = "yyyy/M/d"
                        return f
                        }()
                }
                
                self.dateLabel.text = date.formatDate(Static.filterDateFormatter, uppercase: true)
                self.dateChanged?(date)
            }
            if let root = rootController {
                root.showViewControllerFromSide(vc, inContainer: root.view, bounds: root.view.bounds, side: .BOTTOM)
            }
        }
    }
    
}
