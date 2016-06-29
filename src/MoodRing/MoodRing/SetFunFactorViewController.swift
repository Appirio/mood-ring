//
//  SetFunFactorViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 09.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Popuo screen to set Fun Factro
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
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
    
    /// the API
    internal var api = MoodRingApi.sharedInstance
    
    /// the placeholder
    private var placeholder = ""
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addLeftButton("Cancel".localized(), selector: #selector(SetFunFactorViewController.cancelAction))
        addRightButton("Submit".localized(), selector: #selector(SetFunFactorViewController.submitAction))
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
            var text = self.textView.text ?? ""
            if text == placeholder {
                text = ""
            }
            let loadingIndicator = LoadingView(self.view, dimming: true)
            loadingIndicator.show()
            processSubmission(selectedIndex, comment: text, callback: {
                self.delegate?(selectedIndex, text)
                loadingIndicator.terminate()
                self.cancelAction()
            }, failure: createGeneralFailureCallback(loadingIndicator))
        }
        else {
            showSubmitError()
        }
    }
    
    /**
    Send new fun factor to the server
    
    - parameter selectedIndex: the selected index
    - parameter comment:       the related comment
    - parameter callback:      the callback to invoke after receiving the response
    - parameter failure:       the callback to invoke when an error occurred
    */
    func processSubmission(selectedIndex: Int, comment: String, callback: ()->(), failure: FailureCallback) {
        api.saveFunFactor(selectedIndex, comment: comment, callback: {
            
            // Also save selected fun factor locally
            let funFactor = FunFactorItem(funFactor: selectedIndex, comment: comment)
            AuthenticationUtil.sharedInstance.setLastFunFactor(funFactor)
            callback()
            }, failure: failure)
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