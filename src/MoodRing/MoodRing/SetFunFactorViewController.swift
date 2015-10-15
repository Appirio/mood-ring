//
//  SetFunFactorViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 09.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Popuo screen to set Fun Factro
*
* @author TCASSEMBLER
* @version 1.0
*/
class SetFunFactorViewController: UIViewController, UITextViewDelegate {

    /// the alpha value for the placeholder
    let PLACEHOLDER_ALPHA: CGFloat = 0.5
    
    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var textView: UITextView!
    
    /// callback to return the selected fun factor and a comment
    var delegate: ((Int, String)->())?
    
    /// currently selected smiley
    var selectedIndex: Int?
    
    /// the placeholder
    private var placeholder = ""
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addLeftButton("Cancel".localized(), selector: "cancelAction")
        addRightButton("Submit".localized(), selector: "submitAction")
        topView.addBottomBorder(color: UIColor(r: 221, g: 221, b: 221))
        
        // placeholder
        self.placeholder = textView.text
        textView.alpha = PLACEHOLDER_ALPHA
        
        for b in buttons {
            if b.tag == selectedIndex {
                updateSelectedButton(b)
                break
            }
        }
    }
    
    /**
    Update buttons to reflect the selected button
    
    - parameter button: the button
    */
    func updateSelectedButton(button: UIButton) {
        for b in buttons {
            b.selected = false
        }
        button.selected = true
    }
    
    /**
    "Submit" button action handler
    */
    func submitAction() {
        if let selectedIndex = selectedIndex {
            self.delegate?(selectedIndex, textView.text ?? "")
            cancelAction()
        }
        else {
            showSubmitError()
        }
    }
    
    /**
    "Cancel" button action handler
    */
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    "Fun Factor" buttons action handler
    
    - parameter sender: the button
    */
    @IBAction func funFactorButtonAction(sender: UIButton) {
        updateSelectedButton(sender)
        selectedIndex = sender.tag
    }
    
    /**
    Dismiss keyboard
    
    - parameter touches: the touches
    - parameter event:   the event
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    /**
    Remove placeholder
    
    - parameter textView: the textView
    */
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text.trim() == placeholder {
           textView.text = ""
           textView.alpha = 1
        }
    }

    /**
    Add placeholder
    
    - parameter textView: the textView
    */
    func textViewDidEndEditing(textView: UITextView) {
        let text = textView.text.trim()
        if text == placeholder || text.isEmpty {
            textView.text = placeholder
            textView.alpha = PLACEHOLDER_ALPHA
        }
    }
    
    /**
    Shows a warning that need to tap any of the buttons
    */
    internal func showSubmitError() {
        showAlert("Fun factor required".localized(), "Please select fun factor".localized())
    }
}