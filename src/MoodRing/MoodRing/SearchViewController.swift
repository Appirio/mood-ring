//
//  SearchViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 11.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Search view
*
* @author Alexander Volkov
* @version 1.0
*/
class SearchViewController: UIViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet weak var fieldBgView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldBgView.roundCorners(5)
    }

    /**
    "Cancel" button action handler
    
    - parameter sender: the button
    */
    @IBAction func cancelAction(sender: AnyObject) {
        self.removeFromParent()
    }
    
    /**
    Dismiss keyboard
    
    - parameter textField: the textField
    
    - returns: true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        showAlert("Stub", "Search will be implemented in future")
        delay(0.3) { () -> () in
            self.removeFromParent()
        }
        return true
    }
    
    /**
    "Sound" button action handler
    
    - parameter sender: the button
    */
    @IBAction func soundButtonAction(sender: AnyObject) {
        showStub()
    }
}
